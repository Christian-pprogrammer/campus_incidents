import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_incidents/models/incident.dart';

class IncidentRepository {
  IncidentRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _incidents => _db.collection('incidents');

  String newId() => _incidents.doc().id;

  Stream<List<Incident>> watchAll({int limit = 200}) {
    return _incidents
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Incident.fromDoc).toList());
  }

  Stream<List<Incident>> watchByReporter(String uid) {
    return _incidents.where('reporterId', isEqualTo: uid).snapshots().map((snapshot) {
      final items = snapshot.docs.map(Incident.fromDoc).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  CollectionReference<Map<String, dynamic>> _photos(String id) => _incidents.doc(id).collection('photos');

  /// Writes the incident and its photos in one batch so a report never ends up
  /// with missing photos.
  Future<void> create(Incident incident, {List<Uint8List> photos = const []}) {
    final batch = _db.batch();
    batch.set(_incidents.doc(incident.id), {
      ...incident.toMap(),
      'photoCount': photos.length,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    for (var i = 0; i < photos.length; i++) {
      batch.set(_photos(incident.id).doc('$i'), {'bytes': Blob(photos[i])});
    }
    return batch.commit();
  }

  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String staffId,
    String? note,
  }) {
    final change = StatusChange(
      status: status,
      changedAt: DateTime.now(),
      changedBy: staffId,
      note: note,
    );
    return _incidents.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'history': FieldValue.arrayUnion([change.toMap()]),
    });
  }

  Future<void> setAffected({required String id, required String uid, required bool affected}) {
    return _incidents.doc(id).update({
      'affectedBy': affected ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> delete(Incident incident) {
    final batch = _db.batch();
    for (var i = 0; i < incident.photoCount; i++) {
      batch.delete(_photos(incident.id).doc('$i'));
    }
    batch.delete(_incidents.doc(incident.id));
    return batch.commit();
  }
}
