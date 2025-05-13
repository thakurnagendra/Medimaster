import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/models/send_report_model.dart';
import 'package:medimaster/services/report_service.dart';

class SendReportScreen extends StatefulWidget {
  final int printId;

  const SendReportScreen({Key? key, required this.printId}) : super(key: key);

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ReportService _reportService = Get.put(ReportService());

  // Default method is Email (1)
  int _selectedSendMethod = 1;
  bool _usePatientContact = true;
  bool _sendToClient = true;
  bool _sendToDoctor = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  // Send the report
  Future<void> _sendReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reportModel = SendReportModel(
        id: widget.printId,
        sendMethod: _selectedSendMethod,
        recipientAddress: _recipientController.text.trim(),
        usePatientContact: _usePatientContact,
        sendToClient: _sendToClient,
        sendToDoctor: _sendToDoctor,
      );

      final success = await _reportService.sendReport(reportModel);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Report sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to send report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  String _getHintText() {
    switch (_selectedSendMethod) {
      case 1:
        return 'Email address';
      case 2:
      case 3:
        return 'Phone number';
      default:
        return 'Recipient address';
    }
  }

  String? _validateRecipient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a recipient';
    }

    switch (_selectedSendMethod) {
      case 1: // Email
        // Simple email validation
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case 2: // WhatsApp
      case 3: // SMS
        // Simple phone number validation
        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Report'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Method',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Send Method Selection
                Card(
                  child: Column(
                    children: [
                      RadioListTile<int>(
                        title: const Row(
                          children: [
                            Icon(Icons.email, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Email'),
                          ],
                        ),
                        value: 1,
                        groupValue: _selectedSendMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedSendMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Row(
                          children: [
                            // Use chat icon for WhatsApp instead
                            Icon(Icons.chat, color: Colors.green),
                            SizedBox(width: 8),
                            Text('WhatsApp'),
                          ],
                        ),
                        value: 2,
                        groupValue: _selectedSendMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedSendMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: const Row(
                          children: [
                            Icon(Icons.sms, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('SMS'),
                          ],
                        ),
                        value: 3,
                        groupValue: _selectedSendMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedSendMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recipient field
                TextFormField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: 'Recipient',
                    hintText: _getHintText(),
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      _selectedSendMethod == 1 ? Icons.email : Icons.phone,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  keyboardType: _selectedSendMethod == 1
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  validator: _validateRecipient,
                ),
                const SizedBox(height: 24),

                // Options
                const Text(
                  'Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Use Patient Contact'),
                        subtitle:
                            const Text('Use patient\'s contact information'),
                        value: _usePatientContact,
                        onChanged: (value) {
                          setState(() {
                            _usePatientContact = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Send to Client'),
                        subtitle: const Text('Send a copy to the client'),
                        value: _sendToClient,
                        onChanged: (value) {
                          setState(() {
                            _sendToClient = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Send to Doctor'),
                        subtitle: const Text('Send a copy to the doctor'),
                        value: _sendToDoctor,
                        onChanged: (value) {
                          setState(() {
                            _sendToDoctor = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'SEND REPORT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
