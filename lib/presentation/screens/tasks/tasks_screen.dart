import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_sheet.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final activeFilter = ref.watch(taskFilterProvider);
    final activeSort = ref.watch(taskSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Management'),
        elevation: 0,
        actions: [
          PopupMenuButton<TaskSortBy>(
            initialValue: activeSort,
            icon: const Icon(Icons.sort_rounded, color: AppColors.primaryLight),
            color: AppColors.elevatedSurface,
            onSelected: (sort) {
              ref.read(taskSortProvider.notifier).state = sort;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskSortBy.deadline,
                child: Text('Sort by Deadline'),
              ),
              const PopupMenuItem(
                value: TaskSortBy.priority,
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: TaskSortBy.dateCreated,
                child: Text('Sort by Date Created'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Search Input Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search task or course...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(taskSearchProvider.notifier).state = '';
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    ref.read(taskSearchProvider.notifier).state = val;
                  },
                ),
                const SizedBox(height: 12),

                // Horizontal Filter Chips (ALL, TODAY, UPCOMING, OVERDUE, COMPLETED)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TaskFilter.values.map((f) {
                      final isSelected = activeFilter == f;
                      String label;
                      switch (f) {
                        case TaskFilter.all:
                          label = 'All Tasks';
                          break;
                        case TaskFilter.today:
                          label = 'Today';
                          break;
                        case TaskFilter.upcoming:
                          label = 'Upcoming';
                          break;
                        case TaskFilter.overdue:
                          label = 'Overdue';
                          break;
                        case TaskFilter.completed:
                          label = 'Completed';
                          break;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(taskFilterProvider.notifier).state = f;
                          },
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Task List Body
          Expanded(
            child: filteredTasks.isEmpty
                ? EmptyStateWidget.noTasks(
                    onAddTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const TaskFormSheet(),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
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
          ),
        ],
      ),
    );
  }
}
