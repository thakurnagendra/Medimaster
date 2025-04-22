import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controllers/signin_controllers.dart';

mixin ActivityTrackerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _setupActivityTracking();
  }

  void _setupActivityTracking() {
    // Track scroll activity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollController = ScrollController();
      scrollController.addListener(() {
        _updateActivity();
      });
    });

    // Track tap activity
    GestureDetector(
      onTap: () => _updateActivity(),
      child: widget,
    );
  }

  void _updateActivity() {
    try {
      final signInController = Get.find<SignInController>();
      signInController.updateLastActivityTime();
    } catch (e) {
      print('Error updating activity time: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 