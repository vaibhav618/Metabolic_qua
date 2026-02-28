
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/core/utils/validators.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class DietitianScreen extends StatefulWidget {
  final String enteredEmail;
  final String imageUrlPath;
  final String profileName;

  const DietitianScreen({super.key,  this.enteredEmail="NA",  this.imageUrlPath="NA",  this.profileName="NA"});

  @override
  State<DietitianScreen> createState() => _DietitianScreenState();
}

class _DietitianScreenState extends State<DietitianScreen> {
  final TextEditingController dietitianController = TextEditingController();
  String? errorText;
  final FocusNode _dietitianFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_dietitianFocusNode);
    });
  }

  @override
  void dispose() {
    dietitianController.dispose();
    _dietitianFocusNode.dispose();
    super.dispose();
  }

  void _validateAndProceed(ProfileState state) async {
    final cubit = context.read<ProfileCubit>();
    final input = dietitianController.text.trim();

    final error = Validators.validateDieticianId(input);
    setState(() => errorText = error);

    if (error != null) return;

    // Fetch asynchronously
    await cubit.fetchDietitianName(input);

    // ✅ Check if widget is still mounted
    if (!mounted) return;

    final updatedState = context.read<ProfileCubit>().state;

    // Show error if not found or failed
    if (updatedState.dietitianId == 'NotFound' ||
        updatedState.dietitianName == 'Error' ||
        updatedState.dietitianImageUrl.trim().isEmpty) {
      setState(() {
        errorText = "Dietitian not found";
      });
      return;
    }

    cubit.updateDietitian(input);

    context.push(AppRoutes.dietitianDetailScreen ,extra: {
    "stepCompleted": 1,
    "enteredEmail": widget.enteredEmail,
    "profileImage": widget.imageUrlPath,
    "profileName":  widget.profileName,
    },);
  }

  bool _validateInput(ProfileState state) {
    final input = dietitianController.text.trim();
    final error = Validators.validateDieticianId(input);
    setState(() => errorText = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final noBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset("assets/images/icons/ic_logo_blue.svg"),
                                Visibility(

                                  child: InkWell(
                                    onTap: (){
                                      context.push(AppRoutes.profileInfoScreen, extra: {
                                        "stepCompleted": 1,
                                        "enteredEmail": widget.enteredEmail,
                                        "profileImage": widget.imageUrlPath,
                                        "profileName":  widget.profileName,
                                      },);
                                    },
                                    child: Text("Skip",
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF252525),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.10,
                                        letterSpacing: 0.30,
                                      ),
                                    ),
                                  ),
                                  visible: false,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Text(
                              'Your Dietitian ID?',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 34,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -2.04,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                errorText != null
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: TextFormField(
                              focusNode: _dietitianFocusNode,
                              controller: dietitianController,

                              autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                              maxLength: 9,
                              decoration: InputDecoration(
                                hintText: "Enter your dietitian ID",
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF535359),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  height: 1.10,
                                  letterSpacing: -0.30,
                                ),
                                counterText: "",
                                border: noBorder,
                                enabledBorder: noBorder,
                                disabledBorder: noBorder,
                                focusedBorder: noBorder,
                              ),
                              onChanged: (value) {
                                final trimmed = value.trim();
                                _validateInput(state);

                                final cubit = context.read<ProfileCubit>();

                                if (trimmed.isEmpty || trimmed.length <= 7) {
                                  cubit.clearDieticianName();
                                  return;
                                }
                              },
                            ),
                          ),
                          if (errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 10,
                              ),
                              child: Text(
                                errorText!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                          Spacer(),

                          SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: ProfileBottomNavigation(
            onBack: (){

              print("clicked");
              context.go(AppRoutes.signInOptions);
            },
            onNext: (){


                      FocusScope.of(context).unfocus();
                      _validateAndProceed(context.read<ProfileCubit>().state);
            },
          ),
        ),
        // bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
        //   builder: (context, state) {
        //     return ProfileBottomNavigation(
        //       onBack: () {
        //         context.pop();
        //       },
        //       onNext: () {
        //         FocusScope.of(context).unfocus();
        //         _validateAndProceed(context.read<ProfileCubit>().state);
        //       },
        //       nextLabel: "Finished Up",
        //     );
        //   },
        // ),
      ),
    );
  }
}