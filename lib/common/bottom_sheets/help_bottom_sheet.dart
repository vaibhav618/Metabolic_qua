import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showHelpBottomSheet(
    BuildContext context, {
      required String supportEmail,          // e.g. "support@respyr.in"
      required String whatsappNumberE164,    // e.g. "+919876543210"
      String emailSubject = "Support request",
      String emailBody = "Hi team,\n\nI need help with ...",
      String whatsappMessage = "Hi! I need help with Respyr.",
    }) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return _HelpSheet(
        supportEmail: supportEmail,
        whatsappNumberE164: whatsappNumberE164,
        emailSubject: emailSubject,
        emailBody: emailBody,
        whatsappMessage: whatsappMessage,
      );
    },
  );
}

class _HelpSheet extends StatelessWidget {
  final String supportEmail;
  final String whatsappNumberE164;
  final String emailSubject;
  final String emailBody;
  final String whatsappMessage;

  const _HelpSheet({
    required this.supportEmail,
    required this.whatsappNumberE164,
    required this.emailSubject,
    required this.emailBody,
    required this.whatsappMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(blurRadius: 30, spreadRadius: 0, offset: Offset(0, 12), color: Color(0x1A000000)),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dragHandle(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.help_outline, size: 24),
                const SizedBox(width: 12),
                 Expanded(
                  child: Text(
                    "Need help?",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Contact our team—we usually reply within a few minutes during business hours.",
                style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF505059), height: 1.3),
              ),
            ),
            const SizedBox(height: 16),
            _ActionButton(
              label: "Mail us",
              subtitle: supportEmail,
              icon: "assets/images/icons/ic_email.svg",
              onTap: (){
                Navigator.pop(context);
                _launchEmail(context, supportEmail, subject: emailSubject, body: emailBody);
              },
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: "WhatsApp us",
              subtitle: whatsappNumberE164,
              icon: "assets/images/icons/ic_whatsapp.svg",
              iconColor: const Color(0xFF25D366),
              onTap: () {
                Navigator.pop(context); // close sheet first
                _launchWhatsApp(context, whatsappNumberE164, message: whatsappMessage);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() => Container(
    width: 42,
    height: 5,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0x22000000),
      borderRadius: BorderRadius.circular(100),
    ),
  );

  static Future<void> _launchEmail(
      BuildContext context,
      String email, {
        String subject = "",
        String body = "",
      }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _toast(context, "No email app found");
    }
  }

  static Future<void> _launchWhatsApp(
      BuildContext context,
      String phoneE164, {
        String message = "",
      }) async {



    final encoded = Uri.encodeComponent(message);

    // Native scheme
    final nativeUri = Uri.parse("whatsapp://send?phone=$phoneE164&text=$encoded");

    // Web fallback
    final webUri = Uri.parse("https://wa.me/${phoneE164.replaceAll('+', '')}?text=$encoded");

    // iOS can sometimes prefer web fallback if WA not installed
    if (await canLaunchUrl(nativeUri)) {
      await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      _toast(context, "WhatsApp not available");
    }
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final String icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E8EE)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 22, color: iconColor ?? const Color(0xFF1C1C1E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF707076))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 26, color: Color(0xFFB8BBC6)),
          ],
        ),
      ),
    );
  }
}
