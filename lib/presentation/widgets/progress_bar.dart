import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TaskProgressBar extends StatelessWidget {
  final double ratio;
  final int completedCount;
  final int totalCount;
  final bool showLabel;

  const TaskProgressBar({
    super.key,
    required this.ratio,
    required this.completedCount,
    required this.totalCount,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (ratio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount / $totalCount subtasks',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: ratio == 1.0 ? AppColors.statusCompleted : AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                color: AppColors.borderSubtle,
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                widthFactor: ratio.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: ratio == 1.0 ? AppColors.statusCompleted : AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
