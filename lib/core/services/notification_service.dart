import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission() ?? false;
      return granted;
    } else if (Platform.isIOS) {
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
      return granted;
    }
    return true;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'unitask_channel_id',
      'UniTask Reminders',
      channelDescription: 'University task deadline reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleTaskReminder(TaskItem task) async {
    if (kIsWeb || task.deadline == null || task.status == TaskStatus.completed) return;

    final deadline = task.deadline!;
    final now = DateTime.now();

    // 1. Reminder H-1 (Day before at 19:00)
    final hMinus1Date = DateTime(deadline.year, deadline.month, deadline.day - 1, 19, 0);
    if (hMinus1Date.isAfter(now)) {
      final h1Id = task.id.hashCode.abs() + 1;
      await _scheduleNotification(
        id: h1Id,
        title: '⏰ Besok Deadline: ${task.title}',
        body: 'Tugas "${task.title}" (${task.courseName ?? "Mata Kuliah"}) harus selesai besok.',
        scheduledDate: hMinus1Date,
        payload: task.id,
      );
    }

    // 2. Reminder Day-of Deadline (Morning at 08:00)
    final dayOfDate = DateTime(deadline.year, deadline.month, deadline.day, 8, 0);
    if (dayOfDate.isAfter(now)) {
      final dayId = task.id.hashCode.abs() + 2;
      await _scheduleNotification(
        id: dayId,
        title: '🚨 Deadline Hari Ini: ${task.title}',
        body: 'Tugas "${task.title}" tenggat hari ini. Selesaikan sebelum waktu habis!',
        scheduledDate: dayOfDate,
        payload: task.id,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'unitask_reminders_channel',
        'Task Deadline Reminders',
        channelDescription: 'Notifications for upcoming task deadlines',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelTaskReminder(String taskId) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id: taskId.hashCode.abs() + 1);
    await _notificationsPlugin.cancel(id: taskId.hashCode.abs() + 2);
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }
}
