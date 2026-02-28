import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../common/dialogs/floating_message.dart';
import '../../data/bloc/notification_bloc.dart';
import '../../data/bloc/notification_event.dart';
import '../../data/bloc/notification_state.dart';
import '../../data/model/notification_model.dart' show NotificationItemModel, NotificationModel;
import '../widgets/notification_item.dart';
import '../widgets/notification_type_chip.dart';

class NotificationScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const NotificationScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedNotificationLabel = "All";
  bool notificationsEnabled = true; // for toggle UI

  // cache bloc so we don't use context in dispose()
  late final NotificationBloc _notificationBloc;

  String get _targetId => widget.clientProfileModel.profileId.toString();

  @override
  void initState() {
    super.initState();
    _notificationBloc = context.read<NotificationBloc>();
    _notificationBloc.add(FetchNotificationsEvent(targetId: _targetId));
    _notificationBloc.add(FetchUnseenCountEvent(targetId: _targetId));
  }

  @override
  void dispose() {
    // mark all seen when closing screen
    _notificationBloc.add(MarkAllNotificationsSeenEvent(targetId: _targetId));
    super.dispose();
  }

  List<NotificationItemModel> _getFilteredItems(
      NotificationModel model,
      String selectedLabel,
      ) {
    if (model.groupedNotifications.isEmpty) return [];

    if (selectedLabel == "All") {
      final List<NotificationItemModel> all = [];
      model.groupedNotifications.forEach((key, group) {
        all.addAll(group.items);
      });
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all;
    }

    final group = model.groupedNotifications[selectedLabel];
    if (group == null) return [];

    final items = List<NotificationItemModel>.from(group.items);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  String _formatTimeAgo(String createdAtString) {
    try {
      final createdAt = DateTime.parse(createdAtString);
      final diff = DateTime.now().difference(createdAt);

      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
      if (diff.inHours < 24) return "${diff.inHours} hrs ago";
      return "${diff.inDays} days ago";
    } catch (_) {
      return createdAtString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: const Color(0xFFF5F7FA),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading && state is! NotificationLoaded) {
              return const Center(child: CircularProgressIndicator());
            }


            if (state is NotificationError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FloatingMessage.show(
                  context,
                  message: state.message,
                  type: FloatingMessageType.error,
                );
              });
              return const SizedBox.shrink();
            }

            NotificationModel? model;
            int unseenCount = 0;

            if (state is NotificationLoaded) {
              model = state.notificationModel;
              unseenCount = state.unseenCount;
            } else if (state is NotificationUnseenCountLoaded) {
              unseenCount = state.unseenCount;
            }

            final List<String> notificationTypes = ["All"];
            if (model != null && model.groupedNotifications.isNotEmpty) {
              notificationTypes.addAll(model.groupedNotifications.keys);
            }

            final List<NotificationItemModel> items =
            model != null ? _getFilteredItems(model, selectedNotificationLabel) : [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Notifications",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Toggle card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      spacing: 30,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Text(
                                "Turn ON/OFF Notifications",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF252525),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.10,
                                  letterSpacing: -0.30,
                                ),
                              ),
                              Text(
                                "Daily reminders, promotional and messages",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.10,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: notificationsEnabled,
                          onChanged: (v) {
                            setState(() {
                              notificationsEnabled = v;
                            });
                          },
                          activeTrackColor: const Color(0xFF308BF9),
                          thumbColor: const Color(0xFFCAE1FF),
                          trackOutlineWidth:
                          WidgetStateProperty.resolveWith(
                                (states) =>
                            states.contains(WidgetState.selected) ? 1 : 1,
                          ),
                          inactiveThumbColor: const Color(0xFFA1A1A1),
                          trackOutlineColor:
                          WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.selected)
                                ? Colors.transparent
                                : const Color(0xFFA1A1A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Main card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 15),
                      child: Column(
                        spacing: 20,
                        children: [
                          // Chips row with per-type unseen count
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 30,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    itemCount: notificationTypes.length,
                                    itemBuilder: (context, index) {
                                      final type = notificationTypes[index];

                                      int typeUnseen = 0;
                                      if (model != null) {
                                        if (type == "All") {
                                          typeUnseen = unseenCount;
                                        } else {
                                          final group =
                                          model.groupedNotifications[type];
                                          if (group != null) {
                                            typeUnseen = group.notSeenCount;
                                          }
                                        }
                                      }

                                      return notificationTypeChip(
                                        notificationType: type,
                                        isActive:
                                        selectedNotificationLabel == type,
                                        unseenCount: typeUnseen,
                                        onClick: () {
                                          setState(() {
                                            selectedNotificationLabel = type;
                                          });
                                        },
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Notification list
                          Expanded(
                            child: items.isEmpty
                                ? Center(
                              child: Text(
                                "No notifications",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 13,
                                ),
                              ),
                            )
                                : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];

                                return notificationItem(
                                  notificationTitle: item.title,
                                  notificationMessage: item.message,
                                  timeAgo:
                                  _formatTimeAgo(item.createdAt),
                                  isSeen: item.seenStatus == "seen",
                                );
                              },
                              separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
