import 'package:flutter/material.dart';

import 'package:campus_incidents/core/incident_styles.dart';
import 'package:campus_incidents/models/incident.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final IncidentStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 9 : 12, vertical: dense ? 4 : 6),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: dense ? 11.5 : 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
