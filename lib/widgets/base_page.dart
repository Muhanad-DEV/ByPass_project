import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final bool allowSwipeNavigation;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final bool debug;

  const BasePage({
    Key? key,
    required this.child,
    this.allowSwipeNavigation = true,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.debug = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Disable overflow messages globally
    if (!debug) {
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null && !message.contains('overflowed by')) {
          print(message);
        }
      };
    }

    if (!allowSwipeNavigation) return child;

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! > 0) {
          // Right swipe
          if (debug) print('Debug: Right swipe detected');
          if (onSwipeRight != null) {
            onSwipeRight!();
          } else {
            Navigator.of(context).maybePop();
          }
        } else if (details.primaryVelocity! < 0) {
          // Left swipe
          if (debug) print('Debug: Left swipe detected');
          if (onSwipeLeft != null) {
            onSwipeLeft!();
          } else {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: child,
    );
  }
}