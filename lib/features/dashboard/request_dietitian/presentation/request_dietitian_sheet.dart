import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/client-dashboard/data/model/client_profile_model.dart';

import '../../../../common/widgets/text_input_decoration.dart';
import '../bloc/dietitian_link_bloc.dart';
import '../bloc/dietitian_link_event.dart';
import '../bloc/dietitian_link_state.dart';

// Function to call the bottom sheet
void showDietitianRequestSheet({
  required BuildContext context,
  required ClientProfileModel clientProfile,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return BlocProvider<DietitianLinkBloc>(
        create: (_) => DietitianLinkBloc(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: RequestDietitianSheet(
            clientProfileModel: clientProfile,
          ),
        ),
      );
    },
  );
}

class RequestDietitianSheet extends StatefulWidget {
  final ClientProfileModel clientProfileModel;
  const RequestDietitianSheet({super.key, required this.clientProfileModel});

  @override
  State<RequestDietitianSheet> createState() => _RequestDietitianSheetState();
}

class _RequestDietitianSheetState extends State<RequestDietitianSheet> {
  final TextEditingController dietitianIdController = TextEditingController();

  @override
  void dispose() {
    dietitianIdController.dispose();
    super.dispose();
  }

  void _closeSheet() {
    Navigator.of(context).pop();
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
        final String buttonText =
        hasDietitian ? "Confirm Link" : "Continue";

        // Dynamic title
        final String titleText =
        hasDietitian ? "Is your consultant ?" : "Reference Code";

        return Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                      onPressed: _closeSheet,
                      icon: const Icon(Icons.close, size: 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                      ),
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 30,
                    ),
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
                        Visibility(
                          visible: !hasDietitian,
                          child: TextFormField(
                            controller: dietitianIdController,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.blue,
                            maxLength: 16,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            textCapitalization: TextCapitalization.characters,
                            // ❗ Disable editing when dietitian is already found
                            enabled: !isLookupLoading &&
                                !isLinkLoading &&
                                !hasDietitian,
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
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Dietitian preview card (after lookup success)
                        if (hasDietitian) ...[
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dietitian Found",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Name: ${dietitian.name}"),
                                  const SizedBox(height: 4),
                                  Text("ID: ${dietitian.dietitianId}"),
                                  const SizedBox(height: 4),
                                  Text("Phone: ${dietitian.phoneNo}"),
                                  const SizedBox(height: 4),
                                  Text("Email: ${dietitian.email}"),
                                  const SizedBox(height: 4),
                                  Text("Location: ${dietitian.location}"),
                                  const SizedBox(height: 4),
                                  Text("Clinic: ${dietitian.clinicName}"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        /// Messages
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

                        const SizedBox(height: 180),

                        /// Previous step button (only when dietitian found)




                        Row(
                          children: [
                            if (hasDietitian) ...[
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: isSubmitting
                                      ? null
                                      : () {
                                    context
                                        .read<DietitianLinkBloc>()
                                        .add(ResetDietitianLinkFlow());
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Previous step",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Spacer(),


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
                            ]
                            ,
                            if(hasDietitian) ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
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
                                      dietitianId:
                                      dietitian.dietitianId,
                                    ));
                                  },
                                
                                
                                
                                
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF308BF9),
                                  ), child: Row(
                                  children: [
                                    Text("Send Request"),
                                    Icon( Icons.chevron_right)
                                  ],
                                
                                ),
                                ),
                              ),
                            ]

                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
