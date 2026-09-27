import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/task_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _confirmResetData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset & Seed Sample Data'),
        content: const Text(
          'This will reset all courses and tasks to the default PRD sample data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(tasksProvider.notifier).resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample data reset successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Reset Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification(BuildContext context) async {
    final granted = await NotificationService().requestPermissions();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permissions not granted.')),
      );
      return;
    }

    await NotificationService().showInstantNotification(
      id: 999,
      title: '⏰ Test Notifikasi UniTask',
      body: 'Pengingat deadline tugas universitas Anda aktif!',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent! Check your device system tray.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final tasksAsync = ref.watch(tasksProvider);

    final coursesCount = coursesAsync.value?.length ?? 0;
    final tasks = tasksAsync.value ?? [];
    final tasksCount = tasks.length;
    final subtasksCount = tasks.fold<int>(0, (sum, t) => sum + t.subtasks.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Notifications (V2 Feature)
          const Text(
            'NOTIFICATIONS (V2)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications_active_rounded, color: AppColors.primaryLight),
                  title: Text('Deadline Reminders', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text('Automatic reminders 1 day before & on deadline day', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 20),
                ),
                const Divider(color: AppColors.borderSubtle, height: 1),
                ListTile(
                  leading: const Icon(Icons.touch_app_rounded, color: AppColors.statusInProgress),
                  title: const Text('Send Test Notification', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Test local notifications on your device', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => _sendTestNotification(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Appearance
          const Text(
            'APPEARANCE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const ListTile(
              leading: Icon(Icons.dark_mode_rounded, color: AppColors.primaryLight),
              title: Text('Theme Mode', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text('Modern Minimal Dark Mode (#0B0D10)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 20),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Data & Storage
          const Text(
            'DATA & STORAGE (LOCAL-FIRST)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage_rounded, color: AppColors.primaryLight),
                  title: const Text('Local Database Stats', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '$coursesCount Courses • $tasksCount Tasks • $subtasksCount Subtasks',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                const Divider(color: AppColors.borderSubtle, height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded, color: AppColors.mediumPriority),
                  title: const Text('Reset to Sample Data', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Restore initial PRD courses and tasks', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => _confirmResetData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: About App
          const Text(
            'ABOUT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'UniTask v2.0 (Productivity)',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'University Task Management Application',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                Text(
                  'Don\'t just store tasks. Help students know what to do next.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
