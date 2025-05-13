import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:medimaster/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:medimaster/config/api_config.dart';
import 'package:medimaster/screens/lab/send_report_screen.dart';

class PDFViewerUtil {
  static final ApiService _apiService = Get.find<ApiService>();

  // Show loading dialog
  static void _showLoading() {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading Report..."),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show error dialog
  static void _showError(String message) {
    Get.back(); // Close loading dialog
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      duration: const Duration(seconds: 3),
    );
  }

  // View PDF from print ID
  static Future<void> viewLabReport(int printId, {int groupId = 0}) async {
    _showLoading();

    try {
      // Get the response from API
      final dynamic response =
          await _apiService.getLabReportPdfUrl(printId, groupId: groupId);

      if (response == null) {
        _showError("Failed to load report. Report data not found.");
        return;
      }

      print('Response type: ${response.runtimeType}');

      Uint8List? pdfBytes;

      // Handle different response formats
      if (response is String) {
        // Log a sample of the response to debug
        print(
            'Response preview: ${response.length > 100 ? "${response.substring(0, 100)}..." : response}');

        // Try to detect if it's a direct base64 string first
        if (_isBase64(response)) {
          try {
            // Clean the base64 string of whitespace and possible prefix
            String cleanBase64 = _cleanBase64String(response);
            pdfBytes = base64Decode(cleanBase64);
            print(
                'Successfully decoded direct base64 data: ${pdfBytes.length} bytes');
          } catch (e) {
            print('Error decoding direct base64: $e');
          }
        }

        // If base64 decoding failed, check if it's a direct PDF in binary form
        if (pdfBytes == null &&
            (response.startsWith('%PDF') || response.contains('\x00'))) {
          // Likely a direct PDF file in binary form
          pdfBytes = Uint8List.fromList(response.codeUnits);
          print('Detected binary PDF data: ${pdfBytes.length} bytes');
        }

        // Check if it's JSON
        if (pdfBytes == null &&
            (response.trim().startsWith('{') ||
                response.trim().startsWith('['))) {
          try {
            // Handle both object and array JSON formats
            dynamic jsonData;
            if (response.trim().startsWith('[')) {
              final List<dynamic> jsonArray = json.decode(response);
              if (jsonArray.isNotEmpty &&
                  jsonArray[0] is Map<String, dynamic>) {
                jsonData = jsonArray[0];
              }
            } else {
              jsonData = json.decode(response);
            }

            if (jsonData is Map) {
              // Print JSON keys for debugging
              print('JSON keys: ${(jsonData).keys.join(', ')}');

              // Extract base64 data from JSON
              // Check all common field names for base64 data
              final List<String> possibleFields = [
                'data',
                'pdfData',
                'base64',
                'content',
                'encodedData',
                'fileData',
                'file',
                'document',
                'pdf'
              ];

              String? base64Data;

              for (String field in possibleFields) {
                if (jsonData.containsKey(field) &&
                    jsonData[field] != null &&
                    jsonData[field].toString().isNotEmpty) {
                  base64Data = jsonData[field].toString();
                  print('Found base64 data in field: $field');
                  break;
                }
              }

              // If no specific field was found, check if the entire JSON is the base64 string
              if (base64Data == null && _isBase64(jsonData.toString())) {
                base64Data = jsonData.toString();
                print('Using entire JSON as base64');
              }

              if (base64Data != null && base64Data.isNotEmpty) {
                try {
                  String cleanBase64 = _cleanBase64String(base64Data);
                  pdfBytes = base64Decode(cleanBase64);
                  print(
                      'Successfully decoded base64 from JSON: ${pdfBytes.length} bytes');
                } catch (e) {
                  print('Error decoding base64 from JSON: $e');
                }
              }
            }
          } catch (e) {
            print('Error processing JSON response: $e');

            // As a last resort, try to extract a base64 string directly from the response
            // This handles cases where the JSON might not be valid but contains base64 data
            final RegExp base64Pattern = RegExp(r'"([A-Za-z0-9+/=]{30,})"');
            final match = base64Pattern.firstMatch(response);
            if (match != null) {
              try {
                final extractedBase64 = match.group(1)!;
                print('Extracted base64 using regex pattern');
                String cleanBase64 = _cleanBase64String(extractedBase64);
                pdfBytes = base64Decode(cleanBase64);
                print(
                    'Successfully decoded extracted base64: ${pdfBytes.length} bytes');
              } catch (e) {
                print('Error decoding extracted base64: $e');
              }
            }
          }
        }
      } else if (response is Uint8List) {
        // Direct binary data
        pdfBytes = response;
        print('Received direct Uint8List: ${pdfBytes.length} bytes');
      } else if (response is List<int>) {
        // List of bytes
        pdfBytes = Uint8List.fromList(response);
        print('Converted List<int> to Uint8List: ${pdfBytes.length} bytes');
      } else if (response is Map) {
        // Print Map keys for debugging
        print('Map keys: ${response.keys.join(', ')}');

        // Try to extract base64 string from Map
        final Map<dynamic, dynamic> responseMap = response;
        // Check all common field names for base64 data
        final List<String> possibleFields = [
          'data',
          'pdfData',
          'base64',
          'content',
          'encodedData',
          'fileData',
          'file',
          'document',
          'pdf'
        ];

        String? base64Data;

        for (String field in possibleFields) {
          if (responseMap.containsKey(field) &&
              responseMap[field] != null &&
              responseMap[field].toString().isNotEmpty) {
            base64Data = responseMap[field].toString();
            print('Found base64 data in field: $field');
            break;
          }
        }

        if (base64Data != null && base64Data.isNotEmpty) {
          try {
            String cleanBase64 = _cleanBase64String(base64Data);
            pdfBytes = base64Decode(cleanBase64);
            print(
                'Successfully decoded base64 from Map: ${pdfBytes.length} bytes');
          } catch (e) {
            print('Error decoding base64 from Map: $e');
          }
        }
      }

      // If we still don't have PDF bytes, try to download the PDF directly with auth
      if (pdfBytes == null || pdfBytes.isEmpty) {
        try {
          // Make a direct HTTP request to the endpoint with proper authorization
          final http.Response directResponse =
              await _apiService.getRawPdf(printId, groupId);

          if (directResponse.statusCode == 200) {
            if (directResponse.headers['content-type']
                    ?.contains('application/pdf') ??
                false) {
              pdfBytes = directResponse.bodyBytes;
              print(
                  'Successfully downloaded PDF directly: ${pdfBytes.length} bytes');
            } else {
              // If not PDF, try to decode as JSON containing base64
              try {
                final dynamic jsonData = json.decode(directResponse.body);
                if (jsonData is Map) {
                  // Extract base64 data
                  for (final key in jsonData.keys) {
                    final value = jsonData[key];
                    if (value is String && _isBase64(value)) {
                      String cleanBase64 = _cleanBase64String(value);
                      pdfBytes = base64Decode(cleanBase64);
                      print(
                          'Found base64 data in direct response JSON field: $key');
                      break;
                    }
                  }
                }
              } catch (e) {
                print('Error processing direct JSON response: $e');
              }
            }
          } else {
            print(
                'Failed to download PDF directly: ${directResponse.statusCode}');
            // Try one more fallback - if the direct response contains base64 data
            if (directResponse.statusCode == 401) {
              print(
                  'Auth issue detected (401). Checking if initial response contains base64 data');
              // Look for long base64-like strings in the initial response
              if (response is String) {
                final RegExp base64Pattern = RegExp(r'"([A-Za-z0-9+/=]{30,})"');
                final matches = base64Pattern.allMatches(response);
                for (final match in matches) {
                  try {
                    final extractedBase64 = match.group(1)!;
                    String cleanBase64 = _cleanBase64String(extractedBase64);
                    final testBytes = base64Decode(cleanBase64);

                    // Check if this looks like PDF data
                    if (testBytes.length > 100) {
                      pdfBytes = testBytes;
                      print(
                          'Found likely PDF base64 data in original response: ${pdfBytes.length} bytes');
                      break;
                    }
                  } catch (e) {
                    // Continue to next match
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error downloading PDF directly: $e');
        }
      }

      // If we still don't have valid PDF bytes, show error
      if (pdfBytes == null || pdfBytes.isEmpty) {
        _showError("Failed to process report data. Please try again.");
        return;
      }

      // Validate PDF format (check for PDF header)
      if (!_isValidPDF(pdfBytes)) {
        print(
            'Warning: Data does not appear to be a valid PDF. First 20 bytes: ${pdfBytes.sublist(0, min(20, pdfBytes.length))}');
        // Continue anyway, since some PDFs might not have standard headers
      }

      // Create a temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = '$tempPath/report_$printId.pdf';

      // Write bytes to file
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Close loading dialog
      Get.back();

      // Navigate to PDF viewer
      Get.to(() => PDFScreen(filePath: filePath, printId: printId));
    } catch (e) {
      print('Error viewing lab report: $e');
      _showError(
          "Failed to load report. Please try again later. Error: ${e.toString()}");
    }
  }

  // Check if a string is likely base64 encoded
  static bool _isBase64(String str) {
    // Remove whitespace and any common prefixes
    final cleanStr = _cleanBase64String(str);

    if (cleanStr.isEmpty || cleanStr.length % 4 != 0) {
      return false;
    }

    // Check for base64 character set - allow for URL-safe base64 too
    final regex = RegExp(r'^[A-Za-z0-9+/\-_=]+$');
    return regex.hasMatch(cleanStr);
  }

  // Clean base64 string by removing whitespace and common prefixes
  static String _cleanBase64String(String base64Str) {
    // Remove whitespace
    String cleanStr = base64Str.replaceAll(RegExp(r'\s+'), '');

    // Remove common prefixes used in data URLs
    List<String> prefixes = [
      'data:application/pdf;base64,',
      'data:application/octet-stream;base64,',
      'data:;base64,',
      'base64,',
    ];

    for (String prefix in prefixes) {
      if (cleanStr.startsWith(prefix)) {
        cleanStr = cleanStr.substring(prefix.length);
        break;
      }
    }

    // Replace URL-safe base64 characters with standard base64
    cleanStr = cleanStr.replaceAll('-', '+').replaceAll('_', '/');

    // Adjust padding if needed
    while (cleanStr.length % 4 != 0) {
      cleanStr += '=';
    }

    return cleanStr;
  }

  // Check if data has a valid PDF header
  static bool _isValidPDF(Uint8List bytes) {
    if (bytes.length < 5) return false;

    // Check for PDF header '%PDF-'
    final header = String.fromCharCodes(bytes.sublist(0, 5));
    return header == '%PDF-';
  }

  // Get the minimum of two integers
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}

// PDF viewer screen
class PDFScreen extends StatelessWidget {
  final String filePath;
  final int printId;

  const PDFScreen({
    Key? key,
    required this.filePath,
    required this.printId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Report #$printId'),
        actions: [
          // Add Send Report button
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Send Report',
            onPressed: () {
              Get.to(() => SendReportScreen(printId: printId));
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          print('Error loading PDF: $error');
          Get.snackbar(
            'Error',
            'Could not load the report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
          );
        },
        onPageError: (page, error) {
          print('Error loading page $page: $error');
        },
      ),
    );
  }
}
