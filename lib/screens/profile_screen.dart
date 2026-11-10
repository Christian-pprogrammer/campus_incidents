import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/models/app_user.dart';
import 'package:campus_incidents/models/incident.dart';
import 'package:campus_incidents/providers/incident_provider.dart';
import 'package:campus_incidents/providers/session_provider.dart';
import 'package:campus_incidents/widgets/summary_tile.dart';
import 'package:campus_incidents/widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _sendReset(BuildContext context, AppUser user) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<SessionProvider>().resetPassword(user.email);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Reset link sent to ${user.email}.')));
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Who can see your reports'),
        content: const Text(
          'Other students can see what was reported and where, but not who reported it. '
          'Campus staff can see your name and email so they can follow up with you. '
          'Only signed-in ALU accounts can open the app.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final session = context.read<SessionProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed == true) await session.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionProvider, AppUser?>((s) => s.profile);
    final mine = context.select<IncidentProvider, List<Incident>>((p) => p.myIncidents);
    if (user == null) return const SizedBox.shrink();
    final counts = IncidentProvider.countByStatus(mine);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                UserAvatar(user: user, radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _RoleBadge(role: user.role),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      if (user.program.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(user.program, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  label: 'Total Reports',
                  count: mine.length,
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
            ],
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.lock_reset_rounded,
            label: 'Change password',
            onTap: () => _sendReset(context, user),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Who can see your reports',
            onTap: () => _showPrivacy(context),
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            color: AppColors.red,
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final isStaff = role == UserRole.staff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isStaff ? AppColors.greenSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isStaff ? 'Staff' : 'Student',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isStaff ? AppColors.green : AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          leading: Icon(icon, color: color),
          title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      ),
    );
  }
}
