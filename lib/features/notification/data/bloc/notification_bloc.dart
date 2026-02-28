import 'package:bloc/bloc.dart';

import '../model/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';
import '../repository/notification_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  String? _currentTargetId;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationSeenEvent>(_onMarkNotificationSeen);
    on<MarkAllNotificationsSeenEvent>(_onMarkAllNotificationsSeen);
    on<FetchUnseenCountEvent>(_onFetchUnseenCount);
  }

  Future<void> _onFetchNotifications(
      FetchNotificationsEvent event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());

    try {
      _currentTargetId = event.targetId;

      final NotificationModel model =
      await repository.fetchNotifications(event.targetId);

      final int unseenCount = model.totalNotSeenCount;

      emit(NotificationLoaded(
        notificationModel: model,
        unseenCount: unseenCount,
      ));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationSeen(
      MarkNotificationSeenEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final previousState = state;

    try {
      if (_currentTargetId == null) {
        emit(const NotificationError(
            message: "Target ID not set. Fetch notifications first."));
        return;
      }

      emit(NotificationLoading());

      final bool success = await repository.markAsSeen(event.notificationId);

      if (!success) {
        emit(const NotificationError(
            message: "Failed to mark notification as seen"));
        emit(previousState);
        return;
      }

      final NotificationModel model = await repository.fetchNotifications(_currentTargetId!);
      final int unseenCount =
      await repository.getUnseenCount(_currentTargetId!);

      emit(NotificationLoaded(
        notificationModel: model,
        unseenCount: unseenCount,
      ));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
      emit(previousState);
    }
  }

  Future<void> _onMarkAllNotificationsSeen(
      MarkAllNotificationsSeenEvent event,
      Emitter<NotificationState> emit,
      ) async {
    final previousState = state;

    try {
      _currentTargetId = event.targetId;

      emit(NotificationLoading());

      final bool success = await repository.markAllAsSeen(event.targetId);

      if (!success) {
        emit(const NotificationError(
            message: "Failed to mark all notifications as seen"));
        emit(previousState);
        return;
      }

      final NotificationModel model =
      await repository.fetchNotifications(event.targetId);
      final int unseenCount =
      await repository.getUnseenCount(event.targetId);

      emit(NotificationLoaded(
        notificationModel: model,
        unseenCount: unseenCount,
      ));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
      emit(previousState);
    }
  }

  Future<void> _onFetchUnseenCount(
      FetchUnseenCountEvent event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      _currentTargetId = event.targetId;

      final int unseenCount =
      await repository.getUnseenCount(event.targetId);

      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        emit(current.copyWith(unseenCount: unseenCount));
      } else {
        emit(NotificationUnseenCountLoaded(unseenCount: unseenCount));
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
}
