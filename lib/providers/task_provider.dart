import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/db_helper.dart';
import '../data/models/task_model.dart';
import '../data/models/subtask_model.dart';
import '../core/utils/date_formatter.dart';
import 'course_provider.dart';

enum TaskFilter { all, today, upcoming, overdue, completed }
enum TaskSortBy { deadline, priority, dateCreated }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final taskSortProvider = StateProvider<TaskSortBy>((ref) => TaskSortBy.deadline);
final taskSearchProvider = StateProvider<String>((ref) => '');
final selectedCourseFilterProvider = StateProvider<String?>((ref) => null);

final tasksProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskItem>>>((ref) {
  return TaskNotifier(ref);
});

class TaskNotifier extends StateNotifier<AsyncValue<List<TaskItem>>> {
  final Ref ref;

  TaskNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await DbHelper.instance.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(TaskItem task) async {
    await DbHelper.instance.insertTask(task);
    await loadTasks();
    ref.read(coursesProvider.notifier).loadCourses();
  }

  Future<void> updateTask(TaskItem task) async {
    await DbHelper.instance.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await DbHelper.instance.deleteTask(id);
    await loadTasks();
    ref.read(coursesProvider.notifier).loadCourses();
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final currentTasks = state.value ?? [];
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updated = currentTasks[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await DbHelper.instance.updateTask(updated);
      await loadTasks();
    }
  }

  Future<void> toggleSubtask(String taskId, String subtaskId, bool isCompleted) async {
    final currentTasks = state.value ?? [];
    final taskIndex = currentTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = currentTasks[taskIndex];
      final updatedSubtasks = task.subtasks.map((sub) {
        if (sub.id == subtaskId) {
          return sub.copyWith(isCompleted: isCompleted);
        }
        return sub;
      }).toList();

      // Check if all subtasks completed -> mark task completed
      final allCompleted = updatedSubtasks.isNotEmpty && updatedSubtasks.every((s) => s.isCompleted);
      TaskStatus newStatus = task.status;
      if (allCompleted && task.status != TaskStatus.completed) {
        newStatus = TaskStatus.completed;
      } else if (!allCompleted && task.status == TaskStatus.completed) {
        newStatus = TaskStatus.inProgress;
      }

      final updatedTask = task.copyWith(
        subtasks: updatedSubtasks,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      final subtaskToUpdate = updatedSubtasks.firstWhere((s) => s.id == subtaskId);
      await DbHelper.instance.updateSubtask(subtaskToUpdate);
      await DbHelper.instance.updateTask(updatedTask);
      await loadTasks();
    }
  }

  Future<void> addSubtask(String taskId, String title) async {
    final subtask = Subtask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      title: title,
      createdAt: DateTime.now(),
    );
    await DbHelper.instance.insertSubtask(subtask);
    await loadTasks();
  }

  Future<void> deleteSubtask(String subtaskId) async {
    await DbHelper.instance.deleteSubtask(subtaskId);
    await loadTasks();
  }

  Future<void> resetAllData() async {
    await DbHelper.instance.resetDatabase();
    await loadTasks();
    ref.read(coursesProvider.notifier).loadCourses();
  }
}

// Filtered & Sorted Tasks Provider
final filteredTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final filter = ref.watch(taskFilterProvider);
  final sortBy = ref.watch(taskSortProvider);
  final searchQuery = ref.watch(taskSearchProvider).trim().toLowerCase();
  final courseFilterId = ref.watch(selectedCourseFilterProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      var result = tasks.toList();

      // Course filter
      if (courseFilterId != null && courseFilterId.isNotEmpty) {
        result = result.where((t) => t.courseId == courseFilterId).toList();
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        result = result.where((t) {
          final titleMatch = t.title.toLowerCase().contains(searchQuery);
          final courseMatch = t.courseName?.toLowerCase().contains(searchQuery) ?? false;
          final descMatch = t.description.toLowerCase().contains(searchQuery);
          return titleMatch || courseMatch || descMatch;
        }).toList();
      }

      // Status/Deadline Filter
      switch (filter) {
        case TaskFilter.today:
          result = result.where((t) {
            if (t.status == TaskStatus.completed) return false;
            final state = DateFormatter.getDeadlineState(t.deadline, isCompleted: false);
            return state == DeadlineState.dueToday;
          }).toList();
          break;
        case TaskFilter.upcoming:
          result = result.where((t) {
            if (t.status == TaskStatus.completed) return false;
            final state = DateFormatter.getDeadlineState(t.deadline, isCompleted: false);
            return state == DeadlineState.upcoming || state == DeadlineState.dueTomorrow;
          }).toList();
          break;
        case TaskFilter.overdue:
          result = result.where((t) {
            if (t.status == TaskStatus.completed) return false;
            final state = DateFormatter.getDeadlineState(t.deadline, isCompleted: false);
            return state == DeadlineState.overdue;
          }).toList();
          break;
        case TaskFilter.completed:
          result = result.where((t) => t.status == TaskStatus.completed).toList();
          break;
        case TaskFilter.all:
        default:
          break;
      }

      // Sorting
      result.sort((a, b) {
        switch (sortBy) {
          case TaskSortBy.priority:
            final priorityOrder = {TaskPriority.high: 0, TaskPriority.medium: 1, TaskPriority.low: 2};
            return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
          case TaskSortBy.dateCreated:
            return b.createdAt.compareTo(a.createdAt);
          case TaskSortBy.deadline:
          default:
            if (a.deadline == null && b.deadline == null) return 0;
            if (a.deadline == null) return 1;
            if (b.deadline == null) return -1;
            return a.deadline!.compareTo(b.deadline!);
        }
      });

      return result;
    },
    orElse: () => [],
  );
});
