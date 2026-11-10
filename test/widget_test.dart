import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/widgets/incident_card.dart';
import 'package:campus_incidents/widgets/status_chip.dart';
import 'package:campus_incidents/widgets/status_timeline.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

Incident incident({IncidentStatus status = IncidentStatus.submitted}) {
  final now = DateTime.now().subtract(const Duration(hours: 2));
  return Incident(
    id: '1',
    title: 'Broken classroom projector',
    description: 'The projector in room 204 does not turn on.',
    category: IncidentCategory.facilities,
    location: 'Block B',
    status: status,
    reporterId: 'u1',
    createdAt: now,
    updatedAt: now,
    history: [StatusChange(status: IncidentStatus.submitted, changedAt: now, changedBy: 'u1')],
  );
}

void main() {
  testWidgets('status chip shows a readable label', (tester) async {
    await tester.pumpWidget(wrap(const StatusChip(status: IncidentStatus.inProgress)));
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('incident card shows title, place, age and status', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(IncidentCard(incident: incident(), onTap: () => tapped = true)));

    expect(find.text('Broken classroom projector'), findsOneWidget);
    expect(find.text('Block B'), findsOneWidget);
    expect(find.text('2 hours ago'), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);

    await tester.tap(find.byType(IncidentCard));
    expect(tapped, isTrue);
  });

  testWidgets('timeline lists every stage', (tester) async {
    await tester.pumpWidget(wrap(StatusTimeline(incident: incident(status: IncidentStatus.inProgress))));
    for (final status in IncidentStatus.values) {
      expect(find.text(status.label), findsOneWidget);
    }
  });
}
