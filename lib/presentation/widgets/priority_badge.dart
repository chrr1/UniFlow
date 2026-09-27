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
    int barCount;

    switch (priority) {
      case TaskPriority.high:
        color = AppColors.highPriority;
        label = 'High';
        barCount = 3;
        break;
      case TaskPriority.medium:
        color = AppColors.mediumPriority;
        label = 'Med';
        barCount = 2;
        break;
      case TaskPriority.low:
      default:
        color = AppColors.lowPriority;
        label = 'Low';
        barCount = 1;
        break;
    }

    if (isCompact) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    // Seamless Signal Bars without background box
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            final isActive = index < barCount;
            return Container(
              margin: const EdgeInsets.only(right: 2),
              width: 3,
              height: (index + 1) * 3.5 + 2,
              decoration: BoxDecoration(
                color: isActive ? color : AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        ),
        const SizedBox(width: 4),
        Text(
          label,
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
