import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> init() async {
    debugPrint('NotificationService initialized (Mock)');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint('Notification Alert: $title - $body');
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    debugPrint('Notification Scheduled: $title - $body at $scheduledDate');
  }
}
