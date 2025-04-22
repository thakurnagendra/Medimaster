import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../widgets/global_snackbar.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    // Check initial connection status
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _handleConnectivityResult(results);

    // Subscribe to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityResult);
    
    return this;
  }

  void _handleConnectivityResult(List<ConnectivityResult> results) {
    bool wasConnected = isConnected.value;
    
    // Consider connected if we have any connectivity that isn't "none"
    bool hasConnectivity = results.any((result) => result != ConnectivityResult.none);
    isConnected.value = hasConnectivity;
    
    // Only show messages if the state has changed
    if (wasConnected != isConnected.value) {
      if (isConnected.value) {
        GlobalSnackbar.showNetworkRestored();
      } else {
        GlobalSnackbar.showNetworkError();
      }
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// Extension method for easy access
extension ConnectivityServiceExtension on GetInterface {
  ConnectivityService get connectivity => Get.find<ConnectivityService>();
} 