import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // 🚨 REQUIRED FOR OPENING MAIL APP

// 🚨 Your app's custom responsive size helper (adjust path if necessary)
import '../../../../../core/size/get_height.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const String supportEmail = "connect@respyr.in";

  // 🚨 UPDATED: Forces external launch and catches errors if no email app exists
  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
    );

    try {
      bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No email app found. Please copy the email address."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Could not launch email app: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final poppins = GoogleFonts.poppins();
    final s = rh(context: context, px: 1); // Responsive scale

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Matched FAQ background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color(0xFF252525), size: 24 * s),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Help Center", // Matches the FAQ screen app bar title
          style: GoogleFonts.poppins(
            color: const Color(0xFF252525),
            fontSize: 15 * s,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 2 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🚨 ADDED: Large 34px header to match FAQ and General screens
              Text(
                "Support",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: 34 * s,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -2.04,
                ),
              ),
              SizedBox(height: 28 * s),

              // 🚨 PRESERVED: Header Card (Unchanged style)
              _HeaderCard(poppins: poppins),
              const SizedBox(height: 14),

              // 🚨 PRESERVED: Contact card (Unchanged style)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 18,
                      spreadRadius: 0,
                      offset: Offset(0, 10),
                      color: Color(0x11000000),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contact",
                      style: poppins.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // 🚨 WRAPPED IN GESTURE DETECTOR: Opens Mail App on tap
                        GestureDetector(
                          onTap: () => _launchEmail(
                              context), // 🚨 Updated to pass context
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 🚨 WRAPPED IN GESTURE DETECTOR: Opens Mail App on tap
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _launchEmail(
                                context), // 🚨 Updated to pass context
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: poppins.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  supportEmail,
                                  style: poppins.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: "Copy",
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: supportEmail),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Copied: $supportEmail",
                                    style: poppins.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "For support, please write to the email above.",
                      style: poppins.copyWith(
                        fontSize: 12.5,
                        height: 1.35,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // footer
              Text(
                "Respyr Support",
                textAlign: TextAlign.center,
                style: poppins.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// 🚨 PRESERVED: Header Card completely untouched to retain your exact design
class _HeaderCard extends StatelessWidget {
  final TextStyle poppins;
  const _HeaderCard({required this.poppins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF1F2937),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 22,
            offset: Offset(0, 12),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need help?",
                  style: poppins.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "We’re here to assist you. Reach out anytime.",
                  style: poppins.copyWith(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
