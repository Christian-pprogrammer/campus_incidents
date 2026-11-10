import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/services/incident_repository.dart';
import 'package:campus_incidents/services/photo_storage.dart';

class ReportFormProvider extends ChangeNotifier {
  ReportFormProvider({
    required IncidentRepository repository,
    ImagePicker? picker,
  })  : _repository = repository,
        _picker = picker ?? ImagePicker();

  static const maxPhotos = 3;

  final IncidentRepository _repository;
  final ImagePicker _picker;

  IncidentCategory? _category;
  String? _location;
  final List<XFile> _photos = [];
  bool _submitting = false;
  String? _categoryError;
  String? _locationError;

  IncidentCategory? get category => _category;
  String? get location => _location;
  List<XFile> get photos => List.unmodifiable(_photos);
  bool get submitting => _submitting;
  bool get canAddPhoto => _photos.length < maxPhotos;
  String? get categoryError => _categoryError;
  String? get locationError => _locationError;

  void selectCategory(IncidentCategory category) {
    _category = category;
    _categoryError = null;
    notifyListeners();
  }

  void selectLocation(String location) {
    _location = location;
    _locationError = null;
    notifyListeners();
  }

  Future<String?> addPhoto(ImageSource source) async {
    if (!canAddPhoto) return 'You can attach up to $maxPhotos photos.';
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 60, maxWidth: 1280, maxHeight: 1280);
      if (file == null) return null;
      if (await file.length() > PhotoStorage.maxPhotoBytes) {
        return 'That photo is too large. Try a different one.';
      }
      _photos.add(file);
      notifyListeners();
      return null;
    } on PlatformException {
      return source == ImageSource.camera
          ? 'Camera access was denied. Allow it in your phone settings.'
          : 'Photo library access was denied. Allow it in your phone settings.';
    }
  }

  void removePhoto(int index) {
    _photos.removeAt(index);
    notifyListeners();
  }

  bool validateSelections() {
    _categoryError = _category == null ? 'Choose a category' : null;
    _locationError = _location == null ? 'Choose where the issue is' : null;
    notifyListeners();
    return _categoryError == null && _locationError == null;
  }

  Future<String?> submit({
    required AppUser reporter,
    required String title,
    required String description,
    required String locationDetail,
  }) async {
    _submitting = true;
    notifyListeners();
    try {
      final id = _repository.newId();
      final photoBytes = await Future.wait(_photos.map((photo) => photo.readAsBytes()));
      final now = DateTime.now();

      await _repository.create(Incident(
        id: id,
        title: title.trim(),
        description: description.trim(),
        category: _category!,
        location: _location!,
        locationDetail: locationDetail.trim(),
        status: IncidentStatus.submitted,
        reporterId: reporter.uid,
        createdAt: now,
        updatedAt: now,
        history: [
          StatusChange(status: IncidentStatus.submitted, changedAt: now, changedBy: reporter.uid),
        ],
      ), photos: photoBytes);
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Your account is not allowed to submit reports. Make sure your email is verified.';
      }
      return e.message ?? 'The report could not be submitted.';
    } catch (_) {
      return 'The report could not be submitted. Check your connection and try again.';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
