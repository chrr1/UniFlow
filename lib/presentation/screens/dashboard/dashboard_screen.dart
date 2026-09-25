import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/task_card.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: SafeArea(
        child: tasksAsync.when(
          data: (tasks) {
            final activeTasks = tasks.where((t) => t.status != TaskStatus.completed).toList();
            final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

            final overdueTasks = activeTasks.where((t) {
              return DateFormatter.getDeadlineState(t.deadline) == DeadlineState.overdue;
            }).toList();

            final dueSoonTasks = activeTasks.where((t) {
              final st = DateFormatter.getDeadlineState(t.deadline);
              return st == DeadlineState.dueToday || st == DeadlineState.dueTomorrow;
            }).toList();

            // Find Next Up Focus Task (Urgent: Overdue first, then High priority / nearest deadline)
            TaskItem? nextTask;
            if (activeTasks.isNotEmpty) {
              final sorted = List<TaskItem>.from(activeTasks);
              sorted.sort((a, b) {
                final priorityRank = {TaskPriority.high: 0, TaskPriority.medium: 1, TaskPriority.low: 2};
                final pA = priorityRank[a.priority]!;
                final pB = priorityRank[b.priority]!;
                if (pA != pB) return pA.compareTo(pB);

                if (a.deadline == null) return 1;
                if (b.deadline == null) return -1;
                return a.deadline!.compareTo(b.deadline!);
              });
              nextTask = sorted.first;
            }

            final upcomingTasks = activeTasks.where((t) => t.id != nextTask?.id).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "What should I do right now?",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const TaskFormSheet(),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Cards Row (Active, Due Soon, Overdue)
                  Row(
                    children: [
                      _buildSummaryCard(
                        title: 'Active',
                        count: '${activeTasks.length}',
                        icon: Icons.assignment_outlined,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 10),
                      _buildSummaryCard(
                        title: 'Due Soon',
                        count: '${dueSoonTasks.length}',
                        icon: Icons.alarm,
                        color: AppColors.mediumPriority,
                      ),
                      const SizedBox(width: 10),
                      _buildSummaryCard(
                        title: 'Overdue',
                        count: '${overdueTasks.length}',
                        icon: Icons.error_outline,
                        color: AppColors.highPriority,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Focus / Next Task Card (PRD Section 24)
                  if (nextTask != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.bolt, color: AppColors.mediumPriority, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'NEXT UP / FOCUS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TaskCard(
                      task: nextTask,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: nextTask!.id),
                          ),
                        );
                      },
                      onToggleCompleted: (val) {
                        ref.read(tasksProvider.notifier).updateTaskStatus(
                          nextTask!.id,
                          val == true ? TaskStatus.completed : TaskStatus.inProgress,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ] else if (tasks.isEmpty) ...[
                    EmptyStateWidget.noTasks(
                      onAddTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const TaskFormSheet(),
                        );
                      },
                    ),
                  ] else ...[
                    EmptyStateWidget.allCompleted(),
                  ],

                  // Upcoming Tasks Section
                  if (upcomingTasks.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'UPCOMING TASKS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${upcomingTasks.length} tasks',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingTasks.length,
                      itemBuilder: (context, index) {
                        final task = upcomingTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(taskId: task.id),
                              ),
                            );
                          },
                          onToggleCompleted: (val) {
                            ref.read(tasksProvider.notifier).updateTaskStatus(
                              task.id,
                              val == true ? TaskStatus.completed : TaskStatus.inProgress,
                            );
                          },
                        );
                      },
                    ),
                  ],

                  // Recently Completed Tasks Section
                  if (completedTasks.isNotEmpty && activeTasks.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.statusCompleted, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'COMPLETED (${completedTasks.length})',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedTasks.take(3).length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(taskId: task.id),
                              ),
                            );
                          },
                          onToggleCompleted: (val) {
                            ref.read(tasksProvider.notifier).updateTaskStatus(
                              task.id,
                              val == true ? TaskStatus.completed : TaskStatus.inProgress,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: color),
                Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
