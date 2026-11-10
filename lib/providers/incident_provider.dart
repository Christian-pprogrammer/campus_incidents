import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/models/incident_filter.dart';
import 'package:campus_incidents/services/incident_repository.dart';

enum ReportScope { mine, campus }

class IncidentProvider extends ChangeNotifier {
  IncidentProvider({required IncidentRepository repository}) : _repository = repository;

  final IncidentRepository _repository;

  AppUser? _user;
  List<Incident> _mine = const [];
  List<Incident> _campus = const [];
  bool _loadingMine = true;
  bool _loadingCampus = true;
  String? _error;
  IncidentFilter _filter = const IncidentFilter();
  ReportScope _scope = ReportScope.mine;

  StreamSubscription<List<Incident>>? _mineSub;
  StreamSubscription<List<Incident>>? _campusSub;

  List<Incident> get myIncidents => _mine;
  List<Incident> get campusIncidents => _campus;
  bool get loadingMine => _loadingMine;
  bool get loadingCampus => _loadingCampus;
  String? get error => _error;
  IncidentFilter get filter => _filter;
  ReportScope get scope => _scope;

  bool get isLoading => _scope == ReportScope.mine ? _loadingMine : _loadingCampus;

  List<Incident> get visibleIncidents {
    return _filter.apply(_scope == ReportScope.mine ? _mine : _campus);
  }

  List<Incident> get needsAttention {
    final open = _campus.where((i) => i.status != IncidentStatus.resolved).toList();
    open.sort((a, b) {
      final byStatus = a.status.index.compareTo(b.status.index);
      return byStatus != 0 ? byStatus : a.createdAt.compareTo(b.createdAt);
    });
    return open;
  }

  static Map<IncidentStatus, int> countByStatus(Iterable<Incident> incidents) {
    final counts = {for (final status in IncidentStatus.values) status: 0};
    for (final incident in incidents) {
      counts[incident.status] = counts[incident.status]! + 1;
    }
    return counts;
  }

  Incident? findById(String id) {
    for (final incident in _mine) {
      if (incident.id == id) return incident;
    }
    for (final incident in _campus) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  void bindUser(AppUser? user) {
    final unchanged = user?.uid == _user?.uid && user?.role == _user?.role;
    _user = user;
    if (unchanged) return;

    _mineSub?.cancel();
    _campusSub?.cancel();
    _mine = const [];
    _campus = const [];
    _loadingMine = true;
    _loadingCampus = true;
    _error = null;
    _filter = const IncidentFilter();
    if (user == null) return;

    _scope = user.isStaff ? ReportScope.campus : ReportScope.mine;
    _mineSub = _repository.watchByReporter(user.uid).listen((items) {
      _mine = items;
      _loadingMine = false;
      notifyListeners();
    }, onError: _onStreamError);
    _campusSub = _repository.watchAll().listen((items) {
      _campus = items;
      _loadingCampus = false;
      notifyListeners();
    }, onError: _onStreamError);
  }

  void _onStreamError(Object error) {
    _error = 'Reports could not be loaded. Check your connection.';
    _loadingMine = false;
    _loadingCampus = false;
    notifyListeners();
  }

  void setScope(ReportScope scope) {
    if (_scope == scope) return;
    _scope = scope;
    notifyListeners();
  }

  void setQuery(String query) {
    _filter = _filter.copyWith(query: query);
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _filter = _filter.copyWith(status: () => status);
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _filter = _filter.copyWith(category: () => category);
    notifyListeners();
  }

  void clearFilters() {
    _filter = const IncidentFilter();
    notifyListeners();
  }

  Future<String?> updateStatus(Incident incident, IncidentStatus status, {String? note}) async {
    final user = _user;
    if (user == null || !user.isStaff) {
      return 'Only campus staff can change the status of a report.';
    }
    try {
      await _repository.updateStatus(
        id: incident.id,
        status: status,
        staffId: user.uid,
        note: note?.trim(),
      );
      return null;
    } on FirebaseException catch (e) {
      return _describe(e);
    }
  }

  Future<String?> toggleAffected(Incident incident) async {
    final user = _user;
    if (user == null) return 'Sign in again to continue.';
    if (incident.reporterId == user.uid) return 'You reported this issue.';
    try {
      await _repository.setAffected(
        id: incident.id,
        uid: user.uid,
        affected: !incident.isAffectedBy(user.uid),
      );
      return null;
    } on FirebaseException catch (e) {
      return _describe(e);
    }
  }

  bool canDelete(Incident incident) {
    final user = _user;
    if (user == null) return false;
    if (user.isStaff) return true;
    return incident.reporterId == user.uid && incident.status == IncidentStatus.submitted;
  }

  Future<String?> deleteIncident(Incident incident) async {
    if (!canDelete(incident)) {
      return 'Reports can only be deleted by their author before staff start working on them.';
    }
    try {
      await _repository.delete(incident);
      return null;
    } on FirebaseException catch (e) {
      return _describe(e);
    }
  }

  String _describe(FirebaseException e) {
    if (e.code == 'permission-denied') return "You don't have permission to do that.";
    if (e.code == 'unavailable') return 'You are offline. Try again when you have a connection.';
    return e.message ?? 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _mineSub?.cancel();
    _campusSub?.cancel();
    super.dispose();
  }
}
