abstract class INotificationService {
  Future<void> init();
  Future<void> showNotification();
  Future<void> cancelNotification();
}
