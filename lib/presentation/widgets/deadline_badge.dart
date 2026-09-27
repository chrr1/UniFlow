import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';

class DeadlineBadge extends StatelessWidget {
  final DateTime? deadline;
  final bool isCompleted;

  const DeadlineBadge({
    super.key,
    required this.deadline,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (deadline == null) return const SizedBox.shrink();

    final state = DateFormatter.getDeadlineState(deadline, isCompleted: isCompleted);
    final text = DateFormatter.formatDeadline(deadline, isCompleted: isCompleted);

    Color color;
    IconData icon = Icons.schedule_rounded;

    switch (state) {
      case DeadlineState.overdue:
        color = AppColors.overdue;
        icon = Icons.error_outline_rounded;
        break;
      case DeadlineState.dueToday:
        color = AppColors.dueToday;
        icon = Icons.alarm_rounded;
        break;
      case DeadlineState.dueTomorrow:
        color = AppColors.dueSoon;
        icon = Icons.event_available_rounded;
        break;
      case DeadlineState.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_outline_rounded;
        break;
      case DeadlineState.upcoming:
      default:
        color = AppColors.textSecondary;
        break;
    }

    // Seamless deadline text without background box
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
