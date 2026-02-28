import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/common/widgets/loading_widget.dart';
import 'package:respyr_dietitian/fcm-manager/fcm_token_service.dart';
import '../../../features/profile_info/data/repository/dietician_repository.dart';
import '../../../features/profile_info/data/model/dietician_detail_model.dart';
import '../../data/model/client_profile_model.dart';
import '../../data/bloc/client_bloc.dart';
import '../../data/bloc/client_event.dart';
import '../../data/bloc/client_state.dart';
import '../../data/repository/client_repository.dart';
import 'client_with_dietitian_screen.dart';



class ClientDashboard extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const ClientDashboard({super.key, required this.clientProfileModel});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard>
    with WidgetsBindingObserver {
  final _dietitianRepo = DietitianRepository();
  final _clientRepo = ClientRepository();

  late final ClientBloc _clientBloc;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clientBloc = ClientBloc(_clientRepo);
    _fetchData();

  }

  @override
  void dispose() {
    _clientBloc.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  void didPopNext() {
    _fetchData();
  }

  void _fetchData() {
    _clientBloc.add(FetchClientProfile(
      profileId: widget.clientProfileModel.profileId,
    ));
  }

  @override
  Widget build(BuildContext context) {





    return BlocProvider.value(
      value: _clientBloc,
      child: BlocListener<ClientBloc, ClientState>(
        listener: (context, state) async {
          if (state is ClientLoaded) {
            _isFirstLoad = false;
            final client = state.client;
            await FCMService.saveTokenToServer(client.profileId);
          }
        },
        child: BlocBuilder<ClientBloc, ClientState>(
          builder: (context, state) {
            if ((state is ClientLoading && _isFirstLoad) || state is ClientInitial) {
              return const Scaffold(backgroundColor: Colors.white, body: LoadingWidget(loadingMessage: ""),);
            }

            if (state is ClientError) {
              return Scaffold(
                body: Center(
                  child: Text(state.message),
                ),
              );
            }

            if (state is ClientLoaded) {
              final client = state.client;

              if (client.dietitianId == "NA") {
                // return GiftingDashboard(
                //   clientProfileModel: widget.clientProfileModel,
                // );
              }

              return FutureBuilder<DietitianDetailModel?>(
                future: _dietitianRepo.fetchDietitian(client.dietitianId),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Scaffold(
                      backgroundColor: Colors.white,
                      body: LoadingWidget(loadingMessage: ''),
                    );
                  }

                  if (snap.hasError || snap.data == null) {



                    print(snap.error );



                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(child: Text("Dietitian not found",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1A1),
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          height: 1.10,
                          letterSpacing: -1,
                        ),
                      )),
                    );
                  }

                  final dietitian = snap.data!;
                  return ClientWithDietitianScreen(
                    clientProfileModel: client,
                    dietitianModel: dietitian,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
