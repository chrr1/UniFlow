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
        icon = Icons.warning_amber_rounded;
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
        icon = Icons.event_note_rounded;
        break;
      case DeadlineState.upcoming:
      default:
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
