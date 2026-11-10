import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/incident_styles.dart';
import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/providers/incident_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/screens/incident_details_screen.dart';
import 'package:campus_incidents/widgets/empty_state.dart';
import 'package:campus_incidents/widgets/incident_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearAll(IncidentProvider provider) {
    _search.clear();
    provider.clearFilters();
  }

  void _showCategorySheet(IncidentProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by category', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in IncidentCategory.values)
                    ChoiceChip(
                      avatar: Icon(category.icon, size: 18),
                      label: Text(category.label),
                      selected: provider.filter.category == category,
                      onSelected: (_) {
                        provider.setCategoryFilter(provider.filter.category == category ? null : category);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final isStaff = context.select<SessionProvider, bool>((s) => s.profile?.isStaff ?? false);
    final filter = provider.filter;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Text(
                  isStaff ? 'All Reports' : 'Reports',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Filter by category',
                  onPressed: () => _showCategorySheet(provider),
                  icon: Badge(
                    isLabelVisible: filter.category != null,
                    smallSize: 8,
                    child: const Icon(Icons.tune_rounded),
                  ),
                ),
              ],
            ),
          ),
          if (!isStaff)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ReportScope>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ReportScope.mine, label: Text('My reports')),
                    ButtonSegment(value: ReportScope.campus, label: Text('Across campus')),
                  ],
                  selected: {provider.scope},
                  onSelectionChanged: (selection) => provider.setScope(selection.first),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: TextField(
              controller: _search,
              onChanged: provider.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search title, place or details',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          provider.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _StatusChoice(
                  label: 'All',
                  selected: filter.status == null,
                  onTap: () => provider.setStatusFilter(null),
                ),
                for (final status in IncidentStatus.values)
                  _StatusChoice(
                    label: status.label,
                    selected: filter.status == status,
                    onTap: () => provider.setStatusFilter(status),
                  ),
              ],
            ),
          ),
          if (filter.category != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: InputChip(
                avatar: Icon(filter.category!.icon, size: 16),
                label: Text(filter.category!.label),
                onDeleted: () => provider.setCategoryFilter(null),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults(provider)),
        ],
      ),
    );
  }

  Widget _buildResults(IncidentProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Reports unavailable',
        message: provider.error!,
      );
    }

    final items = provider.visibleIncidents;
    if (items.isEmpty) {
      return provider.filter.isActive
          ? EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matching reports',
              message: 'Try another search term or remove a filter.',
              actionLabel: 'Clear filters',
              onAction: () => _clearAll(provider),
            )
          : const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nothing reported yet',
              message: 'Tap the Report button to log the first issue.',
            );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => IncidentCard(
        incident: items[index],
        onTap: () => IncidentDetailsScreen.open(context, items[index]),
      ),
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
