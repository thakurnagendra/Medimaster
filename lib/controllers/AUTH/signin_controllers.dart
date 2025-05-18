import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:medimaster/controllers/AUTH/logout_controller.dart';
import '../../../config/api_config.dart';
import '../../../services/api_service.dart';
import '../main_controller.dart'; // Import MainController for company management
import '../../../utils/jwt_util.dart'; // Import the new JWT utility
import 'dart:async';

class SignInController extends GetxController {
  LogoutController controller = Get.put(LogoutController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final GetStorage storage = GetStorage();
  final ApiService _apiService = ApiService();
  Timer? _tokenExpirationTimer;
  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  final Duration _inactivityTimeout = const Duration(hours: 8);
  final Duration _tokenRefreshThreshold = const Duration(minutes: 15);

  // For adding company flow
  final RxBool isAddingCompany = false.obs;

  // Flag to track if we're currently trying to refresh the token
  final RxBool isRefreshingToken = false.obs;

  // Flag to track application state
  final RxBool isAppActive = true.obs;

  @override
  void onInit() {
    super.onInit();

    // Ensure storage is properly initialized
    _initStorage();

    // Check if we're in the "add company" flow
    final args = Get.arguments;
    if (args != null && args is Map && args['addingCompany'] == true) {
      isAddingCompany.value = true;
    } else {
      // Delay the login status check to ensure everything is initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkLoginStatus();
        _startTokenExpirationCheck();
        _startInactivityTimer();
      });

      // Setup app lifecycle listeners
      _setupAppLifecycleListeners();
    }
  }

  // Initialize storage to ensure it's ready
  Future<void> _initStorage() async {
    try {
      // Initialize GetStorage
      await GetStorage.init();
      print('GetStorage initialized successfully');
    } catch (e) {
      print('Error initializing GetStorage: $e');
    }

    // Set default values after ensuring storage is initialized
    _setDefaultValues();
  }

  void _setDefaultValues() {
    Future.microtask(() {
      usernameController.text = 'demo';
      passwordController.text = 'Test@1235';
    });
  }

  void _checkLoginStatus() {
    try {
      final token = storage.read<String>('token');
      print(
        'Checking login status: Token = ${token != null ? "${token.substring(0, 10)}..." : "null"}',
      );

      if (token != null && !isAddingCompany.value) {
        try {
          // Validate the token before redirecting
          final Map<String, dynamic> tokenContents = JwtUtil.decodeToken(token);
          print('Token decoded contents: $tokenContents');

          if (tokenContents.containsKey('exp')) {
            final int expirationTime = tokenContents['exp'] as int;
            final int currentTime =
                DateTime.now().millisecondsSinceEpoch ~/ 1000;

            print(
              'Token expiration time: ${DateTime.fromMillisecondsSinceEpoch(expirationTime * 1000)}',
            );
            print('Current time: ${DateTime.now()}');
            print('Time to expiry: ${expirationTime - currentTime} seconds');

            if (currentTime < expirationTime) {
              // Token is valid and not expired
              print('Valid token found. Redirecting to main screen.');
              updateLastActivityTime(); // Update activity time on auto-login

              // Ensure company data is loaded
              _loadCompanyFromToken(token);

              Future.microtask(() => Get.offAllNamed('/main'));
            } else {
              // Token is expired, try to refresh
              print('Token expired. Attempting to refresh...');
              _refreshToken().then((success) {
                if (success) {
                  print('Token refreshed successfully. Redirecting to main.');
                  Future.microtask(() => Get.offAllNamed('/main'));
                } else {
                  print('Token refresh failed. Staying on login screen.');
                  // Clear invalid token but keep username
                  final username = storage.read<String>('username');
                  storage.remove('token');
                  if (username != null) {
                    storage.write('lastUsername', username);
                  }
                }
              });
            }
          } else {
            print('Invalid token format. No expiration data found.');
            storage.remove('token');
          }
        } catch (e) {
          print('Error validating token: $e');
          // Remove invalid token
          storage.remove('token');
        }
      } else {
        print('No token found or adding company, staying on login screen');
      }
    } catch (e) {
      print('Error in _checkLoginStatus: $e');
    }
  }

  // Load company from token if not already loaded
  void _loadCompanyFromToken(String token) {
    try {
      // Check if companies are already loaded
      final companies = storage.read<List>('companies');
      if (companies == null || companies.isEmpty) {
        print('No companies found, adding from token');
        _addSchoolAsCompany(token);
      }
    } catch (e) {
      print('Error loading company from token: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// ✅ **Login with API Integration**
  Future<void> login() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    // 🚨 Validate input
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Username and password are required",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      print('Attempting login with username: $username');
      final response = await _apiService.post(ApiConfig.login, {
        'username': username,
        'password': password,
      });

      // Debug the login response
      print(
        'Login response received: ${response.containsKey('accessToken') ? "contains token" : "no token found"}',
      );

      if (response.containsKey('accessToken')) {
        final token = response['accessToken'];
        print('Access token received, length: ${token.length}');

        // Store refresh token if provided
        final refreshToken = response['refreshToken'] ?? '';
        if (refreshToken.isNotEmpty) {
          print('Refresh token received, length: ${refreshToken.length}');
        }

        // Save token to storage FIRST
        await _saveSessionAsync(token, username, refreshToken);

        // Verify token is saved before continuing
        final savedToken = storage.read<String>('token');
        print('Saved token matches original: ${savedToken == token}');

        // Extract school information from token and add as company
        _addSchoolAsCompany(token);

        Get.offAllNamed('/main');
      } else {
        print('Login failed - No access token in response');
        Get.snackbar(
          "Login Failed",
          response['message'] ?? "Invalid credentials",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Login exception: $e');
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // New async session save method with retry
  Future<void> _saveSessionAsync(
    String token,
    String username, [
    String refreshToken = '',
  ]) async {
    try {
      // Save user token - this will be used for API authorization
      storage.write('token', token);
      storage.write('username', username);

      // Save refresh token if provided
      if (refreshToken.isNotEmpty) {
        storage.write('refreshToken', refreshToken);
        print('Refresh token saved successfully');
      }

      // Also save username in lastUsername for convenience on next login
      storage.write('lastUsername', username);

      print('User session saved with token length: ${token.length}');

      // Verify token is saved properly with retry mechanism
      int attempts = 0;
      bool verified = false;

      while (!verified && attempts < 3) {
        final savedToken = storage.read<String>('token');
        if (savedToken != null && savedToken == token) {
          print(
            'Token successfully verified in storage on attempt ${attempts + 1}',
          );
          verified = true;
        } else {
          print(
            'Token verification failed on attempt ${attempts + 1}, retrying...',
          );
          await Future.delayed(const Duration(milliseconds: 300));
          storage.write('token', token);
          attempts++;
        }
      }

      if (!verified) {
        print('WARNING: Could not verify token after multiple attempts');
      }

      // Update the last activity time to prevent inactivity logout right after login
      updateLastActivityTime();
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Add school as company using token data
  void _addSchoolAsCompany(String token) {
    try {
      print('Adding school as company using token');

      // Extract school name and ID using JwtUtil
      final String schoolName = JwtUtil.getSchoolName(token);
      final String schoolId = JwtUtil.getSchoolId(token);

      // Get school type if available in token
      final String schoolType = JwtUtil.getSchoolType(token) ?? 'lab';

      print(
        'Extracted from token - School Name: $schoolName, School ID: $schoolId, School Type: $schoolType',
      );

      // Random color selection
      final List<Color> colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
      ];
      final Color randomColor =
          colors[DateTime.now().millisecond % colors.length];

      // Generate short name from school ID or name
      String shortName = schoolId.isNotEmpty
          ? schoolId
          : JwtUtil.generateShortName(schoolName);

      // Create company data including the access token
      final companyData = {
        'name': schoolName,
        'shortName': shortName,
        'color': randomColor.value,
        'isActive': true,
        'defaultModule': schoolType,
        'id': schoolId,
        'accessToken': token, // Store the token for company API access
      };

      // Verify the tokens are properly set
      print('User token in storage: ${token.substring(0, 10)}...');
      print(
        'Company token set as: ${companyData['accessToken'].toString().substring(0, 10)}...',
      );

      // Log company data for debugging (partial to avoid showing the full token)
      print(
        'Adding company with name: ${companyData['name']}, ID: ${companyData['id']}',
      );

      // Add company through MainController with default module based on school type
      try {
        final MainController mainController = Get.find<MainController>();
        mainController.addCompany(
          schoolName,
          shortName,
          randomColor,
          defaultModule: schoolType,
          companyId: schoolId,
          companyToken: token,
        );
        print('Company successfully added through MainController');

        // Verify company was added correctly
        if (mainController.companies.isNotEmpty) {
          final lastCompany = mainController.companies.last;
          print(
            'Company added with token status: ${lastCompany.containsKey('accessToken') ? 'Has token' : 'No token'}',
          );
        }
      } catch (e) {
        print('Error finding MainController: $e');
        // If MainController is not available yet, store the company info for later
        storage.write('pendingCompany', companyData);
        print('Company saved as pending for later addition');
      }
    } catch (e) {
      print('Error adding school as company: $e');
    }
  }

  // Variables for company creation
  final String _companyName = '';
  final String _shortName = '';
  final Color _selectedColor = Colors.blue;

  // Validate company input
  bool _validateCompanyInput() {
    if (_companyName.isEmpty) {
      Get.snackbar(
        "Error",
        "Company name is required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (_shortName.isEmpty) {
      Get.snackbar(
        "Error",
        "Short name is required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// ✅ **Logout function (clears storage and redirects to login)**
  void logout() {
    print('User requested logout - calling LogoutController');
    controller.logout(); // Call the LogoutController's logout method
  }

  void _setupAppLifecycleListeners() {
    // Listen for app lifecycle changes
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('App lifecycle state changed: $msg');
      if (msg == AppLifecycleState.resumed.toString()) {
        isAppActive.value = true;
        // Check if user should be logged out due to inactivity
        _checkInactivityOnResume();
      } else if (msg == AppLifecycleState.paused.toString()) {
        isAppActive.value = false;
        // Save last paused time
        storage.write('lastPausedTime', DateTime.now().millisecondsSinceEpoch);
      }
      return Future.value(msg);
    });
  }

  void _checkInactivityOnResume() {
    final lastPausedTime = storage.read<int>('lastPausedTime');
    if (lastPausedTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final inactiveTime = now - lastPausedTime;

      // If inactive for more than 30 minutes (1800000 ms), try to refresh token first
      if (inactiveTime > _inactivityTimeout.inMilliseconds) {
        print(
          'App was inactive for ${inactiveTime / 60000} minutes, attempting token refresh',
        );
        _refreshToken().then((refreshed) {
          if (!refreshed) {
            // Only force logout if refresh failed
            _forceLogout('You have been logged out due to inactivity.');
          } else {
            // If refresh succeeded, update activity time
            updateLastActivityTime();
          }
        });
        return;
      }

      // If we're here, update the activity time
      updateLastActivityTime();
    }
  }

  void _startInactivityTimer() {
    // Cancel any existing timer
    _inactivityTimer?.cancel();

    // Initialize last activity time
    _lastActivityTime = DateTime.now();

    // Store initial activity time
    storage.write('lastActiveTime', _lastActivityTime?.millisecondsSinceEpoch);

    // Check for inactivity every minute
    _inactivityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_lastActivityTime != null) {
        final timeSinceLastActivity = DateTime.now().difference(
          _lastActivityTime!,
        );

        // Also save the last check time to storage for background checks
        storage.write(
          'lastActiveTime',
          _lastActivityTime?.millisecondsSinceEpoch,
        );

        if (timeSinceLastActivity >= _inactivityTimeout) {
          print(
            'User inactive for ${timeSinceLastActivity.inMinutes} minutes. Logging out...',
          );
          _handleInactivityLogout();
        }
      }
    });
  }

  void updateLastActivityTime() {
    _lastActivityTime = DateTime.now();
    // Also update in storage for persistence
    storage.write('lastActiveTime', _lastActivityTime?.millisecondsSinceEpoch);
    print('User activity detected at $_lastActivityTime');
  }

  void _handleInactivityLogout() {
    // Before logging out due to inactivity, always try to refresh the token first
    try {
      print('Inactivity detected - attempting token refresh before logout');
      _refreshToken().then((success) {
        if (success) {
          // If token refresh succeeded, update activity time and continue
          updateLastActivityTime();

          // Reset the inactivity timer with the new timestamp
          _startInactivityTimer();
          print('Session refreshed after inactivity - continuing');
        } else {
          // Only log out if token refresh failed
          print('Token refresh failed after inactivity - logging out');
          _tokenExpirationTimer?.cancel();
          _inactivityTimer?.cancel();

          // Clear storage but preserve username for convenience
          final username = storage.read<String>('username');
          storage.erase();
          if (username != null) {
            storage.write('lastUsername', username);
          }

          // Show inactivity message
          Get.snackbar(
            "Session Timeout",
            "You have been logged out due to inactivity.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Navigate to login screen
          Get.offAllNamed('/login');
        }
      });
    } catch (e) {
      print('Error in inactivity handler: $e');
      // Try to refresh token even if error occurs in the handler
      _refreshToken().then((success) {
        if (!success) {
          // Only log out if refresh fails
          _tokenExpirationTimer?.cancel();
          _inactivityTimer?.cancel();
          storage.erase();
          Get.offAllNamed('/login');
        } else {
          updateLastActivityTime();
        }
      });
    }
  }

  void _startTokenExpirationCheck() {
    // Cancel any existing timer
    _tokenExpirationTimer?.cancel();

    // Check token expiration every 5 minutes instead of every minute
    _tokenExpirationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final token = storage.read('token');
      if (token != null) {
        try {
          final tokenContents = JwtUtil.decodeToken(token);
          if (tokenContents.containsKey('exp')) {
            final expirationTime = tokenContents['exp'] as int;
            final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final timeToExpiry = expirationTime - currentTime;

            // Only log every hour to reduce noise
            if (timeToExpiry % 3600 < 300) {
              print('Token expiration check: ${timeToExpiry}s remaining');
            }

            // Only refresh if token is very close to expiry
            if (timeToExpiry <= _tokenRefreshThreshold.inSeconds) {
              print(
                  'Token expiring soon (${timeToExpiry}s remaining). Attempting refresh...');
              _refreshToken().then((refreshed) {
                if (!refreshed && timeToExpiry <= 0) {
                  // Only force logout if refresh failed AND token is actually expired
                  print('Refresh failed and token is expired. Forcing logout.');
                  _forceLogout('Your session has expired. Please login again.');
                }
              });
            }
          }
        } catch (e) {
          print('Error checking token expiration: $e');
        }
      }
    });
  }

  // Add refresh token expiration check
  bool _isRefreshTokenExpired(String token) {
    try {
      final tokenContents = JwtUtil.decodeToken(token);
      if (tokenContents.containsKey('exp')) {
        final expirationTime = tokenContents['exp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Log the expiration time for debugging
        print(
          'Checking token expiration: ${expirationTime - currentTime}s remaining',
        );

        // Only consider token expired if it's more than 30 seconds past expiry
        // This provides some buffer for clock differences
        return currentTime > expirationTime + 30;
      }
    } catch (e) {
      print('Error checking refresh token expiration: $e');

      // Don't assume expired on error - try to refresh anyway
      return false;
    }
    return false; // If we can't verify, don't assume expired (changed from true)
  }

  // Update the refresh token method to be more resilient
  Future<bool> _refreshToken() async {
    // If we're already refreshing, wait for it to complete
    if (isRefreshingToken.value) {
      print('Token refresh already in progress, waiting...');
      int attempts = 0;
      while (isRefreshingToken.value && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      return !isRefreshingToken.value;
    }

    isRefreshingToken.value = true;
    try {
      final currentToken = storage.read<String>('token');
      final username = storage.read<String>('username');
      final refreshToken = storage.read<String>('refreshToken');

      if (currentToken == null || username == null) {
        print('Cannot refresh token: missing current token or username');
        isRefreshingToken.value = false;
        return false;
      }

      // Check if current token is still valid
      try {
        final tokenContents = JwtUtil.decodeToken(currentToken);
        if (tokenContents.containsKey('exp')) {
          final expirationTime = tokenContents['exp'] as int;
          final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final timeToExpiry = expirationTime - currentTime;

          // If token is still valid for more than 30 minutes, skip refresh
          if (timeToExpiry > 1800) {
            print(
                'Token still valid (${timeToExpiry}s remaining). Skipping refresh.');
            isRefreshingToken.value = false;
            return true;
          }
        }
      } catch (e) {
        print('Error checking token expiration: $e');
      }

      // Prepare refresh request
      final Map<String, dynamic> requestData = {
        'username': username,
        'currentToken': currentToken,
      };

      if (refreshToken != null && refreshToken.isNotEmpty) {
        requestData['refreshToken'] = refreshToken;
      }

      final response = await _apiService.post(
        ApiConfig.refreshToken,
        requestData,
        token: currentToken,
      );

      if (response.containsKey('accessToken')) {
        final newToken = response['accessToken'];
        final newRefreshToken = response['refreshToken'] ?? '';

        await _saveSessionAsync(newToken, username, newRefreshToken);
        _updateCompanyToken(newToken);

        print('Token refreshed successfully');
        isRefreshingToken.value = false;
        return true;
      }

      // Handle HTML responses more gracefully
      if (response.containsKey('html_response')) {
        // Check if current token is still valid
        try {
          final tokenContents = JwtUtil.decodeToken(currentToken);
          if (tokenContents.containsKey('exp')) {
            final expirationTime = tokenContents['exp'] as int;
            final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            if (currentTime < expirationTime - 300) {
              // Still valid for 5+ minutes
              print(
                  'Got HTML response but current token still valid. Continuing session.');
              isRefreshingToken.value = false;
              return true;
            }
          }
        } catch (e) {
          print('Error checking token validity: $e');
        }
      }

      isRefreshingToken.value = false;
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      isRefreshingToken.value = false;
      return false;
    }
  }

  // Update the token in the active company
  void _updateCompanyToken(String newToken) {
    try {
      final MainController mainController = Get.find<MainController>();
      if (mainController.companies.isNotEmpty) {
        final activeIndex = mainController.activeCompanyIndex.value;
        if (activeIndex >= 0 && activeIndex < mainController.companies.length) {
          mainController.companies[activeIndex]['accessToken'] = newToken;
          mainController.companies.refresh();
          print('Company token updated');
        }
      }
    } catch (e) {
      print('Error updating company token: $e');
    }
  }

  void _handleTokenExpiration() {
    // Always try to refresh the token first
    print('Token expiration detected - attempting refresh');
    _refreshToken().then((success) {
      if (success) {
        print('Session restored with refreshed token');
        return;
      }

      // If we get here, token refresh failed - now we can log out
      print('Token refresh failed after expiration - logging out');
      _tokenExpirationTimer?.cancel();
      _inactivityTimer?.cancel();

      // Clear storage but preserve some user data for easier login
      final username = storage.read<String>('username');
      storage.erase();
      if (username != null) {
        storage.write('lastUsername', username);
      }

      // Show expiration message
      Get.snackbar(
        "Session Expired",
        "Your session has expired. Please login again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to login screen
      Get.offAllNamed('/login');
    });
  }

  // Public method to be called from API service
  Future<bool> refreshTokenForApiService() async {
    // Don't allow concurrent refresh attempts
    if (isRefreshingToken.value) {
      print('Token refresh already in progress, waiting...');
      // Wait for the current refresh to complete
      int attempts = 0;
      while (isRefreshingToken.value && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      // If we still couldn't refresh after waiting, return false
      if (isRefreshingToken.value) {
        print('Token refresh is taking too long, returning failure');
        return false;
      }
      // Otherwise return true since the refresh completed
      return true;
    }

    // Set the flag to prevent concurrent refreshes
    isRefreshingToken.value = true;
    print('Token refresh requested from API service');

    try {
      final result = await _refreshToken();
      isRefreshingToken.value = false;
      return result;
    } catch (e) {
      print('Error during token refresh: $e');
      isRefreshingToken.value = false;
      return false;
    }
  }

  // Handle session recovery after network reconnect
  Future<bool> recoverSession() async {
    print('Attempting to recover session after network reconnect');

    // First, check if we have a valid token
    final token = storage.read<String>('token');
    if (token == null) {
      print('No token found for session recovery');
      return false;
    }

    try {
      // Validate the token expiration time
      final tokenContents = JwtUtil.decodeToken(token);
      if (tokenContents.containsKey('exp')) {
        final expirationTime = tokenContents['exp'] as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // If token is expired or will expire soon, refresh it
        if (currentTime >= expirationTime - 300) {
          // 5 minutes
          print('Token expired or expiring soon, refreshing during recovery');
          return await _refreshToken();
        } else {
          print('Token still valid, session recovered successfully');
          // Update activity timestamp
          updateLastActivityTime();
          return true;
        }
      }
    } catch (e) {
      print('Error validating token during recovery: $e');
    }

    // If we can't validate or the token is expired, try to refresh
    return await _refreshToken();
  }

  // Force logout without trying to refresh the token
  void _forceLogout(String message) {
    _tokenExpirationTimer?.cancel();
    _inactivityTimer?.cancel();

    // Clear storage but preserve username for convenience
    final username = storage.read<String>('username');

    // Explicitly remove both access and refresh tokens
    storage.remove('token');
    storage.remove('refreshToken');

    // Clear all user session data
    storage.erase();

    // Preserve username for login convenience
    if (username != null) {
      storage.write('lastUsername', username);
    }

    // Show message
    Get.snackbar(
      "Session Ended",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Navigate to login screen
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    _tokenExpirationTimer?.cancel();
    _inactivityTimer?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
