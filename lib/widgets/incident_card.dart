import 'package:flutter/material.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/time_format.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/widgets/incident_thumbnail.dart';
import 'package:campus_incidents/widgets/status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap});

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const metaStyle = TextStyle(fontSize: 12.5, color: AppColors.textSecondary);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IncidentThumbnail(incident: incident),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        incident.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(timeAgo(incident.createdAt), style: metaStyle),
                          if (incident.affectedCount > 0) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('+${incident.affectedCount}', style: metaStyle),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(status: incident.status, dense: true),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
