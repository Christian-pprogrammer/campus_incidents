import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/providers/incident_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/screens/incident_details_screen.dart';
import 'package:campus_incidents/widgets/empty_state.dart';
import 'package:campus_incidents/widgets/incident_card.dart';
import 'package:campus_incidents/widgets/summary_tile.dart';
import 'package:campus_incidents/widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAllReports, required this.onReportIssue});

  final VoidCallback onSeeAllReports;
  final VoidCallback onReportIssue;

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionProvider, AppUser?>((s) => s.profile);
    final incidents = context.watch<IncidentProvider>();
    if (user == null) return const SizedBox.shrink();

    final isStaff = user.isStaff;
    final source = isStaff ? incidents.campusIncidents : incidents.myIncidents;
    final loading = isStaff ? incidents.loadingCampus : incidents.loadingMine;
    final counts = IncidentProvider.countByStatus(source);
    final highlighted = isStaff ? incidents.needsAttention.take(4).toList() : source.take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hello, ${user.firstName}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                ),
              ),
              UserAvatar(user: user),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isStaff ? 'Here is what needs attention on campus.' : 'Help make our campus safer.',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (!isStaff) ...[
            const SizedBox(height: 4),
            const Text(
              'Report issues and track their resolution.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 20),
          isStaff
              ? _HeroBanner(
                  title: counts[IncidentStatus.submitted] == 1
                      ? '1 new report\nwaiting'
                      : '${counts[IncidentStatus.submitted]} new reports\nwaiting',
                  subtitle: 'Review them and let students know what is happening.',
                  actionLabel: 'Review reports',
                  actionIcon: Icons.fact_check_outlined,
                  onTap: onSeeAllReports,
                )
              : _HeroBanner(
                  title: 'See an issue\non campus?',
                  subtitle: 'Report it and help improve our learning environment.',
                  actionLabel: 'Report an Issue',
                  actionIcon: Icons.add_rounded,
                  onTap: onReportIssue,
                ),
          const SizedBox(height: 28),
          _SectionHeader(title: isStaff ? 'Campus Summary' : 'Report Summary', onSeeAll: onSeeAllReports),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  label: isStaff ? 'All Reports' : 'My Reports',
                  count: source.length,
                  icon: Icons.description_outlined,
                  color: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  label: 'In Progress',
                  count: counts[IncidentStatus.inProgress]!,
                  icon: Icons.schedule_rounded,
                  color: AppColors.blue,
                  background: AppColors.blueSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  label: 'Resolved',
                  count: counts[IncidentStatus.resolved]!,
                  icon: Icons.check_circle_rounded,
                  color: AppColors.green,
                  background: AppColors.greenSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  label: 'Submitted',
                  count: counts[IncidentStatus.submitted]!,
                  icon: Icons.error_rounded,
                  color: AppColors.red,
                  background: AppColors.redSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: isStaff ? 'Needs Attention' : 'Recent Reports', onSeeAll: onSeeAllReports),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (highlighted.isEmpty)
            EmptyState(
              icon: isStaff ? Icons.task_alt_rounded : Icons.inbox_outlined,
              title: isStaff ? 'All caught up' : 'No reports yet',
              message: isStaff
                  ? 'There are no open reports right now.'
                  : 'Issues you report will appear here so you can follow their progress.',
              actionLabel: isStaff ? null : 'Report an issue',
              onAction: isStaff ? null : onReportIssue,
            )
          else
            for (final incident in highlighted)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IncidentCard(
                  incident: incident,
                  onTap: () => IncidentDetailsScreen.open(context, incident),
                ),
              ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionIcon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: 8,
            child: Icon(
              Icons.account_balance_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 230,
                  child: Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.88), height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Icon(actionIcon, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
