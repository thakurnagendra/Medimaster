import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/controllers/auth_controllers/signin_controllers.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final SignInController signInController;

  @override
  void initState() {
    super.initState();
    print('LoginScreen - initState called');
    signInController = Get.put(SignInController());
    print('LoginScreen - SignInController initialized');

    // Check for saved username
    _checkSavedUsername();
  }

  void _checkSavedUsername() {
    final storage = GetStorage();
    final savedUsername = storage.read<String>('lastUsername');
    if (savedUsername != null && savedUsername.isNotEmpty) {
      signInController.usernameController.text = savedUsername;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('LoginScreen - build method called');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 253, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/medimasterlogo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading logo image: $error');
                        return Container(
                          height: 100,
                          width: 200,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Text(
                            'MediMaster',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: signInController.usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => TextField(
                        controller: signInController.passwordController,
                        obscureText: !signInController.isPasswordVisible.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              signInController.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed:
                                signInController.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          signInController.login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A884),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Obx(
                          () => signInController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
