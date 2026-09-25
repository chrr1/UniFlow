import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class SampleData {
  static Future<void> seedInitialData(Database db) async {
    const uuid = Uuid();
    final now = DateTime.now();

    // 1. Courses
    final courseJarkomId = uuid.v4();
    final coursePplId = uuid.v4();
    final coursePrositId = uuid.v4();
    final courseAkplId = uuid.v4();
    final courseHciId = uuid.v4();

    await db.insert('courses', {
      'id': courseJarkomId,
      'name': 'Jaringan Komunikasi Data',
      'code': 'JKD-201',
      'lecturer': 'Dr. Ir. Budi Santoso',
      'created_at': now.toIso8601String(),
    });

    await db.insert('courses', {
      'id': coursePplId,
      'name': 'Pemodelan Perangkat Lunak',
      'code': 'PPL-302',
      'lecturer': 'Prof. Dian Sastro',
      'created_at': now.toIso8601String(),
    });

    await db.insert('courses', {
      'id': coursePrositId,
      'name': 'Proses Perangkat Lunak',
      'code': 'PPL-305',
      'lecturer': 'Dr. Andi Wijaya',
      'created_at': now.toIso8601String(),
    });

    await db.insert('courses', {
      'id': courseAkplId,
      'name': 'Analisis Kebutuhan Perangkat Lunak',
      'code': 'AKPL-204',
      'lecturer': 'Eko Prasetyo, M.Kom.',
      'created_at': now.toIso8601String(),
    });

    await db.insert('courses', {
      'id': courseHciId,
      'name': 'Human Computer Interaction',
      'code': 'HCI-102',
      'lecturer': 'Maya Putri, M.T.',
      'created_at': now.toIso8601String(),
    });

    // Helper for upcoming dates
    DateTime getNextWeekday(int targetWeekday, int hour) {
      DateTime date = DateTime(now.year, now.month, now.day, hour, 0);
      while (date.weekday != targetWeekday || date.isBefore(now)) {
        date = date.add(const Duration(days: 1));
      }
      return date;
    }

    final nextMonday = getNextWeekday(DateTime.monday, 23);
    final nextTuesday = getNextWeekday(DateTime.tuesday, 17);
    final nextWednesday = getNextWeekday(DateTime.wednesday, 20);

    // 2. Task 1: Use Case & Misuse Case Diagram (PPL)
    final taskPplId = uuid.v4();
    await db.insert('tasks', {
      'id': taskPplId,
      'course_id': coursePplId,
      'title': 'Use Case & Misuse Case Diagram',
      'description': 'Membuat Use Case & Misuse Case Diagram sesuai studi kasus perpustakaan digital yang diberikan.',
      'deadline': nextMonday.toIso8601String(),
      'priority': 'HIGH',
      'status': 'IN_PROGRESS',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    final subtasksPpl = [
      {'title': 'Tentukan studi kasus', 'is_completed': 1},
      {'title': 'Identifikasi aktor', 'is_completed': 1},
      {'title': 'Identifikasi use case', 'is_completed': 1},
      {'title': 'Buat use case diagram', 'is_completed': 0},
      {'title': 'Buat misuse case diagram', 'is_completed': 0},
    ];

    for (var sub in subtasksPpl) {
      await db.insert('subtasks', {
        'id': uuid.v4(),
        'task_id': taskPplId,
        'title': sub['title'],
        'is_completed': sub['is_completed'],
        'created_at': now.toIso8601String(),
      });
    }

    // 3. Task 2: Menghitung Subnet Mask (Jarkom)
    final taskJarkomId = uuid.v4();
    await db.insert('tasks', {
      'id': taskJarkomId,
      'course_id': courseJarkomId,
      'title': 'Menghitung Subnet Mask',
      'description': 'Perhitungan VLSM dan CIDR subnetting untuk 4 gedung lab komputer.',
      'deadline': nextTuesday.toIso8601String(),
      'priority': 'HIGH',
      'status': 'TODO',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    final subtasksJarkom = [
      {'title': 'Tentukan IP address', 'is_completed': 1},
      {'title': 'Tentukan prefix', 'is_completed': 0},
      {'title': 'Hitung subnet mask', 'is_completed': 0},
      {'title': 'Tulis hasil', 'is_completed': 0},
    ];

    for (var sub in subtasksJarkom) {
      await db.insert('subtasks', {
        'id': uuid.v4(),
        'task_id': taskJarkomId,
        'title': sub['title'],
        'is_completed': sub['is_completed'],
        'created_at': now.toIso8601String(),
      });
    }

    // 4. Task 3: Laporan Interview (Prosit)
    final taskPrositId = uuid.v4();
    await db.insert('tasks', {
      'id': taskPrositId,
      'course_id': coursePrositId,
      'title': 'Laporan Interview Objek PMO',
      'description': 'Laporan wawancara dengan Project Manager institusi IT internal.',
      'deadline': nextWednesday.toIso8601String(),
      'priority': 'MEDIUM',
      'status': 'IN_PROGRESS',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    final subtasksProsit = [
      {'title': 'Menentukan objek interview', 'is_completed': 1},
      {'title': 'Melakukan interview', 'is_completed': 1},
      {'title': 'Mengumpulkan informasi', 'is_completed': 1},
      {'title': 'Menulis laporan', 'is_completed': 0},
      {'title': 'Finalisasi PDF', 'is_completed': 0},
    ];

    for (var sub in subtasksProsit) {
      await db.insert('subtasks', {
        'id': uuid.v4(),
        'task_id': taskPrositId,
        'title': sub['title'],
        'is_completed': sub['is_completed'],
        'created_at': now.toIso8601String(),
      });
    }
  }
}
