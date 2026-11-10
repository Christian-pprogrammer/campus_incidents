import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/models/incident_filter.dart';

Incident make(String id, String title, IncidentCategory category, IncidentStatus status, String location) {
  final now = DateTime(2026, 10, 1);
  return Incident(
    id: id,
    title: title,
    description: 'Details about $title',
    category: category,
    location: location,
    status: status,
    reporterId: 'u1',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final items = [
    make('1', 'Water shortage', IncidentCategory.water, IncidentStatus.submitted, 'Student Residence'),
    make('2', 'Broken projector', IncidentCategory.facilities, IncidentStatus.inProgress, 'Block B'),
    make('3', 'Overflowing bin', IncidentCategory.sanitation, IncidentStatus.resolved, 'Cafeteria'),
    make('4', 'Flickering lights', IncidentCategory.electricity, IncidentStatus.submitted, 'Block B'),
  ];

  test('an empty filter keeps everything', () {
    expect(const IncidentFilter().apply(items).length, 4);
    expect(const IncidentFilter().isActive, isFalse);
  });

  test('filters by status', () {
    final result = const IncidentFilter(status: IncidentStatus.submitted).apply(items);
    expect(result.map((i) => i.id), ['1', '4']);
  });

  test('filters by category', () {
    final result = const IncidentFilter(category: IncidentCategory.sanitation).apply(items);
    expect(result.single.id, '3');
  });

  test('search matches location without caring about case', () {
    final result = const IncidentFilter(query: 'block b').apply(items);
    expect(result.map((i) => i.id), ['2', '4']);
  });

  test('combines search with status', () {
    final result = const IncidentFilter(query: 'block b', status: IncidentStatus.submitted).apply(items);
    expect(result.single.id, '4');
  });

  test('copyWith can clear a filter back to null', () {
    const filter = IncidentFilter(status: IncidentStatus.resolved);
    expect(filter.copyWith(status: () => null).status, isNull);
    expect(filter.copyWith(query: 'bin').status, IncidentStatus.resolved);
  });
}
