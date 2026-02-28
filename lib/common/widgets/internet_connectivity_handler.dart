import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InternetConnectivityHandler extends StatefulWidget {
  final Widget child;
  final Function(bool hasInternet)? onConnectivityChanged;
  final bool isBody;

  const InternetConnectivityHandler({
    super.key,
    required this.child,
    this.onConnectivityChanged,
    this.isBody = false,
  });

  @override
  State<InternetConnectivityHandler> createState() =>
      _InternetConnectivityHandlerState();
}

class _InternetConnectivityHandlerState
    extends State<InternetConnectivityHandler> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _dialogShown = false;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _handleConnectivityChanged(result);
    });
  }

  void _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _handleConnectivityChanged(result);
  }

  void _handleConnectivityChanged(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;

    if (_hasInternet != hasInternet) {
      _hasInternet = hasInternet;
      widget.onConnectivityChanged?.call(hasInternet);

      if (!hasInternet) {
        if (widget.isBody) {
          // 👈 Body mode → trigger rebuild
          setState(() {});
        } else if (!_dialogShown && mounted) {
          // 👈 Dialog mode
          _dialogShown = true;
          _showNoInternetDialog();
        }
      } else {
        if (widget.isBody) {
          setState(() {});
        } else if (_dialogShown && mounted) {
          _dialogShown = false;
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            contentPadding: const EdgeInsets.all(30),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/images/device_connection/undraw_server-down_lxs9.svg",
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  "Something went wrong",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "No internet connection detected. Please check your connection and try again.",
                  style: GoogleFonts.poppins(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    final retryResult =
                        await Connectivity().checkConnectivity();
                    if (retryResult != ConnectivityResult.none && mounted) {
                      _dialogShown = false;
                      _hasInternet = true;
                      widget.onConnectivityChanged?.call(true);
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF308BF9),
                  ),
                  child: Text(
                    "Try Again",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBody && !_hasInternet) {
      // 👈 Render in-body "No internet" widget
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/images/device_connection/undraw_server-down_lxs9.svg",
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              "No Internet Connection",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Please check your connection and try again.",
              style: GoogleFonts.poppins(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return widget.child;
  }
}
