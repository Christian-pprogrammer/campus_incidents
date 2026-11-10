import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/campus_locations.dart';
import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/validators.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/providers/report_form_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/services/incident_repository.dart';
import 'package:campus_incidents/widgets/app_text_field.dart';
import 'package:campus_incidents/widgets/category_tile.dart';
import 'package:campus_incidents/widgets/primary_button.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportFormProvider(
        repository: context.read<IncidentRepository>(),
      ),
      child: const _ReportForm(),
    );
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm();

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _locationDetail = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _locationDetail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final form = context.read<ReportFormProvider>();
    final reporter = context.read<SessionProvider>().profile;
    final fieldsValid = _formKey.currentState!.validate();
    final selectionsValid = form.validateSelections();
    if (!fieldsValid || !selectionsValid || reporter == null) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final error = await form.submit(
      reporter: reporter,
      title: _title.text,
      description: _description.text,
      locationDetail: _locationDetail.text,
    );
    if (!mounted) return;

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColors.red));
      return;
    }
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Report submitted. Follow its progress under Reports.')),
    );
  }

  Future<void> _pickPhoto() async {
    final form = context.read<ReportFormProvider>();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final error = await form.addPhoto(source);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _pickLocation() async {
    final form = context.read<ReportFormProvider>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.6),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final place in campusLocations)
                ListTile(
                  title: Text(place),
                  trailing: form.location == place
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(place),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) form.selectLocation(selected);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ReportFormProvider>();
    final locked = form.submitting;

    return PopScope(
      canPop: !locked,
      child: Scaffold(
        appBar: AppBar(title: const Text('Report an Incident')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _FieldLabel('Select a category'),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  for (final category in IncidentCategory.values)
                    CategoryTile(
                      category: category,
                      selected: form.category == category,
                      onTap: locked ? null : () => form.selectCategory(category),
                    ),
                ],
              ),
              if (form.categoryError != null) _ErrorText(form.categoryError!),
              const SizedBox(height: 22),
              AppTextField(
                label: 'Title',
                controller: _title,
                hint: 'Briefly describe the issue',
                maxLength: 80,
                enabled: !locked,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: Validators.title,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: _description,
                hint: 'What happened, since when, and who is affected?',
                maxLines: 5,
                maxLength: 1000,
                enabled: !locked,
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.description,
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Location'),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: locked ? null : _pickLocation,
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                    errorText: form.locationError,
                  ),
                  child: Text(
                    form.location ?? 'Select a building or area',
                    style: TextStyle(
                      fontSize: 15,
                      color: form.location == null ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Room or exact spot (optional)',
                controller: _locationDetail,
                hint: 'Room 204, second floor washroom',
                maxLength: 60,
                enabled: !locked,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  _FieldLabel('Add photos'),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 4),
                    child: Text(
                      '(optional, up to ${ReportFormProvider.maxPhotos})',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              _PhotoPicker(
                photos: form.photos,
                canAdd: form.canAddPhoto && !locked,
                onAdd: _pickPhoto,
                onRemove: locked ? null : form.removePhoto,
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Submit Report', loading: locked, onPressed: _submit),
              if (locked && form.photos.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Uploading photos. This can take a moment on a slow connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(message, style: const TextStyle(color: AppColors.red, fontSize: 12)),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photos,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final List<XFile> photos;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return InkWell(
        onTap: canAdd ? onAdd : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 30),
              SizedBox(height: 8),
              Text('Tap to add photos', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < photos.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(photos[i].path), width: 92, height: 92, fit: BoxFit.cover),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove!(i),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (canAdd)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 92,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
              ),
            ),
        ],
      ),
    );
  }
}
