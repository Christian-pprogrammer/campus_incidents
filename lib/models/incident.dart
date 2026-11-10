import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentCategory {
  facilities('Facilities'),
  water('Water'),
  electricity('Electricity'),
  furniture('Furniture'),
  sanitation('Sanitation'),
  safety('Safety');

  const IncidentCategory(this.label);
  final String label;

  static IncidentCategory fromName(String? name) {
    return values.firstWhere((c) => c.name == name, orElse: () => facilities);
  }
}

enum IncidentStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved');

  const IncidentStatus(this.label);
  final String label;

  static IncidentStatus fromName(String? name) {
    return values.firstWhere((s) => s.name == name, orElse: () => submitted);
  }

  IncidentStatus? get next => switch (this) {
        IncidentStatus.submitted => IncidentStatus.inProgress,
        IncidentStatus.inProgress => IncidentStatus.resolved,
        IncidentStatus.resolved => null,
      };
}

DateTime readDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}

class StatusChange {
  const StatusChange({
    required this.status,
    required this.changedAt,
    required this.changedBy,
    this.note,
  });

  final IncidentStatus status;
  final DateTime changedAt;
  final String changedBy;
  final String? note;

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  factory StatusChange.fromMap(Map<String, dynamic> map) {
    return StatusChange(
      status: IncidentStatus.fromName(map['status'] as String?),
      changedAt: readDate(map['changedAt']),
      changedBy: map['changedBy'] as String? ?? '',
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'changedAt': Timestamp.fromDate(changedAt),
        'changedBy': changedBy,
        if (hasNote) 'note': note!.trim(),
      };
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.createdAt,
    required this.updatedAt,
    this.locationDetail = '',
    this.photoCount = 0,
    this.history = const [],
    this.affectedBy = const [],
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final String locationDetail;
  final int photoCount;
  final IncidentStatus status;
  final String reporterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusChange> history;
  final List<String> affectedBy;

  String get fullLocation => locationDetail.isEmpty ? location : '$location — $locationDetail';

  int get affectedCount => affectedBy.length;

  bool isAffectedBy(String uid) => affectedBy.contains(uid);

  List<StatusChange> get notes => history.where((c) => c.hasNote).toList();

  StatusChange? changeFor(IncidentStatus target) {
    StatusChange? latest;
    for (final change in history) {
      if (change.status == target) latest = change;
    }
    return latest;
  }

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Incident.fromMap(doc.id, doc.data() ?? const {});
  }

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final history = (map['history'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => StatusChange.fromMap(Map<String, dynamic>.from(entry)))
        .toList()
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));

    return Incident(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: IncidentCategory.fromName(map['category'] as String?),
      location: map['location'] as String? ?? '',
      locationDetail: map['locationDetail'] as String? ?? '',
      photoCount: (map['photoCount'] as num?)?.toInt() ?? 0,
      status: IncidentStatus.fromName(map['status'] as String?),
      reporterId: map['reporterId'] as String? ?? '',
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
      history: history,
      affectedBy: List<String>.from(map['affectedBy'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'locationDetail': locationDetail,
        'photoCount': photoCount,
        'status': status.name,
        'reporterId': reporterId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'history': history.map((c) => c.toMap()).toList(),
        'affectedBy': affectedBy,
      };
}
