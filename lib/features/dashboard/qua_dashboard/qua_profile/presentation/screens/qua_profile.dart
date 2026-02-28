import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:respyr_dietitian/features/support/presentation/screens/support.dart';

import '../../../../../../client-dashboard/data/model/client_profile_model.dart';
import '../../../../../../client-dashboard/extras/logout.dart';
import '../../../../../account_delete/presentation/screens/account_delete_webview.dart';
import '../../../../../../core/size/get_height.dart';
import '../../../bloc/qua_dashboard_bloc.dart';
import '../../../bloc/qua_dashboard_event.dart';
import '../../../bloc/qua_dashboard_state.dart';

class QuaProfile extends StatefulWidget {
  final ClientProfileModel clientProfileModel;

  const QuaProfile({
    super.key,
    required this.clientProfileModel,
  });

  @override
  State<QuaProfile> createState() => _QuaProfileState();
}

class _QuaProfileState extends State<QuaProfile> {
  static const _bg = Color(0xFFF5F7FA);
  static const _textPrimary = Color(0xFF252525);
  static const _danger = Color(0xFFDA5747);
  static const _dangerPure = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuaDashboardBloc()
        ..add(
          QuaLoadClientAndDietitian(email: widget.clientProfileModel.email),
        ),
      child: BlocConsumer<QuaDashboardBloc, QuaDashboardState>(
        listenWhen: (prev, curr) {
          final prevMsg = (prev is QuaDashboardReady) ? prev.errorMessage : null;
          final currMsg = (curr is QuaDashboardReady) ? curr.errorMessage : null;
          return currMsg != null && currMsg != prevMsg;
        },
        listener: (context, state) {
          if (state is QuaDashboardReady && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: _danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is QuaDashboardLoading) {
            return  Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                title: Text(
                  "Profile",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF252525),
                    fontSize: rh(context: context, px: 15),
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.30,
                  ),
                ),
                centerTitle: false,
              ),
              body: SafeArea(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (state is QuaDashboardError) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(rh(context: context, px: 16)),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _textPrimary,
                        fontSize: rh(context: context, px: 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is QuaDashboardReady) {
            return _buildScreen(context, state, state.client);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScreen(
      BuildContext context,
      QuaDashboardReady state,
      ClientProfileModel client,
      ) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Account",
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.30,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: rh(context: context, px: 16)),
                children: [
                  SizedBox(height: rh(context: context, px: 10)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 10),
                    ),
                    child: _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoItem(
                            label: "Name",
                            value: widget.clientProfileModel.profileName,
                          ),
                          SizedBox(height: rh(context: context, px: 28)),
                          _InfoItem(
                            label: "Gender",
                            value: widget.clientProfileModel.gender,
                          ),
                          SizedBox(height: rh(context: context, px: 28)),
                          _InfoItem(
                            label: "Age",
                            value: widget.clientProfileModel.age,
                          ),
                          SizedBox(height: rh(context: context, px: 28)),
                          _InfoItem(
                            label: "Height",
                            value: "${widget.clientProfileModel.height} cm",
                          ),
                          SizedBox(height: rh(context: context, px: 28)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  label: "Weight",
                                  value: "${state.client.weight} kg",
                                ),
                              ),
                              SizedBox(width: rh(context: context, px: 12)),
                              IconButton(
                                onPressed: () =>
                                    _showUpdateBottomSheet(context, state),
                                style: IconButton.styleFrom(
                                  backgroundColor: _textPrimary,
                                  minimumSize: Size(
                                    rh(context: context, px: 40),
                                    rh(context: context, px: 40),
                                  ),
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: rh(context: context, px: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: rh(context: context, px: 12)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rh(context: context, px: 20),
                    ),
                    child: Column(
                      children: [
                        _DeleteAccountButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeleteAccountWebView(
                                  email: client.email,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Respyr Metabolism 1.0",
              style: GoogleFonts.poppins(
                color: const Color(0xFFA0A8B2),
                fontSize: rh(context: context, px: 12),
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
            ),
            SizedBox(height: rh(context: context, px: 15)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(rh(context: context, px: 18)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delete account?",
                  style: GoogleFonts.poppins(
                    fontSize: rh(context: context, px: 16.5),
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: rh(context: context, px: 8)),
                Text(
                  "This action permanently deletes the account and data. This cannot be undone.",
                  style: GoogleFonts.poppins(
                    fontSize: rh(context: context, px: 12.5),
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: rh(context: context, px: 18)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 14),
                            ),
                          ),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB),
                            width: rh(context: context, px: 1),
                          ),
                          foregroundColor: const Color(0xFF374151),
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context: context, px: 12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: rh(context: context, px: 13.5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: rh(context: context, px: 10)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dangerPure,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              rh(context: context, px: 14),
                            ),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: rh(context: context, px: 12),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: rh(context: context, px: 13.5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateBottomSheet(BuildContext context, QuaDashboardReady state) {
    final bloc = context.read<QuaDashboardBloc>();
    final initialText = state.client.weight.trim();
    final controller = TextEditingController(text: initialText);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            return GestureDetector(
              onTap: () => FocusScope.of(sheetContext).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:
                      Radius.circular(rh(context: context, px: 20)),
                      topRight:
                      Radius.circular(rh(context: context, px: 20)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(rh(context: context, px: 20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: rh(context: context, px: 44),
                            height: rh(context: context, px: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 999),
                              ),
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 14)),
                          Text(
                            "Update weight",
                            style: GoogleFonts.poppins(
                              fontSize: rh(context: context, px: 18),
                              fontWeight: FontWeight.w500,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: rh(context: context, px: 20)),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(
                                rh(context: context, px: 10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    autofocus: false,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    style: GoogleFonts.poppins(
                                      fontSize: rh(context: context, px: 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}$'),
                                      ),
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                        rh(context: context, px: 16),
                                        vertical:
                                        rh(context: context, px: 12),
                                      ),
                                      hintText: "0.0",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: rh(context: context, px: 18),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    onChanged: (_) {
                                      if (errorText != null) {
                                        setState(() => errorText = null);
                                      }
                                    },
                                    onSubmitted: (_) =>
                                        FocusScope.of(sheetContext).unfocus(),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: rh(context: context, px: 16),
                                  ),
                                  child: Text(
                                    "Kg",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (errorText != null) ...[
                            SizedBox(height: rh(context: context, px: 8)),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                errorText!,
                                style: GoogleFonts.poppins(
                                  color: _danger,
                                  fontSize: rh(context: context, px: 12),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: rh(context: context, px: 18)),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                    side: BorderSide(
                                      color: const Color(0xFFE5E7EB),
                                      width: rh(context: context, px: 1),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context: context, px: 12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: rh(context: context, px: 10)),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF308BF9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        rh(context: context, px: 10),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: rh(context: context, px: 12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    final input = controller.text.trim();
                                    final weight = double.tryParse(input);

                                    const double minWeight = 20.0;
                                    const double maxWeight = 250.0;

                                    if (weight == null) {
                                      setState(() =>
                                      errorText = "Enter a valid number");
                                      return;
                                    }
                                    if (weight < minWeight) {
                                      setState(() => errorText =
                                      "Weight must be at least ${minWeight.toStringAsFixed(0)} kg");
                                      return;
                                    }
                                    if (weight > maxWeight) {
                                      setState(() => errorText =
                                      "Weight must be below ${maxWeight.toStringAsFixed(0)} kg");
                                      return;
                                    }

                                    bloc.add(
                                      QuaUpdateWeight(
                                        profileId: state.client.profileId,
                                        weightKg: weight,
                                        email: state.client.email,
                                      ),
                                    );

                                    Navigator.pop(sheetContext);
                                  },
                                  child: Text(
                                    "Update",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: rh(context: context, px: 8)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteAccountButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: rh(context: context, px: 52),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: BorderSide(
            color: const Color(0xFFDC2626),
            width: rh(context: context, px: 1.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rh(context: context, px: 16)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              size: rh(context: context, px: 20),
              color: const Color(0xFFDC2626),
            ),
            SizedBox(width: rh(context: context, px: 10)),
            Text(
              "Delete Account",
              style: GoogleFonts.poppins(
                fontSize: rh(context: context, px: 15.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rh(context: context, px: 15)),
        ),
        shadows: [
          BoxShadow(
            blurRadius: rh(context: context, px: 18),
            offset: Offset(
              0,
              rh(context: context, px: 10),
            ),
            color: const Color(0x11000000),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: rh(context: context, px: 30),
        horizontal: rh(context: context, px: 20),
      ),
      child: child,
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: rh(context: context, px: 15),
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.30,
          ),
        ),
        SizedBox(height: rh(context: context, px: 10)),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFF535359),
            fontSize: rh(context: context, px: 12),
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
