import 'package:flutter/foundation.dart';

import 'package:campus_incidents/models/incident.dart';

@immutable
class IncidentFilter {
  const IncidentFilter({this.query = '', this.status, this.category});

  final String query;
  final IncidentStatus? status;
  final IncidentCategory? category;

  bool get isActive => query.trim().isNotEmpty || status != null || category != null;

  IncidentFilter copyWith({
    String? query,
    ValueGetter<IncidentStatus?>? status,
    ValueGetter<IncidentCategory?>? category,
  }) {
    return IncidentFilter(
      query: query ?? this.query,
      status: status != null ? status() : this.status,
      category: category != null ? category() : this.category,
    );
  }

  bool matches(Incident incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;

    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;

    return incident.title.toLowerCase().contains(term) ||
        incident.description.toLowerCase().contains(term) ||
        incident.fullLocation.toLowerCase().contains(term) ||
        incident.category.label.toLowerCase().contains(term);
  }

  List<Incident> apply(List<Incident> incidents) => incidents.where(matches).toList();
}
