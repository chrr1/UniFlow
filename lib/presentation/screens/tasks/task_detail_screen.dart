import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../providers/task_provider.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/deadline_badge.dart';
import '../../widgets/progress_bar.dart';
import 'task_form_sheet.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _handleAddSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      ref.read(tasksProvider.notifier).addSubtask(widget.taskId, text);
      _subtaskController.clear();
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tasksProvider.notifier).deleteTask(widget.taskId);
              Navigator.pop(context); // Go back from detail screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.highPriority),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
            onPressed: () {
              final tasks = tasksAsync.value ?? [];
              final task = tasks.firstWhere((t) => t.id == widget.taskId);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TaskFormSheet(initialTask: task),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.highPriority),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final taskList = tasks.where((t) => t.id == widget.taskId).toList();
          if (taskList.isEmpty) {
            return const Center(child: Text('Task not found'));
          }

          final task = taskList.first;
          final isCompleted = task.status == TaskStatus.completed;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course badge
                if (task.courseName != null && task.courseName!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.courseName!,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Task Title
                Text(
                  task.title,
                  style: TextStyle(
                    color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Status & Priority Grid Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          PopupMenuButton<TaskStatus>(
                            initialValue: task.status,
                            color: AppColors.elevatedSurface,
                            child: StatusBadge(status: task.status),
                            onSelected: (newStatus) {
                              ref.read(tasksProvider.notifier).updateTaskStatus(task.id, newStatus);
                            },
                            itemBuilder: (context) => TaskStatus.values.map((st) {
                              return PopupMenuItem(
                                value: st,
                                child: Row(
                                  children: [
                                    StatusBadge(status: st),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.borderSubtle),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Priority', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          PriorityBadge(priority: task.priority),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.borderSubtle),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Deadline', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          DeadlineBadge(deadline: task.deadline, isCompleted: isCompleted),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Subtasks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SUBTASKS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (task.subtasks.isNotEmpty)
                      Text(
                        '${task.completedSubtasksCount} / ${task.subtasks.length} completed',
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (task.subtasks.isNotEmpty) ...[
                  TaskProgressBar(
                    ratio: task.progressRatio,
                    completedCount: task.completedSubtasksCount,
                    totalCount: task.subtasks.length,
                    showLabel: false,
                  ),
                  const SizedBox(height: 14),
                ],

                // List of subtasks
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: task.subtasks.length,
                  itemBuilder: (context, idx) {
                    final sub = task.subtasks[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: CheckboxListTile(
                        value: sub.isCompleted,
                        activeColor: AppColors.statusCompleted,
                        title: Text(
                          sub.title,
                          style: TextStyle(
                            color: sub.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                            fontSize: 14,
                            decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            ref.read(tasksProvider.notifier).deleteSubtask(sub.id);
                          },
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(tasksProvider.notifier).toggleSubtask(task.id, sub.id, val);
                          }
                        },
                      ),
                    );
                  },
                ),

                // Add subtask inline input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Add new subtask...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onSubmitted: (_) => _handleAddSubtask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _handleAddSubtask,
                      icon: const Icon(Icons.add, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description Section
                if (task.description.isNotEmpty) ...[
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action button: Toggle Complete
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newStatus = isCompleted ? TaskStatus.inProgress : TaskStatus.completed;
                      ref.read(tasksProvider.notifier).updateTaskStatus(task.id, newStatus);
                    },
                    icon: Icon(
                      isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      isCompleted ? 'Mark as In Progress' : 'Mark Completed',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? AppColors.surface : AppColors.statusCompleted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
