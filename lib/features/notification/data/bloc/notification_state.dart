import 'package:equatable/equatable.dart';

import '../model/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationModel notificationModel;
  final int unseenCount;

  const NotificationLoaded({
    required this.notificationModel,
    required this.unseenCount,
  });

  NotificationLoaded copyWith({
    NotificationModel? notificationModel,
    int? unseenCount,
  }) {
    return NotificationLoaded(
      notificationModel: notificationModel ?? this.notificationModel,
      unseenCount: unseenCount ?? this.unseenCount,
    );
  }

  @override
  List<Object?> get props => [notificationModel, unseenCount];
}

class NotificationUnseenCountLoaded extends NotificationState {
  final int unseenCount;

  const NotificationUnseenCountLoaded({required this.unseenCount});

  @override
  List<Object?> get props => [unseenCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
