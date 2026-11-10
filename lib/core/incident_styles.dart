import 'package:flutter/material.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/models/incident.dart';

extension CategoryStyle on IncidentCategory {
  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_rounded,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_rounded,
        IncidentCategory.furniture => Icons.chair_outlined,
        IncidentCategory.sanitation => Icons.delete_outline_rounded,
        IncidentCategory.safety => Icons.shield_outlined,
      };
}

extension StatusStyle on IncidentStatus {
  Color get color => switch (this) {
        IncidentStatus.submitted => AppColors.amber,
        IncidentStatus.inProgress => AppColors.blue,
        IncidentStatus.resolved => AppColors.green,
      };

  Color get softColor => switch (this) {
        IncidentStatus.submitted => AppColors.amberSoft,
        IncidentStatus.inProgress => AppColors.blueSoft,
        IncidentStatus.resolved => AppColors.greenSoft,
      };

  IconData get icon => switch (this) {
        IncidentStatus.submitted => Icons.error_outline_rounded,
        IncidentStatus.inProgress => Icons.schedule_rounded,
        IncidentStatus.resolved => Icons.check_circle_outline_rounded,
      };
}
