import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.assignment_turned_in_outlined,
    this.buttonText,
    this.onButtonPressed,
  });

  factory EmptyStateWidget.noTasks({VoidCallback? onAddTap}) {
    return EmptyStateWidget(
      title: 'No tasks yet',
      subtitle: 'Add your first university task\nand keep your deadlines organized.',
      icon: Icons.assignment_add,
      buttonText: '+ Add Task',
      onButtonPressed: onAddTap,
    );
  }

  factory EmptyStateWidget.clearToday() {
    return const EmptyStateWidget(
      title: "You're clear today 🎉",
      subtitle: 'No tasks scheduled for today.\nTake a breather or focus on upcoming work.',
      icon: Icons.wb_sunny_outlined,
    );
  }

  factory EmptyStateWidget.allCompleted() {
    return const EmptyStateWidget(
      title: 'All tasks completed!',
      subtitle: 'Great job! Nothing left to do.',
      icon: Icons.task_alt_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                icon,
                size: 44,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
