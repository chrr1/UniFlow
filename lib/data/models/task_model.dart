import 'subtask_model.dart';

enum TaskPriority { high, medium, low }
enum TaskStatus { todo, inProgress, completed }

extension TaskPriorityX on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  static TaskPriority fromString(String val) {
    switch (val.toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'LOW':
      default:
        return TaskPriority.low;
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get name {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'IN_PROGRESS':
      case 'IN PROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
        return TaskStatus.completed;
      case 'TODO':
      default:
        return TaskStatus.todo;
    }
  }
}

class TaskItem {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime? deadline;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Subtask> subtasks;
  final String? courseName; // Optional joined helper field

  TaskItem({
    required this.id,
    required this.courseId,
    required this.title,
    this.description = '',
    this.deadline,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    required this.createdAt,
    required this.updatedAt,
    this.subtasks = const [],
    this.courseName,
  });

  double get progressRatio {
    if (status == TaskStatus.completed) return 1.0;
    if (subtasks.isEmpty) return 0.0;
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    return completedCount / subtasks.length;
  }

  int get completedSubtasksCount {
    return subtasks.where((s) => s.isCompleted).length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map, {List<Subtask>? subtasks, String? courseName}) {
    return TaskItem(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
      priority: TaskPriorityX.fromString(map['priority'] as String? ?? 'MEDIUM'),
      status: TaskStatusX.fromString(map['status'] as String? ?? 'TODO'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      subtasks: subtasks ?? [],
      courseName: courseName ?? map['course_name'] as String?,
    );
  }

  TaskItem copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Subtask>? subtasks,
    String? courseName,
  }) {
    return TaskItem(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      courseName: courseName ?? this.courseName,
    );
  }
}
