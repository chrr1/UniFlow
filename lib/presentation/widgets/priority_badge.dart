import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/task_model.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    String dotEmoji;

    switch (priority) {
      case TaskPriority.high:
        color = AppColors.highPriority;
        label = 'HIGH';
        dotEmoji = '🔴';
        break;
      case TaskPriority.medium:
        color = AppColors.mediumPriority;
        label = 'MEDIUM';
        dotEmoji = '🟡';
        break;
      case TaskPriority.low:
      default:
        color = AppColors.lowPriority;
        label = 'LOW';
        dotEmoji = '⚪';
        break;
    }

    if (isCompact) {
      return Text(
        dotEmoji,
        style: const TextStyle(fontSize: 12),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
