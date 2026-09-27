import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TaskStatus.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_outline_rounded;
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        icon = Icons.play_circle_outline_rounded;
        break;
      case TaskStatus.todo:
      default:
        color = AppColors.statusTodo;
        icon = Icons.circle_outlined;
        break;
    }

    // Seamless status text without background box
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
