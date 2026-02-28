import 'package:flutter/material.dart';

class DietTheme {
  // Status bar swatches (if you use them elsewhere)
  final Color morningStatusBarColor   = const Color(0xFFFFE29F);
  final Color afternoonStatusBarColor = const Color(0xFFFFD6A5);
  final Color nightStatusBarColor     = const Color(0xFF8093F1);

  // Morning
  final Color morningDietDarkColor = const Color(0xFFDA5747);
  final LinearGradient morningHeroGradient = const LinearGradient(
    begin: Alignment(0.5, 0.0),
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)],
  );
  final LinearGradient morningItemGradient = LinearGradient(
    begin: const Alignment(0.5, 0.0),
    end: const Alignment(0.5, 1.0),
    colors: [Colors.white, Colors.white, Colors.white.withOpacity(0.0)],
  );

  // Afternoon
  final Color afternoonDietDarkColor = const Color(0xFFC9880F);
  final LinearGradient afternoonHeroGradient = const LinearGradient(
    begin: Alignment(0.5, 0.0),
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFFFD6A5), Color(0xFFFDCB6E)],
  );
  final LinearGradient afternoonItemGradient = LinearGradient(
    begin: const Alignment(0.5, 0.0),
    end: const Alignment(0.5, 1.0),
    colors: [Colors.white, Colors.white, Colors.white.withOpacity(0.0)],
  );

  // Night
  final Color nightDietDarkColor = const Color(0xFF582699);

  final LinearGradient nightHeroGradient = const LinearGradient(
    begin: Alignment(0.5, 0.0),
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFF8093F1), Color(0xFFB388EB)],
  );
  final LinearGradient nightItemGradient = LinearGradient(
    begin: const Alignment(0.5, 0.0),
    end: const Alignment(0.5, 1.0),
    colors: [Colors.white, Colors.white, Colors.white.withOpacity(0.0)],
  );


}
