import 'package:flutter/material.dart';

import 'package:campus_incidents/core/incident_styles.dart';
import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/widgets/incident_photo.dart';

class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 72});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (incident.photoCount == 0) return _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: IncidentPhoto(
        incidentId: incident.id,
        index: 0,
        width: size,
        height: size,
        placeholder: _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(incident.category.icon, color: AppColors.primary, size: size * 0.4),
    );
  }
}
