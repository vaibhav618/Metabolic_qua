import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/diet_plan_strategy_model.dart';

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/bluetooth_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/data/repository/generating_result_repository.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/exhale_screen_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/generating_result_params.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/domain/params/result_screen_params.dart';

import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_device_connectivity.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_breathe_tube.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_calibration_screen.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_generating_result_screen_new.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_inhale_screen_new.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_new_exhale_screen.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/pages/bluetooth_start_test_device_screen.dart';
import 'package:respyr_dietitian/features/bluetooth_device_connectivity/presentation/cubit/bluetooth_generating_result_cubit_new/bluetooth_generating_result_cubit.dart';

import 'package:respyr_dietitian/features/practice_test/practice_test_connection/presentation/screens/bluetooth_device_connectivity.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/bloc/practice_flow_bloc.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/presentation/screens/practice_test_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_home/presentation/screens/start_device_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/data/practice_test_inhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_inhale/presentation/screens/practice_test_inhale_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_full_test/presentation/data/practice_full_test_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_full_test/presentation/screens/practice_full_test_screen.dart';

import 'package:respyr_dietitian/features/profile_info/presentation/pages/age_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/dietician_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/gender_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/height_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/profile_info_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/profile_welcome_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/pages/weight_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/dietician_detail_screen.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/full_screen_image_view.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/image_cropper_screen.dart';

import 'package:respyr_dietitian/features/result_screen/presentation/pages/result_screen.dart';
import 'package:respyr_dietitian/features/select_client/presentation/screens/select_client_screen.dart';
import 'package:respyr_dietitian/features/select_client/presentation/screens/who_is_using_screen.dart';
import 'package:respyr_dietitian/features/walk_through/presentation/screen/walk_through.dart';
import 'package:respyr_dietitian/splash/splash_screen.dart';

import 'package:respyr_dietitian/features/client_login/presentation/screens/client_login_with_phone_no.dart';
import 'package:respyr_dietitian/features/client_login/presentation/screens/sign_in_options.dart';
import 'package:respyr_dietitian/features/client_login/presentation/screens/sign_in_with_email.dart';

import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/screens/qua_dashboard_screen.dart';

import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/cubit/dietitian_result_cubit.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/pages/detailed_result_screen.dart';
import 'package:respyr_dietitian/features/dietitian_result_screen/presentation/pages/overall_score_new.dart';

import 'package:respyr_dietitian/features/notification/data/bloc/notification_bloc.dart';
import 'package:respyr_dietitian/features/notification/data/repository/notification_repository.dart';
import 'package:respyr_dietitian/features/notification/presentation/screens/notification_screen.dart';

import 'package:respyr_dietitian/features/retake_test/presentation/screens/retake_test_screen.dart';
import 'package:respyr_dietitian/features/retake_test/presentation/screens/test_conditions_screen.dart';
import 'package:respyr_dietitian/features/test_result/test_history/presentation/screen/test_history_screen.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/data/practice_test_exhale_params.dart';
import 'package:respyr_dietitian/features/practice_test/practice_test_exhale/presentation/screens/practice_test_exhale_screen.dart';

import 'package:respyr_dietitian/routes/app_routes.dart';

import '../common/screens/error_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

double _toDouble(dynamic v, {double fallback = 0.0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

Map<String, dynamic>? _asMap(dynamic extra) => extra is Map<String, dynamic>
    ? extra
    : (extra is Map ? extra.cast<String, dynamic>() : null);

ClientProfileModel? _getClient(Map<String, dynamic> m, String key) {
  final c = m[key];
  return c is ClientProfileModel ? c : null;
}

DietPlanStrategyModel? _getStrategy(Map<String, dynamic> m, String key) {
  final s = m[key];
  if (s == null) return null;
  return s is DietPlanStrategyModel ? s : null;
}

Widget _errorScreen(String message) {
  return Scaffold(
    body: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      ),
    ),
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splashScreen,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.clientDashboard,
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! ClientProfileModel) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        return QuaDashboardScreen(clientProfileModel: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.profileInfoScreen,
      builder: (context, state) {
        final data = _asMap(state.extra) ?? {};
        final int stepCompleted = (data["stepCompleted"] as int?) ?? 1;
        final String enteredEmail = (data["enteredEmail"] as String?) ?? "NA";
        final String profileImage = (data["profileImage"] as String?) ?? "NA";
        final String profileName = (data["profileName"] as String?) ?? "NA";

        return ProfileInfoScreen(
          stepCompleted: stepCompleted,
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.genderScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 2;
        return GenderScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.ageScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 3;
        return AgeScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.heightScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 4;
        return HeightScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.weightScreen,
      builder: (context, state) {
        final step = state.extra as int? ?? 5;
        return WeightScreen(stepCompleted: step);
      },
    ),
    GoRoute(
      path: AppRoutes.dietitianScreen,
      builder: (context, state) {
        final data = _asMap(state.extra) ?? {};
        final String enteredEmail = (data["enteredEmail"] as String?) ?? "NA";
        final String profileImage = (data["profileImage"] as String?) ?? "NA";
        final String profileName = (data["profileName"] as String?) ?? "NA";

        return DietitianScreen(
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.dietitianDetailScreen,
      builder: (context, state) {
        final data = _asMap(state.extra) ?? {};
        final String enteredEmail = (data["enteredEmail"] as String?) ?? "NA";
        final String profileImage = (data["profileImage"] as String?) ?? "NA";
        final String profileName = (data["profileName"] as String?) ?? "NA";

        return DietitianDetailScreen(
          enteredEmail: enteredEmail,
          imageUrlPath: profileImage,
          profileName: profileName,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profileWelcomeScreen,
      builder: (context, state) => const ProfileWelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageCropperScreen,
      builder: (context, state) {
        final imageData = state.extra;
        if (imageData is! Uint8List) {
          return _errorScreen('No image data provided');
        }
        return ImageCropperScreen(imageData: imageData);
      },
    ),
    GoRoute(
      path: AppRoutes.walThroughScreen,
      builder: (context, state) => const WalkthroughScreen(),
    ),
    GoRoute(
      path: AppRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.clientLoginWithPhoneNo,
      builder: (context, state) => const ClientLoginWithPhoneNo(),
    ),
    GoRoute(
      path: AppRoutes.selectCountryCode,
      builder: (context, state) => const SelectCountryCode(),
    ),
    GoRoute(
      path: AppRoutes.signInOptions,
      builder: (context, state) => const SignInOptions(),
    ),
    GoRoute(
      path: AppRoutes.signInWithEmail,
      builder: (context, state) => const SignInWithEmail(),
    ),
    GoRoute(
      path: AppRoutes.bluetoothDeviceConnectivity,
      builder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) return _errorScreen('Missing or invalid params.');

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = _toDouble(m['min_range']);
        final maxRange = _toDouble(m['max_range']);
        final isTestTaken = (m['is_test_taken'] as bool?) ?? false;

        if (client == null) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        if (m['strategy'] != null && strategy == null) {
          return _errorScreen('Missing or invalid diet plan strategy data.');
        }

        return BluetoothDeviceConnectivity(
          clientProfileModel: client,
          dietPlanStrategyModel: strategy!,
          minRange: minRange,
          maxRange: maxRange,
          isTestTaken: isTestTaken,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothDeviceStartTest,
      builder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) return _errorScreen('Missing or invalid params.');

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = _toDouble(m['min_range']);
        final maxRange = _toDouble(m['max_range']);
        final isTestTaken = (m['is_test_taken'] as bool?) ?? false;

        if (client == null) {
          return _errorScreen('Missing or invalid client profile data.');
        }
        if (m['strategy'] != null && strategy == null) {
          return _errorScreen('Missing or invalid diet plan strategy data.');
        }

        return StartDeviceTestScreen(
          clientProfileModel: client,
          dietPlanStrategyModel: strategy!,
          minRange: minRange,
          maxRange: maxRange,
          isTakenTest: isTestTaken,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothBreatheTube,
      pageBuilder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null)
          return NoTransitionPage(
              child: _errorScreen('Missing or invalid params.'));

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = _toDouble(m['min_range']);
        final maxRange = _toDouble(m['max_range']);

        if (client == null)
          return NoTransitionPage(
              child: _errorScreen('Missing or invalid client profile data.'));
        if (m['strategy'] != null && strategy == null) {
          return NoTransitionPage(
              child:
                  _errorScreen('Missing or invalid diet plan strategy data.'));
        }

        return NoTransitionPage(
          child: BluetoothBreatheTube(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy!,
            minRange: minRange,
            maxRange: maxRange,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothCalibrationScreen,
      pageBuilder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null)
          return NoTransitionPage(
              child: _errorScreen('Missing or invalid params.'));

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = _toDouble(m['min_range']);
        final maxRange = _toDouble(m['max_range']);

        if (client == null)
          return NoTransitionPage(
              child: _errorScreen('Missing or invalid client profile data.'));
        if (m['strategy'] != null && strategy == null) {
          return NoTransitionPage(
              child:
                  _errorScreen('Missing or invalid diet plan strategy data.'));
        }

        return NoTransitionPage(
          child: BluetoothCalibrationScreen(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy!,
            minRange: minRange,
            maxRange: maxRange,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothInhaleScreen,
      pageBuilder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) {
          return const NoTransitionPage(
            child: Scaffold(
                body: Center(child: Text('Missing or invalid params.'))),
          );
        }

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = _toDouble(m['min_range']);
        final maxRange = _toDouble(m['max_range']);
        final breathSettings = m['breath_settings'];

        if (client == null) {
          return const NoTransitionPage(
            child: Scaffold(
                body: Center(
                    child: Text('Missing or invalid client profile data.'))),
          );
        }

        if (m['strategy'] != null && strategy == null) {
          return const NoTransitionPage(
            child: Scaffold(
                body: Center(
                    child:
                        Text('Missing or invalid diet plan strategy data.'))),
          );
        }

        return NoTransitionPage(
          child: BluetoothInhaleScreenNew(
            clientProfileModel: client,
            dietPlanStrategyModel: strategy!,
            minRange: minRange,
            maxRange: maxRange,
            breathingSettings: breathSettings,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothExhaleScreen,
      pageBuilder: (context, state) {
        final extra = state.extra;
        ExhaleScreenParams? params;

        if (extra is ExhaleScreenParams) {
          params = extra;
        } else {
          final m = _asMap(extra);
          if (m == null)
            return NoTransitionPage(
                child:
                    _errorScreen('Missing or invalid navigation parameters.'));

          try {
            final client = m['clientProfileModel'];
            final dietPlan = m['dietPlanStrategyModel'];
            final breathSettings = m['breathSettings'];

            if (client is! ClientProfileModel) {
              return NoTransitionPage(
                  child:
                      _errorScreen('Missing or invalid client profile data.'));
            }
            if (dietPlan is! DietPlanStrategyModel) {
              return NoTransitionPage(
                  child: _errorScreen(
                      'Missing or invalid diet plan strategy data.'));
            }

            final baseValue = (m['baseValue'] ?? '').toString();
            final minRange = _toDouble(m['min_range']);
            final maxRange = _toDouble(m['max_range']);

            params = ExhaleScreenParams(
              clientProfileModel: client,
              baseValue: baseValue,
              dietPlanStrategyModel: dietPlan,
              minRange: minRange,
              maxRange: maxRange,
              breathingSettings: breathSettings,
            );
          } catch (e) {
            return NoTransitionPage(
                child: _errorScreen('Invalid navigation map: $e'));
          }
        }

        return NoTransitionPage(
          child: BluetoothNewExhaleScreen(
            clientProfileModel: params.clientProfileModel,
            baseValue: params.baseValue,
            dietPlanStrategyModel: params.dietPlanStrategyModel,
            minRange: params.minRange,
            maxRange: params.maxRange,
            breathingSettings: params.breathingSettings,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.bluetoothGeneratingResultScreen,
      builder: (context, state) {
        final params = state.extra as GeneratingResultParams;

        return BlocProvider(
          create: (context) => BluetoothGeneratingResultCubit(
            repo: context.read<BluetoothRepository>(),
            repository: context.read<GeneratingResultRepository>(),
            maxPressure: params.maxPressure,
            bestPressure: params.bestPressure,
            blowDuration: params.blowDuration,
            blowValuesList: params.blowValuesList,
            clientProfileModel: params.clientProfileModel,
            dietPlanStrategyModel: params.dietPlanStrategyModel,
            minRange: params.minRange,
            maxRange: params.maxRange,
          ),
          child: BluetoothGeneratingResultScreen(
            maxPressure: params.maxPressure,
            bestPressure: params.bestPressure,
            blowDuration: params.blowDuration,
            blowValuesList: params.blowValuesList,
            clientProfileModel: params.clientProfileModel,
            dietPlanStrategyModel: params.dietPlanStrategyModel,
            minRange: params.minRange,
            maxRange: params.maxRange,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.dietitianResultScreen,
      builder: (context, state) {
        final params = state.extra as ResultScreenParamsNew;
        return BlocProvider(
          create: (_) => DietitianResultCubit(),
          child: OverallScoreNew(
            testResultResponse: params.result,
            clientProfileModel: params.clientProfileModel,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.overallResultScreen,
      builder: (context, state) {
        final params = state.extra as ResultScreenParamsNew;
        return BlocProvider(
          create: (_) => DietitianResultCubit(),
          child: DetailedResultScreen(
            testResultResponse: params.result,
            clientProfileModel: params.clientProfileModel,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.fullScreenImageView,
      pageBuilder: (context, state) {
        final imagePath = state.extra as String?;
        return CustomTransitionPage(
          opaque: false,
          barrierColor: Colors.black.withAlpha(40),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: FullScreenImageView(imagePath: imagePath),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resultScreen,
      builder: (context, state) {
        final client = state.extra as ClientProfileModel;
        return ResultScreen(clientProfileModel: client);
      },
    ),
    GoRoute(
      path: AppRoutes.notificationScreen,
      builder: (context, state) {
        final client = state.extra as ClientProfileModel;

        return BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(repository: NotificationRepository()),
          child: NotificationScreen(clientProfileModel: client),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.completeTestHistory,
      builder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) {
          return ErrorScreen(errorMessage: 'Missing route arguments');
        }

        final client = m['client'];
        final plan = m['plan'];

        return TestHistoryScreen(
          clientProfileModel: client,
          dietPlanStrategyModel: plan,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.testConditionScreen,
      builder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) {
          return ErrorScreen(
              errorMessage: 'Missing or invalid route arguments');
        }

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = m['min_range'];
        final maxRange = m['max_range'];

        if (client == null) {
          return ErrorScreen(
              errorMessage: 'ClientProfileModel is missing or invalid');
        }
        if (strategy == null) {
          return ErrorScreen(
              errorMessage: 'DietPlanStrategyModel is missing or invalid');
        }
        if (minRange is! double || maxRange is! double) {
          return ErrorScreen(
              errorMessage: 'Range values are missing or invalid');
        }

        return TestConditionsScreen(
          clientProfileModel: client,
          dietPlanStrategyModel: strategy,
          minRange: minRange,
          maxRange: maxRange,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.retakeTestScreen,
      builder: (context, state) {
        final m = _asMap(state.extra);
        if (m == null) {
          return ErrorScreen(
              errorMessage: 'Missing or invalid route arguments');
        }

        final client = _getClient(m, 'client');
        final strategy = _getStrategy(m, 'strategy');

        final minRange = m['min_range'];
        final maxRange = m['max_range'];

        if (client == null) {
          return ErrorScreen(
              errorMessage: 'ClientProfileModel is missing or invalid');
        }
        if (strategy == null) {
          return ErrorScreen(
              errorMessage: 'DietPlanStrategyModel is missing or invalid');
        }
        if (minRange is! double || maxRange is! double) {
          return ErrorScreen(
              errorMessage: 'Range values are missing or invalid');
        }

        return RetakeTestScreen(
          clientProfileModel: client,
          dietPlanStrategyModel: strategy,
          minRange: minRange,
          maxRange: maxRange,
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (ctx) =>
              PracticeFlowBloc(repo: ctx.read<BluetoothRepository>())
                ..add(const PracticeFlowInit()),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.practiceFlowShell,
          builder: (context, state) {
            final extra = state.extra;

            // Check if extra is a Params object instead of a Model
            if (extra is PracticeTestInhaleParams) {
              return PracticeTestScreen(
                  clientProfileModel: extra.clientProfileModel);
            } else if (extra is PracticeTestExhaleParams) {
              return PracticeTestScreen(
                  clientProfileModel: extra.clientProfileModel);
            } else if (extra is ClientProfileModel) {
              return PracticeTestScreen(clientProfileModel: extra);
            }

            return _errorScreen('Missing profile data');
          },
          routes: [
            GoRoute(
              path: AppRoutes.startDeviceScreen,
              builder: (context, state) {
                final client = state.extra as ClientProfileModel;
                return StartDeviceScreen(clientProfileModel: client);
              },
            ),
            GoRoute(
              path: AppRoutes.practiceTestConnectivity,
              builder: (context, state) {
                final client = state.extra as ClientProfileModel;
                return PracticeTestBluetoothDeviceConnectivity(
                    clientProfileModel: client);
              },
            ),
            GoRoute(
              path: AppRoutes.practiceTestInhaleScreen,
              builder: (context, state) {
                final params = state.extra as PracticeTestInhaleParams;
                return PracticeTestInhaleScreen(
                    practiceTestInhaleParams: params);
              },
            ),
            GoRoute(
              path: AppRoutes.practiceTestExhaleScreen,
              builder: (context, state) {
                // Cast the extra argument to the Exhale params model
                final params = state.extra as PracticeTestExhaleParams;
                return PracticeTestExhaleScreen(
                    practiceTestExhaleParams: params);
              },
            ),
            GoRoute(
              path: AppRoutes.practiceFullTestScreen,
              builder: (context, state) {
                // We pass the params class we created earlier as the 'extra'
                final params = state.extra as PracticeFullTestParams;
                return PracticeFullTestScreen(practiceFullTestParams: params);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.selectClient,
      builder: (context, state) => const SelectClientScreen(),
    ),
    GoRoute(
      path: AppRoutes.whoIsUsing,
      builder: (context, state) => const WhoIsUsingScreen(),
    ),
  ],
);
