import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads incident photos, which are stored as JPEG bytes in Firestore under
/// `incidents/{incidentId}/photos/{index}` (one document per photo, each kept
/// under Firestore's 1 MiB document limit).
class PhotoStorage {
  PhotoStorage({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  /// Largest photo we accept, leaving headroom below the 1 MiB document limit.
  static const maxPhotoBytes = 900 * 1024;

  final FirebaseFirestore _db;
  final Map<String, Future<Uint8List?>> _cache = {};

  Future<Uint8List?> load(String incidentId, int index) {
    final key = '$incidentId/$index';
    return _cache[key] ??= _fetch(incidentId, index).then((bytes) {
      if (bytes == null) _cache.remove(key);
      return bytes;
    });
  }

  Future<Uint8List?> _fetch(String incidentId, int index) async {
    try {
      final doc = await _db.collection('incidents').doc(incidentId).collection('photos').doc('$index').get();
      final blob = doc.data()?['bytes'];
      return blob is Blob ? blob.bytes : null;
    } on FirebaseException {
      return null;
    }
  }
}
