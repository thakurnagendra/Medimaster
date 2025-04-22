import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'dart:ui';

class QRScannerController extends GetxController {
  final scanResult = ''.obs;
  final isScanCompleted = false.obs;
  final controller = MobileScannerController();
  final scanLinePosition = 10.0.obs;
  final patternSeed = 0.obs;
  final isDetecting = false.obs;
  final lastDetectionTime = 0.obs;
  final scanMode = ''.obs; // 'qr' or 'barcode'

  QRScannerController({String mode = 'qr'}) {
    scanMode.value = mode;
  }

  @override
  void onInit() {
    super.onInit();
    startScanAnimation();
    _startPatternAnimation();
  }

  void _startPatternAnimation() {
    if (isScanCompleted.value) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      patternSeed.value = DateTime.now().millisecondsSinceEpoch;
      _startPatternAnimation();
    });
  }

  void startScanAnimation() {
    // Reset position to top
    scanLinePosition.value = 10.0;

    // Create a loop that moves from top to bottom
    _animateScanLine();
  }

  void _animateScanLine() {
    if (isScanCompleted.value) return;

    Future.delayed(const Duration(milliseconds: 16), () {
      scanLinePosition.value += 1.5;
      if (scanLinePosition.value >= 270) {
        scanLinePosition.value = 10.0;
      }
      _animateScanLine();
    });
  }

  void foundBarcode(BarcodeCapture capture) {
    if (!isScanCompleted.value) {
      // Update last detection time and status
      isDetecting.value = true;
      lastDetectionTime.value = DateTime.now().millisecondsSinceEpoch;

      // After 1 second without detection, reset detection status
      Future.delayed(const Duration(milliseconds: 1000), () {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - lastDetectionTime.value >= 900) {
          isDetecting.value = false;
        }
      });

      if (capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        isScanCompleted.value = true;
        scanResult.value = barcode.rawValue ?? '';
        controller.stop();

        // Vibrate when QR code is detected
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200), () {
          HapticFeedback.mediumImpact();
        });
      }
    }
  }

  void restartScanner() {
    isScanCompleted.value = false;
    scanResult.value = '';
    scanLinePosition.value = 10.0;
    controller.start();
    startScanAnimation();
    _startPatternAnimation();
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.tryParse(url) ?? Uri();
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          mode: url_launcher.LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not launch URL");
    }
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}

class QRScannerView extends GetView<QRScannerController> {
  final String mode;

  const QRScannerView({super.key, this.mode = 'qr'});

  static void initBindings({String mode = 'qr'}) {
    Get.lazyPut<QRScannerController>(() => QRScannerController(mode: mode));
  }

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized if not done through bindings
    if (!Get.isRegistered<QRScannerController>()) {
      Get.put(QRScannerController(mode: mode));
    }

    // Is this a barcode or QR scanner?
    final bool isBarcode = mode == 'barcode';
    final String title = isBarcode ? "Scan Barcode" : "Scan QR Code";
    final String instruction = isBarcode
        ? "Position the barcode within the frame to scan"
        : "Position the QR code within the frame to scan";

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: controller.controller,
            onDetect: controller.foundBarcode,
            // Configure scanner based on the mode
            scanWindow: isBarcode
                ? Rect.fromLTWH(
                    50,
                    MediaQuery.of(context).size.height / 2 - 50,
                    MediaQuery.of(context).size.width - 100,
                    100,
                  )
                : null,
          ),

          // Overlay with cutout
          Obx(
            () => !controller.isScanCompleted.value
                ? Stack(
                    children: [
                      // Dark overlay with cutout
                      ClipPath(
                        clipper: isBarcode
                            ? BarcodeScannerClipper()
                            : ScannerClipper(),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),

                      // Scanner frame
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildScanFrame(isBarcode),

                            // Instructions
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 40, right: 40),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      instruction,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            blurRadius: 5,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(0.5),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildResultView(),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: controller.restartScanner,
                                icon: const Icon(Icons.replay),
                                label: const Text("Scan Again"),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue.withOpacity(0.6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 24),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
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
        ],
      ),
    );
  }

  Widget _buildScanFrame(bool isBarcode) {
    if (isBarcode) {
      // Barcode scanner frame (rectangular)
      return SizedBox(
        width: 280.0,
        height: 100.0,
        child: Stack(
          children: [
            // Frame with border and glow
            Obx(() => Container(
                  width: 280.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: controller.isDetecting.value
                            ? Colors.green.withOpacity(0.8)
                            : Colors.blue.withOpacity(0.8),
                        width: 3),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: controller.isDetecting.value
                            ? Colors.green.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.2),
                        blurRadius: controller.isDetecting.value ? 30 : 20,
                        spreadRadius: controller.isDetecting.value ? 8 : 5,
                      ),
                    ],
                  ),
                )),

            // Enhanced scanner animation (horizontal for barcode)
            Obx(() => !controller.isScanCompleted.value
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: controller.scanLinePosition.value *
                        280.0 /
                        270.0, // Scale position to barcode width
                    width: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            controller.isDetecting.value
                                ? Colors.green.withOpacity(0.8)
                                : Colors.blue.withOpacity(0.8),
                            Colors.white,
                            controller.isDetecting.value
                                ? Colors.green.withOpacity(0.8)
                                : Colors.blue.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: controller.isDetecting.value
                                ? Colors.green.withOpacity(0.9)
                                : Colors.blue.withOpacity(0.9),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox()),

            // Corner markers
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(true, true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(true, false),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner(false, true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner(false, false),
            ),
          ],
        ),
      );
    } else {
      // Existing QR scanner frame (square)
      return SizedBox(
        width: 300.0,
        height: 300.0,
        child: Stack(
          children: [
            // Frame with border and glow
            Obx(() => Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: controller.isDetecting.value
                            ? Colors.green.withOpacity(0.8)
                            : Colors.blue.withOpacity(0.8),
                        width: 3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: controller.isDetecting.value
                            ? Colors.green.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.2),
                        blurRadius: controller.isDetecting.value ? 30 : 20,
                        spreadRadius: controller.isDetecting.value ? 8 : 5,
                      ),
                    ],
                  ),
                )),

            // Scanning grid pattern
            Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomPaint(
                    size: const Size(300.0, 300.0),
                    painter:
                        ScannerPatternPainter(controller.patternSeed.value),
                  ),
                )),

            // Enhanced scanner animation
            Obx(() => !controller.isScanCompleted.value
                ? Positioned(
                    top: controller.scanLinePosition.value,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Main laser line
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                controller.isDetecting.value
                                    ? Colors.green.withOpacity(0.7)
                                    : Colors.blue.withOpacity(0.7),
                                Colors.white,
                                controller.isDetecting.value
                                    ? Colors.green.withOpacity(0.7)
                                    : Colors.blue.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: controller.isDetecting.value
                                    ? Colors.green.withOpacity(0.9)
                                    : Colors.blue.withOpacity(0.9),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Afterglow effect
                        Container(
                          height: 15,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                controller.isDetecting.value
                                    ? Colors.green.withOpacity(0.6)
                                    : Colors.blue.withOpacity(0.6),
                                controller.isDetecting.value
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()),

            // Corner markers
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(true, true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(true, false),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner(false, true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner(false, false),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildResultView() {
    return InkWell(
      onTap: () {
        if (controller.scanResult.value.startsWith("http")) {
          controller.openUrl(controller.scanResult.value);
        }
      },
      onLongPress: () async {
        await Clipboard.setData(
            ClipboardData(text: controller.scanResult.value));
        Get.snackbar("Copied", "QR code result copied to clipboard");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              controller.scanResult.value,
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 14,
                decoration: controller.scanResult.value.startsWith("http")
                    ? TextDecoration.underline
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: Colors.blue.withOpacity(0.8), width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: Colors.blue.withOpacity(0.8), width: 3)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: Colors.blue.withOpacity(0.8), width: 3)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: Colors.blue.withOpacity(0.8), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// New class to create the cutout
class ScannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a path that covers the whole screen
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate the square in the center
    const scannerSize = 300.0;
    final left = (size.width - scannerSize) / 2;
    final top = (size.height - scannerSize) / 2;

    // Cut out the center square by using a subpath with evenOdd fill type
    path.fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromLTWH(left, top, scannerSize, scannerSize));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ScannerPatternPainter extends CustomPainter {
  final int seed;

  ScannerPatternPainter([this.seed = 0]);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw horizontal scan lines
    for (var i = 0; i < size.height; i += 10) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw vertical scan lines
    for (var i = 0; i < size.width; i += 10) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    // Add some focus points
    final highlightPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw random focus points
    final random = seed > 0 ? seed : DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10; i++) {
      final x = ((random + i * 127) % size.width.toInt()).toDouble();
      final y = ((random + i * 231) % size.height.toInt()).toDouble();
      final dotSize = (((random + i) % 5) + 2).toDouble();
      canvas.drawCircle(Offset(x, y), dotSize, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScannerPatternPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

// New class to create a rectangular cutout for barcode scanning
class BarcodeScannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Create a path that covers the whole screen
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate a rectangle in the center for barcode
    const scannerWidth = 280.0;
    const scannerHeight = 100.0;
    final left = (size.width - scannerWidth) / 2;
    final top = (size.height - scannerHeight) / 2;

    // Cut out the rectangle using evenOdd fill type
    path.fillType = PathFillType.evenOdd;
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scannerWidth, scannerHeight),
        const Radius.circular(8)));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
