import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class BarcodeScannerResultView extends StatelessWidget {
  final String scanResult;

  const BarcodeScannerResultView({super.key, required this.scanResult});

  bool get _isUrl {
    final urlPattern = RegExp(
      r'^(http:\/\/|https:\/\/)?' // optional protocol
      r'([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}([\/\w\-\.\?\=\&\%]*)*$', // domain and path
      caseSensitive: false,
    );
    return urlPattern.hasMatch(scanResult);
  }

  Future<void> _launchUrl() async {
    String url = scanResult.trim();

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorAndCopy();
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      String textToCopy = scanResult.trim();
      if (_isUrl && !textToCopy.startsWith('http')) {
        textToCopy = 'https://$textToCopy';
      }

      await Clipboard.setData(ClipboardData(text: textToCopy));
      HapticFeedback.mediumImpact();

      Get.snackbar(
        'Copied to Clipboard',
        textToCopy,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to copy text',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  void _showErrorAndCopy() {
    _copyToClipboard();
    Get.snackbar(
      'Could not open link',
      'Link copied to clipboard instead',
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isUrl ? 'URL Detected' : 'Scanned Result',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(scanResult),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Result Display
                InkWell(
                  onTap: _isUrl ? _launchUrl : null,
                  onLongPress: _copyToClipboard,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            _isUrl ? Colors.blue : AppConstantColors.labAccent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isUrl ? Icons.link : Icons.document_scanner,
                          color: _isUrl ? Colors.blue : Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          scanResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isUrl ? Colors.lightBlue : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration:
                                _isUrl ? TextDecoration.underline : null,
                          ),
                        ),
                        if (_isUrl)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap to open. Long press to copy.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUrl)
                      ElevatedButton.icon(
                        onPressed: _launchUrl,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.7),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.7),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(scanResult),
                  icon: const Icon(Icons.check),
                  label: const Text('Use This'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
