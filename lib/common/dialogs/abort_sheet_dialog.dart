import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/size/get_height.dart' show rh;

class CheckAbortSheet {
  static void show({
    required BuildContext context,
    VoidCallback? onTakeTextClick,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rh(context: context, px: 20)),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return _CoolingDownContent(onTakeTextClick: onTakeTextClick);
      },
    );
  }
}

class _CoolingDownContent extends StatefulWidget {
  final VoidCallback? onTakeTextClick;

  const _CoolingDownContent({this.onTakeTextClick});

  @override
  State<_CoolingDownContent> createState() => _CoolingDownContentState();
}

class _CoolingDownContentState extends State<_CoolingDownContent> {
  static const String _keyCancelOrDisconnectTime = 'cancel_or_disconnect_time';

  // ✅ single source of truth
  static const int _cooldownSeconds = 35;

  int _remainingSeconds = _cooldownSeconds;
  bool _isButtonEnabled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
  }

  Future<void> _calculateRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTimeStr = prefs.getString(_keyCancelOrDisconnectTime);

    if (storedTimeStr != null) {
      final storedTime = DateTime.tryParse(storedTimeStr);
      if (storedTime != null) {
        final now = DateTime.now();
        final diff = now.difference(storedTime).inSeconds;
        final remaining = _cooldownSeconds - diff;

        if (remaining > 0) {
          setState(() {
            _remainingSeconds = remaining;
            _isButtonEnabled = false;
          });
          _startTimer();
          return;
        }
      }
    }

    setState(() {
      _remainingSeconds = 0;
      _isButtonEnabled = true;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isButtonEnabled = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rh(context: context, px: 20),
          vertical: rh(context: context, px: 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: CircleAvatar(
                  radius: rh(context: context, px: 16),
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: rh(context: context, px: 24),
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // SizedBox(height: rh(context: context, px: 10)),
            // _isButtonEnabled
            //     ? SvgPicture.asset("assets/images/device_connection/device_ready.svg")
            //     : SvgPicture.asset("assets/images/device_connection/device_error.svg"),

            SizedBox(height: rh(context: context, px: 50)),
            Text(
              _isButtonEnabled ? "Device is Ready Now" : "Device Cooling Down",
              style: GoogleFonts.poppins(
                color: const Color(0xFF252525),
                fontSize: rh(context: context, px: 25),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: rh(context: context, px: 10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _isButtonEnabled
                    ? "Device is ready now. You can continue with the test."
                    : "You aborted the previous test. Respyr needs to cool down. Please wait for few seconds before starting the next test.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF535359),
                  fontSize: rh(context: context, px: 15),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: rh(context: context, px: 10)),
            if (_remainingSeconds > 0)
              Text(
                "$_remainingSeconds seconds",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF252525),
                  fontSize: rh(context: context, px: 25),
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(height: rh(context: context, px: 50)),
            SizedBox(
              width: double.infinity,
              height: rh(context: context, px: 52),
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  Navigator.of(context).pop();
                  widget.onTakeTextClick?.call();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    vertical: rh(context: context, px: 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      rh(context: context, px: 2500),
                    ),
                  ),
                  backgroundColor: const Color(0xFF308BF9),
                  // backgroundColor: const Color(0xFFD9D9D9),
                  disabledBackgroundColor: const Color(0xFFD9D9D9),
                ),
                child: Text(
                  _isButtonEnabled ? "Start Test" : "00 : $_remainingSeconds",
                  style: GoogleFonts.poppins(
                    fontSize: rh(context: context, px: 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
