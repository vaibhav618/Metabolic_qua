import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final bool success;
  final String targetId;
  final int totalNotSeenCount;
  final Map<String, NotificationGroupModel> groupedNotifications;

  const NotificationModel({
    required this.success,
    required this.targetId,
    required this.totalNotSeenCount,
    required this.groupedNotifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, NotificationGroupModel> groups = {};

    if (json['grouped_notifications'] != null &&
        json['grouped_notifications'] is Map<String, dynamic>) {
      (json['grouped_notifications'] as Map<String, dynamic>)
          .forEach((key, value) {
        groups[key] = NotificationGroupModel.fromJson(value);
      });
    }

    return NotificationModel(
      success: json['success'] ?? false,
      targetId: json['target_id']?.toString() ?? '',
      totalNotSeenCount:
      int.tryParse(json['total_not_seen_count'].toString()) ?? 0,
      groupedNotifications: groups,
    );
  }

  @override
  List<Object?> get props => [
    success,
    targetId,
    totalNotSeenCount,
    groupedNotifications,
  ];
}

class NotificationGroupModel extends Equatable {
  final int notSeenCount;
  final List<NotificationItemModel> items;

  const NotificationGroupModel({
    required this.notSeenCount,
    required this.items,
  });

  factory NotificationGroupModel.fromJson(Map<String, dynamic> json) {
    final List<NotificationItemModel> list = [];

    if (json['items'] != null && json['items'] is List) {
      for (final item in (json['items'] as List)) {
        list.add(NotificationItemModel.fromJson(item));
      }
    }

    return NotificationGroupModel(
      notSeenCount: int.tryParse(json['not_seen_count'].toString()) ?? 0,
      items: list,
    );
  }

  @override
  List<Object?> get props => [notSeenCount, items];
}

class NotificationItemModel extends Equatable {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String type;
  final String targetId;
  final String? actionType;
  final String? actionPayload;
  final String? scheduledTime;
  final String createdAt;
  final String seenStatus;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.type,
    required this.targetId,
    required this.createdAt,
    required this.seenStatus,
    this.actionType,
    this.actionPayload,
    this.scheduledTime,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      targetId: json['target_id']?.toString() ?? '',
      actionType: json['action_type']?.toString(),
      actionPayload: json['action_payload']?.toString(),
      scheduledTime: json['scheduled_time']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      seenStatus: json['seen_status']?.toString() ?? 'not_seen',
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    notificationType,
    type,
    targetId,
    actionType,
    actionPayload,
    scheduledTime,
    createdAt,
    seenStatus,
  ];
}
