import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/task_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final TaskItem? initialTask;
  final String? defaultCourseId;

  const TaskFormSheet({
    super.key,
    this.initialTask,
    this.defaultCourseId,
  });

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subtaskInputController;

  String? _selectedCourseId;
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.todo;
  List<String> _subtaskTitles = [];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _subtaskInputController = TextEditingController();

    _selectedCourseId = task?.courseId ?? widget.defaultCourseId;
    _selectedDeadline = task?.deadline;
    if (task?.deadline != null) {
      _selectedTime = TimeOfDay.fromDateTime(task!.deadline!);
    }
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedStatus = task?.status ?? TaskStatus.todo;

    if (task != null) {
      _subtaskTitles = task.subtasks.map((s) => s.title).toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtaskTitles.add(text);
        _subtaskInputController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskTitles.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.elevatedSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime?.hour ?? 23,
          _selectedTime?.minute ?? 59,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.elevatedSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_selectedDeadline != null) {
          _selectedDeadline = DateTime(
            _selectedDeadline!.year,
            _selectedDeadline!.month,
            _selectedDeadline!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    const uuid = Uuid();
    final now = DateTime.now();
    final isEditing = widget.initialTask != null;
    final taskId = isEditing ? widget.initialTask!.id : uuid.v4();

    List<Subtask> subtasks = [];
    if (isEditing) {
      // Retain existing completed states if editing
      subtasks = _subtaskTitles.map((title) {
        final existing = widget.initialTask!.subtasks.firstWhere(
          (s) => s.title == title,
          orElse: () => Subtask(
            id: uuid.v4(),
            taskId: taskId,
            title: title,
            createdAt: now,
          ),
        );
        return existing;
      }).toList();
    } else {
      subtasks = _subtaskTitles
          .map((title) => Subtask(
                id: uuid.v4(),
                taskId: taskId,
                title: title,
                createdAt: now,
              ))
          .toList();
    }

    final task = TaskItem(
      id: taskId,
      courseId: _selectedCourseId!,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _selectedDeadline,
      priority: _selectedPriority,
      status: _selectedStatus,
      createdAt: isEditing ? widget.initialTask!.createdAt : now,
      updatedAt: now,
      subtasks: subtasks,
    );

    if (isEditing) {
      ref.read(tasksProvider.notifier).updateTask(task);
    } else {
      ref.read(tasksProvider.notifier).addTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final isEditing = widget.initialTask != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title
                      TextFormField(
                        controller: _titleController,
                        autofocus: !isEditing,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Task Title (e.g. Laporan Interview)',
                          labelText: 'Task Title *',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Task title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Course Picker
                      coursesAsync.when(
                        data: (courses) {
                          if (courses.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.highPriority.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'No courses found. Please add a course first in Courses tab.',
                                style: TextStyle(color: AppColors.highPriority, fontSize: 13),
                              ),
                            );
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedCourseId ?? (courses.isNotEmpty ? courses.first.id : null),
                            dropdownColor: AppColors.elevatedSurface,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Course *',
                              prefixIcon: Icon(Icons.book_outlined, color: AppColors.primaryLight),
                            ),
                            items: courses.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Text('${c.name} ${c.code.isNotEmpty ? "(${c.code})" : ""}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCourseId = val;
                              });
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection
                      const Text(
                        'Priority',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: TaskPriority.values.map((p) {
                          final isSelected = _selectedPriority == p;
                          Color color;
                          String label;
                          String dot;

                          switch (p) {
                            case TaskPriority.high:
                              color = AppColors.highPriority;
                              label = 'HIGH';
                              dot = '🔴';
                              break;
                            case TaskPriority.medium:
                              color = AppColors.mediumPriority;
                              label = 'MEDIUM';
                              dot = '🟡';
                              break;
                            case TaskPriority.low:
                              color = AppColors.lowPriority;
                              label = 'LOW';
                              dot = '⚪';
                              break;
                          }

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('$dot $label'),
                                selected: isSelected,
                                selectedColor: color.withOpacity(0.2),
                                backgroundColor: AppColors.surface,
                                side: BorderSide(
                                  color: isSelected ? color : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected ? color : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedPriority = p;
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Deadline Date & Time
                      const Text(
                        'Deadline',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLight),
                              label: Text(
                                _selectedDeadline == null
                                    ? 'Set Date'
                                    : DateFormat('d MMM yyyy').format(_selectedDeadline!),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryLight),
                              label: Text(
                                _selectedTime == null
                                    ? 'Set Time (23:59)'
                                    : _selectedTime!.format(context),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description (Optional)
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add extra details or notes...',
                          labelText: 'Description (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtasks List Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Subtasks (Steps to completion)',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskInputController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Add subtask (e.g. Buat usecase diagram)',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _addSubtask,
                            icon: const Icon(Icons.add, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      if (_subtaskTitles.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subtaskTitles.length,
                          itemBuilder: (context, idx) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_box_outline_blank, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _subtaskTitles[idx],
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeSubtask(idx),
                                    child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
