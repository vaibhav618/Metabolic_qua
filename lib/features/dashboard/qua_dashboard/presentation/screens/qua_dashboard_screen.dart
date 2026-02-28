import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';

import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard/presentation/widgets/loading_screen.dart';
import 'package:respyr_dietitian/features/dashboard/qua_dashboard/presentation/screens/qua_dashboard.dart';

import '../../../../../client_login_manager/client_login_manager.dart';
import '../../../../../core/appupdate/ios_update.dart';
import '../../../../../fcm-manager/fcm_token_service.dart';
import '../../../../../routes/app_routes.dart';

import '../../bloc/qua_dashboard_bloc.dart';
import '../../bloc/qua_dashboard_event.dart';
import '../../bloc/qua_dashboard_state.dart';

import '../../target/bloc/metabolism_target_bloc.dart';
import '../../target/bloc/metabolism_target_event.dart';
import '../../target/bloc/metabolism_target_state.dart';
import '../../target/data/repository/metabolism_target_repository.dart';
import '../../target/data/services/metabolism_target_service.dart';

import 'error_screen.dart';

class QuaDashboardScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const QuaDashboardScreen({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<QuaDashboardScreen> createState() => _QuaDashboardScreenState();
}

class _QuaDashboardScreenState extends State<QuaDashboardScreen> {
  bool _logoutHandled = false;
  bool _checkedUpdateOnce = false;
  bool _updating = false;

  void _fetchTarget(BuildContext context) {
    context.read<MetabolismTargetBloc>().add(
      FetchMetabolismTarget(
        age: int.tryParse(widget.clientProfileModel.age) ?? 0,
        gender: widget.clientProfileModel.gender,
        heightCm: double.tryParse(widget.clientProfileModel.height) ?? 0.0,
        currentWeight: double.tryParse(widget.clientProfileModel.weight) ?? 0.0,
        diabetic: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FCMService.saveTokenToServer(widget.clientProfileModel.profileId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    if (_checkedUpdateOnce) return;
    _checkedUpdateOnce = true;

    if (Platform.isAndroid) {
      await _checkAndroidInAppUpdate();
    } else if (Platform.isIOS) {
      await checkIosUpdate(context);
    }
  }

  Future<void> _checkAndroidInAppUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      final available =
          info.updateAvailability == UpdateAvailability.updateAvailable;

      if (!available) return;

      if (!mounted) return;
      setState(() => _updating = true);

      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {} finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updating) {
      return const LoadingScreen();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuaDashboardBloc()
            ..add(
              QuaLoadClientAndDietitian(
                email: widget.clientProfileModel.email,
              ),
            ),
        ),
        BlocProvider(
          create: (_) {
            final targetService = MetabolismTargetService();
            final repo = MetabolismTargetRepository(targetService);
            final bloc = MetabolismTargetBloc(repo: repo);

            bloc.add(
              FetchMetabolismTarget(
                age: int.tryParse(widget.clientProfileModel.age) ?? 0,
                gender: widget.clientProfileModel.gender,
                heightCm: double.tryParse(widget.clientProfileModel.height) ?? 0.0,
                currentWeight:
                double.tryParse(widget.clientProfileModel.weight) ?? 0.0,
                diabetic: false,
              ),
            );

            return bloc;
          },
        ),
      ],
      child: BlocConsumer<QuaDashboardBloc, QuaDashboardState>(
        listener: (context, state) async {
          if (state is QuaDashboardError) {
            final msg = state.message;
            final isProfileNotFound = msg.contains("Profile not found");

            if (isProfileNotFound && !_logoutHandled) {
              _logoutHandled = true;

              try {
                final googleSignIn = GoogleSignIn();
                final signedIn = await googleSignIn.isSignedIn();
                if (signedIn) {
                  await googleSignIn.signOut();
                }
                await ClientLoginManager().clearClientProfile();
              } catch (_) {}

              if (!context.mounted) return;
              GoRouter.of(context).go(AppRoutes.signInOptions);
            }
          }
        },
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return const LoadingScreen();
          }

          if (state is QuaDashboardError) {
            if (state.message.contains("Profile not found")) {
              return const LoadingScreen();
            }

            return ErrorScreen(
              state: state,
              retryButtonClicked: () {
                context.read<QuaDashboardBloc>().add(
                  QuaRefreshClientAndDietitian(
                    email: widget.clientProfileModel.email,
                  ),
                );
                _fetchTarget(context);
              },
            );
          }

          if (state is QuaDashboardReady) {
            double minRange = 0.0;
            double maxRange = 0.0;

            final targetState =
                context.watch<MetabolismTargetBloc>().state;
            if (targetState is MetabolismTargetLoaded) {
              final rangeStr = targetState.data.targetScores[
              "target_fat_loss_metabolism_score %"] ??
                  "";
              final parsed = extractRange(rangeStr);
              if (parsed.length >= 2) {
                minRange = parsed[0];
                maxRange = parsed[1];
              }
            }

            return QuaDashboard(
              clientProfile: state.client,
              dietitianDetailModel: state.dietitian,
              currentMinRange: minRange,
              currentMaxRange: maxRange,
            );
          }

          return const LoadingScreen();
        },
      ),
    );
  }

  List<double> extractRange(String value) {
    final regex = RegExp(r'([\d.]+)');
    final matches = regex.allMatches(value);
    if (matches.length < 2) return [];
    return [
      double.tryParse(matches.elementAt(0).group(0)!) ?? 0.0,
      double.tryParse(matches.elementAt(1).group(0)!) ?? 0.0,
    ];
  }
}
