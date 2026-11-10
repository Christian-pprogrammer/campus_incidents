import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_incidents/models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Future<void> createProfile(AppUser user) {
    return _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<AppUser?> watch(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : AppUser.fromMap(snapshot.id, data);
    });
  }

  Future<AppUser?> fetch(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    return data == null ? null : AppUser.fromMap(snapshot.id, data);
  }
}
