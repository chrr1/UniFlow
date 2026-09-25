import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course_model.dart';
import '../../../providers/course_provider.dart';

class CourseFormSheet extends ConsumerStatefulWidget {
  final Course? initialCourse;

  const CourseFormSheet({super.key, this.initialCourse});

  @override
  ConsumerState<CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends ConsumerState<CourseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _lecturerController;

  @override
  void initState() {
    super.initState();
    final course = widget.initialCourse;
    _nameController = TextEditingController(text: course?.name ?? '');
    _codeController = TextEditingController(text: course?.code ?? '');
    _lecturerController = TextEditingController(text: course?.lecturer ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    const uuid = Uuid();
    final isEditing = widget.initialCourse != null;

    final course = Course(
      id: isEditing ? widget.initialCourse!.id : uuid.v4(),
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      lecturer: _lecturerController.text.trim(),
      createdAt: isEditing ? widget.initialCourse!.createdAt : DateTime.now(),
    );

    if (isEditing) {
      ref.read(coursesProvider.notifier).updateCourse(course);
    } else {
      ref.read(coursesProvider.notifier).addCourse(course);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCourse != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Course' : 'Add Course',
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Course Name *',
                  hintText: 'e.g. Pemodelan Perangkat Lunak',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _codeController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Course Code (Optional)',
                  hintText: 'e.g. PPL-302',
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _lecturerController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Lecturer Name (Optional)',
                  hintText: 'e.g. Prof. Dian Sastro',
                ),
              ),
              const SizedBox(height: 24),

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
                    isEditing ? 'Save Course' : 'Create Course',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
