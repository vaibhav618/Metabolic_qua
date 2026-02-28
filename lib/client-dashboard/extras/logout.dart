import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // ✅ cache clear
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../client_login_manager/client_login_manager.dart';
import '../../routes/app_routes.dart';

class Logout {
  Future<void> show(
      BuildContext context, {
        required void Function(bool) isLoggingOut,
      }) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _ConfirmCard(
          title: 'Confirm Logout',
          message: 'Are you sure you want to logout?',
          cancelText: 'Cancel',
          confirmText: 'Logout',
          onCancel: () => Navigator.pop(ctx, false),
          onConfirm: () => Navigator.pop(ctx, true),
        ),
      ),
    );

    if (confirm != true) return;

    isLoggingOut(true);
    bool isCleared = false;

    try {
      debugPrint("🍏 Logout: Start logging out...");

      // ✅ Google Sign-Out (if signed in)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final bool signedIn = await googleSignIn.isSignedIn();
      if (signedIn) {
        debugPrint("🍏 Logout: Google Sign-in found, signing out...");
        await googleSignIn.signOut();
        debugPrint("🍏 Logout: Google Sign-in signed out.");
      } else {
        debugPrint("🍏 Logout: Google Sign-in not found.");
      }

      // ✅ Clear Flutter image MEMORY cache
      debugPrint("🧹 Logout: Clearing Flutter image memory cache...");
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // ✅ Clear DISK cache (cached_network_image / flutter_cache_manager)
      debugPrint("🧹 Logout: Clearing disk cache...");
      await DefaultCacheManager().emptyCache();

      // ✅ Clear your app session/profile storage
      isCleared = await ClientLoginManager().clearClientProfile();
      debugPrint("🍏 Logout: Profile cleared status: $isCleared");
    } catch (e) {
      isCleared = false;
      debugPrint("🍏 Logout: Error occurred during logout -> $e");
    } finally {
      isLoggingOut(false);
    }

    if (!context.mounted) return;

    if (isCleared) {
      debugPrint("🍏 Logout: Successful logout, navigating to Sign In Options.");
      context.go(AppRoutes.signInOptions);
    } else {
      debugPrint("🍏 Logout: Logout failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to logout. Please try again.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// A reusable custom "container" dialog card
class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onConfirm,
    this.cancelText = 'Cancel',
    this.confirmText = 'OK',
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            offset: Offset(0, 12),
            color: Color(0x1A000000),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFF4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.logout, color: Color(0xFF2F80ED)),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.24,
              letterSpacing: -0.34,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: const Color(0xFF252525),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.26,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    cancelText,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    confirmText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
