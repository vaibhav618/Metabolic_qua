import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PillVariant { filled, outline, soft }

class Pill extends StatelessWidget {
  final String label;
  final PillVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final double fontSize;

  /// Custom overrides
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const Pill({
    super.key,
    required this.label,
    this.variant = PillVariant.filled,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.radius = 999, // pill shape
    this.fontSize = 12,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Defaults per variant
    Color bg, fg, border;
    switch (variant) {
      case PillVariant.filled:
        bg = backgroundColor ?? cs.primary;
        fg = textColor ?? cs.onPrimary;
        border = borderColor ?? Colors.transparent;
        break;
      case PillVariant.outline:
        bg = backgroundColor ?? Colors.transparent;
        fg = textColor ?? cs.primary;
        border = borderColor ?? cs.primary.withOpacity(0.5);
        break;
      case PillVariant.soft:
        bg = backgroundColor ?? cs.primary.withOpacity(0.1);
        fg = textColor ?? cs.primary;
        border = borderColor ?? Colors.transparent;
        break;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 4, color: fg),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.20,
              height: 1.2
            ),
          ),
        ),
      ],
    );

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: child,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
