import 'package:flutter/material.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/screens/home_screen.dart';
import 'package:campus_incidents/screens/profile_screen.dart';
import 'package:campus_incidents/screens/report_incident_screen.dart';
import 'package:campus_incidents/screens/reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openReportForm() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onSeeAllReports: () => setState(() => _index = 1),
            onReportIssue: _openReportForm,
          ),
          const ReportsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelect: (index) => setState(() => _index = index),
        onReport: _openReportForm,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelect, required this.onReport});

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => onSelect(0),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description_rounded,
                label: 'Reports',
                selected: index == 1,
                onTap: () => onSelect(1),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onReport,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Report',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                selected: index == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
