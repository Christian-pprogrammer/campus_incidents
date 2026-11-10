import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incidents/models/incident.dart';

void main() {
  final created = DateTime(2026, 10, 15, 10, 24);

  Incident sample() => Incident(
        id: 'abc',
        title: 'Water shortage',
        description: 'No water in the residence since this morning.',
        category: IncidentCategory.water,
        location: 'Student Residence',
        locationDetail: '2nd floor',
        photoCount: 2,
        status: IncidentStatus.inProgress,
        reporterId: 'student-1',
        createdAt: created,
        updatedAt: created,
        history: [
          StatusChange(status: IncidentStatus.submitted, changedAt: created, changedBy: 'student-1'),
          StatusChange(
            status: IncidentStatus.inProgress,
            changedAt: created.add(const Duration(hours: 5)),
            changedBy: 'staff-1',
            note: 'Plumber on the way',
          ),
        ],
        affectedBy: const ['student-2'],
      );

  test('survives a round trip through a Firestore map', () {
    final original = sample();
    final restored = Incident.fromMap(original.id, original.toMap());

    expect(restored.title, original.title);
    expect(restored.category, IncidentCategory.water);
    expect(restored.status, IncidentStatus.inProgress);
    expect(restored.createdAt, created);
    expect(restored.photoCount, 2);
    expect(restored.history.length, 2);
    expect(restored.notes.single.note, 'Plumber on the way');
    expect(restored.isAffectedBy('student-2'), isTrue);
  });

  test('falls back to safe defaults for missing fields', () {
    final incident = Incident.fromMap('x', const {});

    expect(incident.status, IncidentStatus.submitted);
    expect(incident.category, IncidentCategory.facilities);
    expect(incident.photoCount, 0);
    expect(incident.history, isEmpty);
  });

  test('unknown enum values do not crash parsing', () {
    final incident = Incident.fromMap('x', const {'status': 'archived', 'category': 'parking'});

    expect(incident.status, IncidentStatus.submitted);
    expect(incident.category, IncidentCategory.facilities);
  });

  test('changeFor returns the latest change for a status', () {
    final incident = sample();

    expect(incident.changeFor(IncidentStatus.inProgress)?.changedBy, 'staff-1');
    expect(incident.changeFor(IncidentStatus.resolved), isNull);
  });

  test('fullLocation joins the area and the exact spot', () {
    expect(sample().fullLocation, 'Student Residence — 2nd floor');
  });

  test('status moves forward one step at a time', () {
    expect(IncidentStatus.submitted.next, IncidentStatus.inProgress);
    expect(IncidentStatus.inProgress.next, IncidentStatus.resolved);
    expect(IncidentStatus.resolved.next, isNull);
  });
}
