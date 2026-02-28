// lib/core/widgets/status_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBar extends StatelessWidget {
  final Color color;                              // Status bar background
  final Brightness iconBrightness;                // ANDROID icons (light=white, dark=black)
  final Brightness iosBrightness;                 // iOS text (dark => light text)
  final Color? navBarColor;                       // Android nav bar (optional)
  final Brightness? navIconBrightness;            // Android nav icons (optional)
  final Widget child;

  const StatusBar({
    super.key,
    required this.color,
    this.iconBrightness = Brightness.light,
    this.iosBrightness = Brightness.dark,
    this.navBarColor,
    this.navIconBrightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final style = SystemUiOverlayStyle(
      statusBarColor: color,
      statusBarIconBrightness: iconBrightness,      // Android
      statusBarBrightness: iosBrightness,           // iOS
      systemNavigationBarColor: navBarColor ?? Colors.black,
      systemNavigationBarIconBrightness: navIconBrightness ?? Brightness.light,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}
