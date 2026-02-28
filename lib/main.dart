import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:respyr_dietitian/core/audio/audio_cubit.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/datasource/uuid_bluetooth_manager.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/repository_impl/bluetooth_repository_impl.dart';

import 'package:respyr_dietitian/features/dietitian_dashboard/data/repository/dietitian_dashboard_repository.dart';
import 'package:respyr_dietitian/features/dietitian_dashboard/presentation/cubit/dietitian_dashboard_cubit.dart';

import 'package:respyr_dietitian/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:respyr_dietitian/features/log_food/presentation/cubit/test_timer_cubit/test_timer_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/data/repository/dietician_repository.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmi.dart';
import 'package:respyr_dietitian/features/profile_info/domain/usecases/calculate_bmr.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/create_profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';

import 'package:respyr_dietitian/routes/app_router.dart' hide rootNavigatorKey;

import 'core/global_keys.dart';
import 'features/bluetooth_device_connectivity/presentation/cubit/global_error_cubit/global_error_cubit.dart';
import 'features/bluetooth_device_connectivity/presentation/widgets/global_ble_popup_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class InternetCubit extends Cubit<bool> {
  InternetCubit() : super(true) {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    emit(!_isOffline(initial));
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      emit(!_isOffline(results));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

Future<String?> _tryGetFcmTokenOnce() async {
  try {
    final t = await FirebaseMessaging.instance.getToken();
    if (t != null && t.isNotEmpty) return t;
  } catch (e) {
    // ignore: avoid_print
    print("❌ getToken failed: $e");
  }
  return null;
}

Future<String?> _getFcmTokenWithRetry() async {
  for (int i = 0; i < 6; i++) {
    final t = await _tryGetFcmTokenOnce();
    if (t != null) return t;
    await Future.delayed(Duration(seconds: 2 + (i * 2)));
  }
  return null;
}

Future<void> _initFcmAndLocalNotifs() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    final notifSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    // ignore: avoid_print
    print("🔔 iOS permission: ${notifSettings.authorizationStatus}");
  } catch (e) {
    // ignore: avoid_print
    print("❌ requestPermission failed: $e");
  }

  try {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    // ignore: avoid_print
    print("❌ setForegroundNotificationPresentationOptions failed: $e");
  }

  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iOSInit,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      try {
        final payload = details.payload;
        if (payload != null && payload.isNotEmpty) {
          final data = jsonDecode(payload);
          final screen = data['screen'];
          final chatUserId = data['chatUserId'];

          if (screen == 'chat-screen') {
            appRouter.pushNamed('chat', extra: chatUserId);
          } else {
            appRouter.goNamed('home');
          }
        } else {
          appRouter.goNamed('home');
        }
      } catch (_) {
        appRouter.goNamed('home');
      }
    },
  );

  try {
    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  } catch (e) {
    // ignore: avoid_print
    print("❌ iOS local notif permission failed: $e");
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );

  try {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } catch (e) {
    // ignore: avoid_print
    print("❌ createNotificationChannel failed: $e");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  });

  try {
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    // ignore: avoid_print
    print("✅ APNS TOKEN: $apnsToken");
  } catch (e) {
    // ignore: avoid_print
    print("❌ getAPNSToken failed: $e");
  }

  Future.microtask(() async {
    final token = await _getFcmTokenWithRetry();
    // ignore: avoid_print
    print("✅ FCM TOKEN: $token");
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await WakelockPlus.enable();

  await Firebase.initializeApp();
  tzdata.initializeTimeZones();

  await _initFcmAndLocalNotifs();

  final calculateBMI = CalculateBMI();
  final calculateBMR = CalculateBMR();
  final dieticianRepository = DietitianRepository();
  final dietitianDashboardRepository = DietitianDashboardRepository();

  final uuidBleManager = UuidBluetoothManager();

  GlobalBlePopupManager.init(
    manager: uuidBleManager,
    navigatorKey: rootNavigatorKey,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BluetoothRepository>(
          create: (_) => BluetoothRepositoryImpl(uuidBleManager),
        ),
        RepositoryProvider<GeneratingResultRepository>(
          create: (_) => GeneratingResultRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CreateProfileCubit()),
          BlocProvider(
            create: (_) => ProfileCubit(
              calculateBMI,
              calculateBMR,
              dieticianRepository,
            ),
          ),
          BlocProvider(create: (_) => AudioCubit()),
          BlocProvider(create: (_) => TestTimerCubit()),
          BlocProvider(
            create: (_) => DietitianDashboardCubit(dietitianDashboardRepository)
              ..loadDietitianDashboard(DateTime.now()),
          ),
          BlocProvider(create: (_) => DashboardBloc()),
          BlocProvider(create: (_) => InternetCubit()),
          BlocProvider.value(value: globalErrorCubit),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
    ) async {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        primaryColor: const Color(0xFF308BF9),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF308BF9),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF252525),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF252525),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      scaffoldMessengerKey: rootMessengerKey,
      builder: (context, child) {
        return MultiBlocListener(
          listeners: [
            BlocListener<InternetCubit, bool>(
              listenWhen: (prev, curr) => prev != curr,
              listener: (context, hasInternet) {
                final messenger = rootMessengerKey.currentState;
                if (messenger == null) return;

                messenger.clearSnackBars();

                if (!hasInternet) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("No internet connection"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(days: 1),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Back online"),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            BlocListener<GlobalErrorCubit, GlobalErrorState>(
              listenWhen: (prev, curr) => prev.message != curr.message,
              listener: (context, state) async {
                final msg = state.message;
                if (msg == null) return;

                final navState = rootNavigatorKey.currentState;
                if (navState == null) return;

                final navContext = navState.overlay!.context;

                if (_isDialogShowing) return;
                _isDialogShowing = true;

                await showDialog(
                  context: navContext,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text("Device Error"),
                    content: Text(msg),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(navContext, rootNavigator: true).pop();
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );

                _isDialogShowing = false;
                globalErrorCubit.clear();
              },
            ),
          ],
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          ),
        );
      },
    );
  }
}
