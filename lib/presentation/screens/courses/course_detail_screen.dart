import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_sheet.dart';
import 'course_form_sheet.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? All associated tasks will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(coursesProvider.notifier).deleteCourse(courseId);
              ref.read(tasksProvider.notifier).loadTasks();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.highPriority),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return coursesAsync.when(
      data: (courses) {
        final courseList = courses.where((c) => c.id == courseId).toList();
        if (courseList.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Course not found')),
          );
        }
        final course = courseList.first;

        final allTasks = tasksAsync.value ?? [];
        final courseTasks = allTasks.where((t) => t.courseId == courseId).toList();
        final activeTasks = courseTasks.where((t) => t.status != TaskStatus.completed).toList();
        final completedTasks = courseTasks.where((t) => t.status == TaskStatus.completed).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(course.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CourseFormSheet(initialCourse: course),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.highPriority),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => TaskFormSheet(defaultCourseId: course.id),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (course.code.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.code,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        course.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (course.lecturer.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              course.lecturer,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderSubtle),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('Total Tasks', '${courseTasks.length}', AppColors.textPrimary),
                          _buildStatColumn('Active Tasks', '${activeTasks.length}', AppColors.primaryLight),
                          _buildStatColumn('Completed', '${completedTasks.length}', AppColors.statusCompleted),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Course Tasks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'COURSE TASKS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${courseTasks.length} tasks',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (courseTasks.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.assignment_outlined, size: 40, color: AppColors.textMuted),
                          const SizedBox(height: 10),
                          const Text(
                            'No tasks for this course yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => TaskFormSheet(defaultCourseId: course.id),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Task'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courseTasks.length,
                    itemBuilder: (context, index) {
                      final task = courseTasks[index];
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
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
