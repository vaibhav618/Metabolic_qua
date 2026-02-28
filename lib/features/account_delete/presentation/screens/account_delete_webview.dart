import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // ✅ add
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:respyr_dietitian/client_login_manager/client_login_manager.dart';
import 'package:respyr_dietitian/routes/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DeleteAccountWebView extends StatefulWidget {
  final String email;
  const DeleteAccountWebView({super.key, required this.email});

  @override
  State<DeleteAccountWebView> createState() => _DeleteAccountWebViewState();
}

class _DeleteAccountWebViewState extends State<DeleteAccountWebView> {
  late final WebViewController controller;

  bool _isPageLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    // ✅ Properly encode email in URL
    final uri = Uri.parse("https://humorstech.com/metabolism/account/delete/")
        .replace(queryParameters: {"email": widget.email});

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)

    // 🔥 Track loading + progress + fix scaling
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isPageLoading = true;
              _progress = 0;
            });
          },
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _progress = p);
          },
          onPageFinished: (_) async {
            // ✅ prevent zoom / fix viewport
            try {
              await controller.runJavaScript('''
                (function() {
                  var existing = document.querySelector('meta[name="viewport"]');
                  if (existing) existing.remove();
                  var meta = document.createElement('meta');
                  meta.name = 'viewport';
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                  document.getElementsByTagName('head')[0].appendChild(meta);
                })();
              ''');
            } catch (_) {}

            if (!mounted) return;
            setState(() {
              _isPageLoading = false;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _isPageLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to load page: ${error.description}"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      )

    // ✅ Message from Web page
      ..addJavaScriptChannel(
        'AccountDeletionChannel',
        onMessageReceived: (JavaScriptMessage msg) async {
          debugPrint("WebView message: ${msg.message}");

          if (msg.message == "ACCOUNT_DELETED") {
            // ✅ Silent clear local data + cache + redirect (no popup)
            try {
              // 1) Google sign out (silent)
              try {
                final googleSignIn = GoogleSignIn();
                if (await googleSignIn.isSignedIn()) {
                  await googleSignIn.signOut();
                }
              } catch (_) {}

              // 2) Clear Flutter image MEMORY cache
              try {
                PaintingBinding.instance.imageCache.clear();
                PaintingBinding.instance.imageCache.clearLiveImages();
              } catch (_) {}

              // 3) Clear DISK cache (cached_network_image / flutter_cache_manager)
              try {
                await DefaultCacheManager().emptyCache();
              } catch (_) {}

              // 4) Clear local storage/profile
              await ClientLoginManager().clearClientProfile();
            } catch (e) {
              debugPrint("Clear session/cache error: $e");
              // still redirect
            }

            if (!mounted) return;
            context.go(AppRoutes.signInOptions);
          }
        },
      )

    // ✅ Load your page
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: _isPageLoading
            ? PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: (_progress / 100).clamp(0.0, 1.0),
            minHeight: 2,
            backgroundColor: const Color(0xFFE5E7EB),
          ),
        )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          // ✅ Full-screen loader until page finished
          if (_isPageLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
