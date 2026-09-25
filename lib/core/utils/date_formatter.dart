import 'package:intl/intl.dart';

enum DeadlineState {
  overdue,
  dueToday,
  dueTomorrow,
  upcoming,
  completed,
}

class DateFormatter {
  DateFormatter._();

  static String formatDeadline(DateTime? deadline, {bool isCompleted = false}) {
    if (deadline == null) return 'No Deadline';
    if (isCompleted) return DateFormat('E, d MMM').format(deadline);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = targetDate.difference(today).inDays;

    final timeStr = deadline.hour != 0 || deadline.minute != 0
        ? ' • ${DateFormat('HH:mm').format(deadline)}'
        : '';

    if (difference < 0) {
      return 'Overdue (${DateFormat('d MMM').format(deadline)})';
    } else if (difference == 0) {
      return 'Today$timeStr';
    } else if (difference == 1) {
      return 'Tomorrow$timeStr';
    } else if (difference < 7) {
      return '${DateFormat('EEEE').format(deadline)}$timeStr';
    } else {
      return '${DateFormat('E, d MMM').format(deadline)}$timeStr';
    }
  }

  static DeadlineState getDeadlineState(DateTime? deadline, {bool isCompleted = false}) {
    if (isCompleted) return DeadlineState.completed;
    if (deadline == null) return DeadlineState.upcoming;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(deadline.year, deadline.month, deadline.day);
    final difference = targetDate.difference(today).inDays;

    if (difference < 0) return DeadlineState.overdue;
    if (difference == 0) return DeadlineState.dueToday;
    if (difference == 1) return DeadlineState.dueTomorrow;
    return DeadlineState.upcoming;
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM yyyy • HH:mm').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy').format(dateTime);
  }
}
