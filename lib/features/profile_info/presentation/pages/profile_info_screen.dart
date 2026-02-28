import 'dart:io';
// only for the cropper result type
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:respyr_dietitian/common/widgets/exist_confirmation.dart';

import 'package:respyr_dietitian/common/widgets/text_input_decoration.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_cubit.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/cubit/profile_state.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_bottom_navigation.dart';
import 'package:respyr_dietitian/features/profile_info/presentation/widgets/profile_progress_bar.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';

class ProfileInfoScreen extends StatefulWidget {
  final int stepCompleted;
  final String enteredEmail;
  final String imageUrlPath;
  final String profileName;

  const ProfileInfoScreen({
    super.key,
    required this.stepCompleted,
    this.enteredEmail = "NA",  this.imageUrlPath="NA",  this.profileName="NA",
  });

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;

    locationController.text = state.location;

    // Set email once: prefer enteredEmail if provided
    if (widget.enteredEmail != "NA" && widget.enteredEmail.isNotEmpty) {
      emailController.text = widget.enteredEmail;
    } else {
      emailController.text = state.email;
    }

    if(widget.profileName != "NA" && widget.profileName.isNotEmpty){
      nameController.text = widget.profileName;
    }else{
      nameController.text = state.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<bool> _checkPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) return false;
      }
    } else {
      if (Platform.isAndroid) {
        var photosStatus = await Permission.photos.status;
        var storageStatus = await Permission.storage.status;
        if (!photosStatus.isGranted && !storageStatus.isGranted) {
          photosStatus = await Permission.photos.request();
          storageStatus = await Permission.storage.request();
        }
        return photosStatus.isGranted || storageStatus.isGranted;
      } else if (Platform.isIOS) {
        return await Permission.photos.request().isGranted;
      }
    }
    return true;
  }

  Future<void> _pickImage(BuildContext context) async {
    final hasPermission = await _checkPermission(ImageSource.gallery);
    if (!context.mounted) return;
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission not granted.')),
      );
      return;
    }

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final imageBytes = await pickedFile.readAsBytes();

      if (!context.mounted) return;
      // Push to your cropper screen which returns Uint8List of cropped bytes
      final result = await context.push(
        AppRoutes.imageCropperScreen,
        extra: imageBytes,
      );

      if (result != null && result is Uint8List) {
        // Save cropped bytes to a temp file
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = path.join(tempDir.path, fileName);
        final savedFile = await File(filePath).writeAsBytes(result);

        context.read<ProfileCubit>().updateProfileImagePath(savedFile.path);

        if (!context.mounted) return;
        // Store only the path in cubit
        context.read<ProfileCubit>().updateProfileImagePath(savedFile.path);




      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    String? profileImagePath;



    if (widget.imageUrlPath.isNotEmpty && widget.imageUrlPath != "NA") {
      profileImagePath = widget.imageUrlPath;
    }

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {


        if (state.profileImagePath != null && state.profileImagePath!.isNotEmpty && state.profileImagePath != "NA") {
          profileImagePath = state.profileImagePath;
        }

        return WillPopScope(
          onWillPop: () async {
            return await ExitConfirmation().show(
              context,
              yes: () {
                context.go(AppRoutes.signInOptions);
              },
              no: () {
                Navigator.of(context).pop(false); // return false
              },
            );
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileProgressBar(stepCompleted: widget.stepCompleted),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SingleChildScrollView(
                        reverse: true,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: MediaQuery.of(context).viewInsets.top,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Basic Info',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF252525),
                                fontSize: 34,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 47),

                            // Avatar
                            Visibility(
                              visible: false,
                              child: Center(
                                child: SizedBox(
                                  height: 140,
                                  width: 140,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {

                                          final p = context.read<ProfileCubit>().state.profileImagePath;
                                          if (p != null && p.isNotEmpty) {
                                            context.push(AppRoutes.fullScreenImageView, extra: p);
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 65,
                                          backgroundColor: Colors.grey.shade300,
                                          backgroundImage:
                                          (profileImagePath != null &&
                                              profileImagePath!.isNotEmpty)
                                              ? FileImage(File(profileImagePath!))
                                              : null,
                                          child: (profileImagePath == null ||
                                              profileImagePath!.isEmpty)
                                              ? Text(
                                            'Upload\nPhoto',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => _pickImage(context),
                                          child: const CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.blue,
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 42),

                            // Form
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    keyboardType: TextInputType.name,
                                    cursorColor: Colors.blue,
                                    maxLength: 16,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    textCapitalization: TextCapitalization.words,
                                    buildCounter: (
                                        _,
                                        {
                                          required currentLength,
                                          required isFocused,
                                          required maxLength,
                                        }
                                        ) =>
                                    null,
                                    onChanged: (value) => context
                                        .read<ProfileCubit>()
                                        .updateName(value.trim()),
                                    validator: (value) {
                                      value = value?.trim();
                                      if (value == null || value.isEmpty) {
                                        return 'Name should not be empty';
                                      }
                                      if (value.length < 3) {
                                        return 'Name must be at least 3 characters long';
                                      }
                                      final nameExp =
                                      RegExp(r'^[a-zA-Z\s]+$');
                                      if (!nameExp.hasMatch(value)) {
                                        return 'Name cannot contain numbers or special characters';
                                      }
                                      return null;
                                    },
                                    decoration: buildInputDecoration(
                                      hintText: "Enter name",
                                      prefixIcon:
                                      "assets/images/common/profile_name_icon.svg",
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor: Colors.blue,
                                    enabled: false,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => context
                                        .read<ProfileCubit>()
                                        .updateEmail(value.trim()),
                                    validator: (value) {
                                      value = value?.trim();
                                      if (value == null || value.isEmpty) {
                                        return 'Email should not be empty';
                                      }
                                      final emailExp = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                      );
                                      if (!emailExp.hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                    decoration: buildInputDecoration(
                                      hintText: "Enter email",
                                      prefixIcon:
                                      "assets/images/common/profile_mail_icon.svg",
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: locationController,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.blue,
                                    autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                    textCapitalization:
                                    TextCapitalization.words,
                                    onChanged: (value) => context
                                        .read<ProfileCubit>()
                                        .updateLocation(value.trim()),
                                    validator: (value) {
                                      value = value?.trim();
                                      if (value == null || value.isEmpty) {
                                        return 'Location should not be empty';
                                      }
                                      return null;
                                    },
                                    decoration: buildInputDecoration(
                                      hintText: "Enter Location",
                                      prefixIcon:
                                      "assets/images/common/profile_location_icon.svg",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom navigation
            bottomNavigationBar: ProfileBottomNavigation(
              onNext: () {
                if (formKey.currentState!.validate()) {
                  final cubit = context.read<ProfileCubit>();
                  cubit.updateName(nameController.text.trim());
                  cubit.updateEmail(emailController.text.trim());
                  cubit.updateLocation(locationController.text.trim());
                  cubit.updateProfileImagePath(profileImagePath ?? "assets/images/icon/default2.png" );

                  context.push(
                    AppRoutes.genderScreen,
                    extra: widget.stepCompleted + 1,
                  );
                }
              },
              onBack: () async{

                 await ExitConfirmation().show(
                  context,
                  yes: () {
                    context.go(AppRoutes.signInOptions);
                  },
                  no: () {
                    Navigator.of(context).pop(false); // return false
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }




}
