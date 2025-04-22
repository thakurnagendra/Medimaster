import 'package:flutter/material.dart';
import 'package:medimaster/constant/app_constant_colors.dart';

class WelcomeCard extends StatelessWidget {
  final String doctorName;
  final String message;

  const WelcomeCard({
    super.key,
    this.doctorName = "Dr. Sarah",
    this.message = "Have a great day ahead",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppConstantColors.greyLight,
        image: DecorationImage(
          image: AssetImage('assets/lab/lab-welcome.png'),
          fit: BoxFit.contain,
          opacity: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $doctorName!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstantColors.primaryColor,
                          ),
                        ),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstantColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
