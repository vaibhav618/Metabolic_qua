import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';
import 'package:respyr_dietitian/features/dashboard/request_dietitian/bloc/dietitian_link_bloc.dart';
import 'package:respyr_dietitian/features/dashboard/request_dietitian/bloc/dietitian_link_state.dart';

import '../../../../common/widgets/text_input_decoration.dart';
import '../bloc/dietitian_link_event.dart';

class SelectDietitianScreen extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const SelectDietitianScreen({super.key, required this.clientProfileModel});

  @override
  State<SelectDietitianScreen> createState() => _SelectDietitianScreenState();
}

class _SelectDietitianScreenState extends State<SelectDietitianScreen> {
  final TextEditingController dietitianIdController = TextEditingController();

  @override
  void dispose() {
    dietitianIdController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DietitianLinkBloc, DietitianLinkState>(
      builder: (context, state) {
        final isLookupLoading = state.isLookupLoading;
        final isLinkLoading = state.isLinkLoading;
        final dietitian = state.dietitian;
        final errorMessage = state.errorMessage;
        final successMessage = state.successMessage;

        final bool hasDietitian = dietitian != null;

        // If dietitian found, reflect its ID in the text field once
        if (hasDietitian &&
            dietitianIdController.text.trim().isEmpty) {
          dietitianIdController.text = dietitian.dietitianId;
        }

        // Button label & loading state
        final bool isSubmitting = isLookupLoading || isLinkLoading;
        final String _ =
        hasDietitian ? "Confirm Link" : "Continue";

        // Dynamic title
        final String titleText =
        hasDietitian ? "Is this your\nconsultant??" : "Reference Code";

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    titleText,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -2.04,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if(!hasDietitian)...[
                    TextFormField(
                      controller: dietitianIdController,
                      keyboardType: TextInputType.name,
                      cursorColor: Colors.blue,
                      maxLength: 16,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.characters,
                      enabled: !isLookupLoading && !isLinkLoading && !hasDietitian,
                      buildCounter: (
                          _,
                          {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }
                          ) =>
                      null,
                      decoration: buildInputDecoration(
                        hintText: "Enter Dietician reference code",
                      ),
                    )
                  ],

                  if (hasDietitian) ...[


                    Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F7FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Row(
                        spacing: 15,
                        children: [
                          Image.network(dietitian.logoUrl, cacheHeight: 120, cacheWidth: 120,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [


                                Text(dietitian.name,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF252525),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.30,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text("Dietitian @ ${dietitian.clinicName}",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                                SizedBox(height: 5,),

                                Text(dietitian.email,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,

                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(dietitian.phoneNo,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,

                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(dietitian.location,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF535359),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.24,

                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (successMessage != null) ...[
                    Text(
                      successMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],





                ],
              ),
            ),
          ),


          bottomNavigationBar:  SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (isSubmitting) return; // when loading do nothing

                      if (hasDietitian) {
                        // Case 1: Dietitian found → go back to reference-code step
                        context.read<DietitianLinkBloc>().add(ResetDietitianLinkFlow());
                      } else {
                        // Case 2: Dietitian NOT found → go back to previous screen
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_left_outlined,
                      color: Color(0xFF535359),
                    ),
                  ),


                  if(!hasDietitian) ...[
                    IconButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                          final code = dietitianIdController.text
                              .trim()
                              .toString();
                          if (!hasDietitian) {
                            /// Step 1: Fetch dietitian by code
                            context
                                .read<DietitianLinkBloc>()
                                .add(FetchDietitianByCode(code));
                          } else {
                            /// Step 2: Confirm link
                            context
                                .read<DietitianLinkBloc>()
                                .add(ConfirmDietitianLink(
                              profileId: widget
                                  .clientProfileModel.profileId
                                  .toString(),
                              dietitianId:
                              dietitian.dietitianId,
                            ));
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF308BF9),
                        ),
                        icon: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.white,size: 24,)
                    ),
                  ],


                  if(hasDietitian)...[
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {

                        /// Step 2: Confirm link
                        context
                            .read<DietitianLinkBloc>()
                            .add(ConfirmDietitianLink(
                          profileId: widget
                              .clientProfileModel.profileId
                              .toString(),
                          dietitianId: "dietitian.dietitianId",
                        ));
                      },


                      style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF308BF9),
                          elevation: 0
                      ), child: Row(
                      children: [
                        Text("Send Request",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                            letterSpacing: 0.30,
                          ),
                        ),
                        Icon( Icons.chevron_right,color: Colors.white,)
                      ],

                    ),
                    ),
                  ]


                ],
              ),
            ),
          ),


        );
      },
    );
  }
}
