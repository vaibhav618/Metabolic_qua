import 'package:equatable/equatable.dart';

/// Base class for all notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch all notifications for a given target (client / dietitian)
class FetchNotificationsEvent extends NotificationEvent {
  final String targetId;

  const FetchNotificationsEvent({required this.targetId});

  @override
  List<Object?> get props => [targetId];
}

/// Mark a single notification as seen
class MarkNotificationSeenEvent extends NotificationEvent {
  final int notificationId;

  const MarkNotificationSeenEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications for a targetId as seen
class MarkAllNotificationsSeenEvent extends NotificationEvent {
  final String targetId;

  const MarkAllNotificationsSeenEvent({required this.targetId});

  @override
  List<Object?> get props => [targetId];
}

/// Fetch only unseen count (using fetch_notification.php)
class FetchUnseenCountEvent extends NotificationEvent {
  final String targetId;

  const FetchUnseenCountEvent({required this.targetId});

  @override
  List<Object?> get props => [targetId];
}
