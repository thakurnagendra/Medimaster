import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/agent_wise_billing_and_summary/agent_wise_billing_screen.dart';
import 'package:medimaster/screens/lab/Lab_report_Menus/agent_wise_billing_and_summary/agent_wise_summary_screen.dart';

class AgentWiseSelectionDialog extends StatelessWidget {
  const AgentWiseSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agent Wise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  'Summary',
                  Icons.summarize,
                  () => Get.off(() => const AgentWiseSummaryScreen()),
                ),
                _buildOptionButton(
                  context,
                  'Billing',
                  Icons.receipt_long,
                  () => Get.off(() => const AgentWiseBillingScreen()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
