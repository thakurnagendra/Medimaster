import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/AUTH/signin_controllers.dart';

/// A widget that listens for user interactions and updates the activity timestamp
/// to prevent automatic logout due to inactivity
class ActivityTracker extends StatelessWidget {
  final Widget child;

  const ActivityTracker({super.key, required this.child});

  void _updateActivity() {
    try {
      final signInController = Get.find<SignInController>();
      signInController.updateLastActivityTime();
    } catch (e) {
      // Silently fail if controller not found
      debugPrint('ActivityTracker: Cannot update activity - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _updateActivity(),
      onPointerMove: (_) => _updateActivity(),
      onPointerSignal: (_) => _updateActivity(),
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: _updateActivity,
        onScaleStart: (_) => _updateActivity(),
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }
}
