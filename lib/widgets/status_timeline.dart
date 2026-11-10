import 'package:flutter/material.dart';

import 'package:campus_incidents/core/theme.dart';
import 'package:campus_incidents/core/time_format.dart';
import 'package:campus_incidents/models/incident.dart';

enum _StepState { done, current, pending }

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    final currentIndex = steps.indexOf(incident.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _TimelineStep(
              status: steps[i],
              state: _stateFor(i, currentIndex, steps.length),
              change: i <= currentIndex ? incident.changeFor(steps[i]) : null,
              showLeftLine: i > 0,
              showRightLine: i < steps.length - 1,
              leftActive: i <= currentIndex,
              rightActive: i < currentIndex,
            ),
          ),
      ],
    );
  }

  _StepState _stateFor(int index, int currentIndex, int total) {
    if (index < currentIndex) return _StepState.done;
    if (index > currentIndex) return _StepState.pending;
    return index == total - 1 ? _StepState.done : _StepState.current;
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.state,
    required this.change,
    required this.showLeftLine,
    required this.showRightLine,
    required this.leftActive,
    required this.rightActive,
  });

  final IncidentStatus status;
  final _StepState state;
  final StatusChange? change;
  final bool showLeftLine;
  final bool showRightLine;
  final bool leftActive;
  final bool rightActive;

  @override
  Widget build(BuildContext context) {
    final labelColor = switch (state) {
      _StepState.current => AppColors.primary,
      _StepState.done => AppColors.textPrimary,
      _StepState.pending => AppColors.textSecondary,
    };

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _line(showLeftLine, leftActive)),
            _dot(),
            Expanded(child: _line(showRightLine, rightActive)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor),
        ),
        const SizedBox(height: 2),
        Text(
          change == null ? '-' : shortDate(change!.changedAt),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _line(bool visible, bool active) {
    final color = !visible
        ? Colors.transparent
        : active
            ? AppColors.primary
            : AppColors.border;
    return Container(height: 2, color: color);
  }

  Widget _dot() {
    switch (state) {
      case _StepState.done:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case _StepState.current:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primarySoft, width: 4),
          ),
          child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 14),
        );
      case _StepState.pending:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
        );
    }
  }
}
