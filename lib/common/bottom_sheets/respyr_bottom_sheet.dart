import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final VoidCallback onCloseSheet;
  final Widget child;

  const AppBottomSheet({
    super.key,
    required this.onCloseSheet,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        // ✅ prevents keyboard / bottom inset overflow
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              // ✅ Rounded top like a real sheet
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                // ✅ IMPORTANT: don't force full height
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button area
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: onCloseSheet,
                        icon: const Icon(Icons.close, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(36, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ),

                  // ✅ This prevents the Column overflow by allowing the content to take remaining space
                  Flexible(
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
