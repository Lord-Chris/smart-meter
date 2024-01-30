import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:smart_meter/services/notification_service/i_notification_service.dart';

class NotificationService extends INotificationService {
  final _notification = AwesomeNotifications();

  @override
  Future<void> init() async {
    await _notification.initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          channelKey: 'smart_meter',
          channelName: 'Smart Meter',
          channelDescription: 'Smart Meter Notification Channel',
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
    );
  }

  @override
  Future<void> cancelNotification() async {
    return await _notification.cancelAll();
  }

  @override
  Future<void> showNotification() async {
    await _notification.createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'smart_meter',
        title: 'Smart Meter Anomaly Detected',
        body: 'An anomaly has been detected in your smart meter.',
      ),
    );
  }
}
