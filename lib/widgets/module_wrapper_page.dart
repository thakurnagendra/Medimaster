import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/services/back_button_service.dart';

/// A widget that wraps all module screens with consistent back button behavior
class ModuleWrapperPage extends StatelessWidget {
  final Widget child;
  final String moduleName;
  final bool showExitConfirmation;
  
  const ModuleWrapperPage({
    super.key, 
    required this.child,
    required this.moduleName,
    this.showExitConfirmation = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !showExitConfirmation,
      onPopInvoked: (didPop) async {
        if (didPop || !showExitConfirmation) return;
        
        try {
          // Show exit confirmation dialog with module name for customized message
          final backButtonService = Get.find<BackButtonService>();
          await backButtonService.showExitConfirmationDialog(moduleName: moduleName);
        } catch (e) {
          print('Error showing exit dialog: $e');
        }
      },
      child: child,
    );
  }
} 