import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/db_helper.dart';
import '../data/models/course_model.dart';

final coursesProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier();
});

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  CourseNotifier() : super(const AsyncValue.loading()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      final courses = await DbHelper.instance.getCourses();
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCourse(Course course) async {
    await DbHelper.instance.insertCourse(course);
    await loadCourses();
  }

  Future<void> updateCourse(Course course) async {
    await DbHelper.instance.updateCourse(course);
    await loadCourses();
  }

  Future<void> deleteCourse(String id) async {
    await DbHelper.instance.deleteCourse(id);
    await loadCourses();
  }
}
