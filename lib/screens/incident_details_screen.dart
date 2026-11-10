import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/incident_styles.dart';
import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/time_format.dart';
import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/providers/incident_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/services/user_repository.dart';
import 'package:campus_incidents/widgets/incident_photo.dart';
import 'package:campus_incidents/widgets/incident_thumbnail.dart';
import 'package:campus_incidents/widgets/primary_button.dart';
import 'package:campus_incidents/widgets/status_chip.dart';
import 'package:campus_incidents/widgets/status_timeline.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key, required this.initial});

  final Incident initial;

  static Future<void> open(BuildContext context, Incident incident) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => IncidentDetailsScreen(initial: incident)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Incident incident) async {
    final provider = context.read<IncidentProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('The report and its photos will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    navigator.pop();
    final error = await provider.deleteIncident(incident);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Report deleted.')));
  }

  void _openStatusSheet(BuildContext context, Incident incident) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _StatusUpdateSheet(incident: incident),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final viewer = context.select<SessionProvider, AppUser?>((s) => s.profile);
    final incident = provider.findById(initial.id) ?? initial;
    if (viewer == null) return const SizedBox.shrink();

    final isOwner = incident.reporterId == viewer.uid;
    final notes = incident.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (provider.canDelete(incident))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'delete') _confirmDelete(context, incident);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete report')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _HeaderCard(incident: incident, viewer: viewer, isOwner: isOwner),
          const SizedBox(height: 24),
          const _SectionTitle('Status Timeline'),
          const SizedBox(height: 14),
          StatusTimeline(incident: incident),
          if (!isOwner && !viewer.isStaff && incident.status != IncidentStatus.resolved) ...[
            const SizedBox(height: 20),
            _AffectedButton(incident: incident, uid: viewer.uid),
          ],
          const SizedBox(height: 24),
          const _SectionTitle('Description'),
          const SizedBox(height: 8),
          Text(incident.description, style: const TextStyle(fontSize: 14.5, height: 1.5)),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Updates from staff'),
            const SizedBox(height: 10),
            for (final note in notes.reversed) _NoteTile(change: note),
          ],
          if (incident.photoCount > 0) ...[
            const SizedBox(height: 24),
            _SectionTitle(incident.photoCount == 1 ? 'Attached Photo' : 'Attached Photos'),
            const SizedBox(height: 10),
            _PhotoGallery(incident: incident),
          ],
        ],
      ),
      bottomNavigationBar: viewer.isStaff
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: PrimaryButton(
                  label: 'Update status',
                  icon: Icons.edit_note_rounded,
                  onPressed: () => _openStatusSheet(context, incident),
                ),
              ),
            )
          : null,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.incident, required this.viewer, required this.isOwner});

  final Incident incident;
  final AppUser viewer;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final others = incident.affectedCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IncidentThumbnail(incident: incident, size: 78),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      incident.fullLocation,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(status: incident.status, dense: true),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(incident.category.icon, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              incident.category.label,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          _MetaRow(icon: Icons.calendar_today_outlined, text: 'Submitted on ${fullDate(incident.createdAt)}'),
          const SizedBox(height: 6),
          if (isOwner)
            const _MetaRow(icon: Icons.person_outline_rounded, text: 'Reported by you')
          else if (viewer.isStaff)
            _ReporterName(reporterId: incident.reporterId)
          else
            const _MetaRow(
              icon: Icons.visibility_off_outlined,
              text: 'Reporter is only visible to campus staff',
            ),
          if (others > 0) ...[
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.group_outlined,
              text: '$others other ${others == 1 ? 'person says' : 'people say'} this affects them',
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _ReporterName extends StatefulWidget {
  const _ReporterName({required this.reporterId});

  final String reporterId;

  @override
  State<_ReporterName> createState() => _ReporterNameState();
}

class _ReporterNameState extends State<_ReporterName> {
  late final Future<AppUser?> _reporter = context.read<UserRepository>().fetch(widget.reporterId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _reporter,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final text = switch (snapshot.connectionState) {
          ConnectionState.done when user != null => 'Reported by ${user.fullName} (${user.email})',
          ConnectionState.done => 'Reporter profile not found',
          _ => 'Loading reporter',
        };
        return _MetaRow(icon: Icons.person_outline_rounded, text: text);
      },
    );
  }
}

class _AffectedButton extends StatefulWidget {
  const _AffectedButton({required this.incident, required this.uid});

  final Incident incident;
  final String uid;

  @override
  State<_AffectedButton> createState() => _AffectedButtonState();
}

class _AffectedButtonState extends State<_AffectedButton> {
  bool _saving = false;

  Future<void> _toggle() async {
    setState(() => _saving = true);
    final error = await context.read<IncidentProvider>().toggleAffected(widget.incident);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final affected = widget.incident.isAffectedBy(widget.uid);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _saving ? null : _toggle,
        icon: Icon(affected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded),
        label: Text(affected ? 'You said this affects you' : 'This affects me too'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: affected ? AppColors.primarySoft : null,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.change});

  final StatusChange change;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(status: change.status, dense: true),
              const Spacer(),
              Text(
                shortDate(change.changedAt),
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(change.note!, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.incident});

  final Incident incident;

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoViewer(incidentId: incident.id, index: index),
    ));
  }

  Widget _photo(BuildContext context, int index, {double? width}) {
    return GestureDetector(
      onTap: () => _openViewer(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IncidentPhoto(
          incidentId: incident.id,
          index: index,
          width: width,
          height: 190,
          placeholder: Container(
            width: width,
            height: 190,
            color: AppColors.primarySoft,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (incident.photoCount == 1) return _photo(context, 0, width: double.infinity);
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: incident.photoCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _photo(context, index, width: 250),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.incidentId, required this.index});

  final String incidentId;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: IncidentPhoto(
            incidentId: incidentId,
            index: index,
            fit: BoxFit.contain,
            placeholder: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _StatusUpdateSheet extends StatefulWidget {
  const _StatusUpdateSheet({required this.incident});

  final Incident incident;

  @override
  State<_StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<_StatusUpdateSheet> {
  late IncidentStatus _selected = widget.incident.status.next ?? widget.incident.status;
  final _note = TextEditingController();
  bool _saving = false;
  String? _noteError;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _hasChanges => _selected != widget.incident.status || _note.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (_selected == IncidentStatus.resolved && _note.text.trim().isEmpty) {
      setState(() => _noteError = 'Tell the reporter what was fixed before resolving.');
      return;
    }
    setState(() {
      _saving = true;
      _noteError = null;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<IncidentProvider>().updateStatus(
          widget.incident,
          _selected,
          note: _note.text,
        );
    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('Status set to ${_selected.label}.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              widget.incident.title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final status in IncidentStatus.values)
              _StatusOption(
                status: status,
                selected: _selected == status,
                isCurrent: widget.incident.status == status,
                onTap: _saving ? null : () => setState(() => _selected = status),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 300,
              enabled: !_saving,
              onChanged: (_) => setState(() => _noteError = null),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Note for the reporter, e.g. plumber booked for Friday',
                errorText: _noteError,
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Save update',
              loading: _saving,
              onPressed: _hasChanges ? _save : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  final IncidentStatus status;
  final bool selected;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? status.softColor : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? status.color : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(status.icon, color: status.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCurrent ? '${status.label} (current)' : status.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (selected) Icon(Icons.check_rounded, color: status.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
