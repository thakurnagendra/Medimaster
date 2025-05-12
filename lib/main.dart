import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medimaster/bindings/lab_bindings.dart';
import 'package:medimaster/controllers/main_controller.dart';
import 'package:medimaster/screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'package:medimaster/controllers/auth_controllers/signin_controllers.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:medimaster/services/connectivity_service.dart';
import 'package:medimaster/services/back_button_service.dart';
import 'package:medimaster/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.i('App initializing...');
  await GetStorage.init();
  Logger.i('GetStorage initialized');

  // Initialize controllers
  Get.put(GetStorage());
  Logger.i('GetStorage registered in GetX');

  // Register ApiService as permanent
  Get.put(ApiService(), permanent: true);
  Logger.i('ApiService registered in GetX');

  // Register SignInController as permanent (for token refresh)
  Get.put(SignInController(), permanent: true);
  Logger.i('SignInController registered in GetX');

  // Register MainController as permanent (keep in memory)
  Get.put(MainController(), permanent: true);
  Logger.i('MainController registered in GetX');

  // Register BackButtonService for handling app exit confirmations
  Get.put(BackButtonService(), permanent: true);
  Logger.i('BackButtonService registered in GetX');

  // Initialize connectivity service
  await Get.putAsync(() async => await ConnectivityService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.i('Building MyApp widget');
    return ActivityTrackingWrapper(
      child: GetMaterialApp(
        title: 'MediMaster',
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(
            name: '/main',
            page: () => MainScreen(),
            binding: BindingsBuilder(() {
              // Ensure controller is ready before the page loads
              if (!Get.isRegistered<MainController>()) {
                Get.put(MainController(), permanent: true);
              }
              // Initialize the Lab module bindings
              LabBinding().dependencies();
            }),
          ),
        ],
      ),
    );
  }
}

class ActivityTrackingWrapper extends StatefulWidget {
  final Widget child;
  const ActivityTrackingWrapper({super.key, required this.child});

  @override
  State<ActivityTrackingWrapper> createState() =>
      _ActivityTrackingWrapperState();
}

class _ActivityTrackingWrapperState extends State<ActivityTrackingWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          final signInController = Get.find<SignInController>();
          signInController.updateLastActivityTime();
        } catch (e) {
          Logger.e('Error updating activity time', e);
        }
      },
      child: widget.child,
    );
  }
}
