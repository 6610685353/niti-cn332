import 'package:flutter/material.dart';
import 'package:technician_app/core/constants/app_color.dart';

class UpdateStatusBottomSheet extends StatelessWidget {
  const UpdateStatusBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Update Status',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Select the progress of this work order',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          // Option 1: Save and Update
          _buildOptionCard(
            title: 'Save and Update',
            subtitle:
                'Transition to the next stage and notify the resident of progress.',
            backgroundColor: AppColors.primary,
            titleColor: Colors.white,
            subtitleColor: Colors.white.withOpacity(0.8),
            borderColor: Colors.transparent,
          ),
          const SizedBox(height: 16),

          // Option 2: Finish & Close Job
          _buildOptionCard(
            title: 'Finish & Close Job',
            subtitle:
                'Submit final evidence, completion report and close work order.',
            backgroundColor: Colors.white,
            titleColor: const Color(0xFF0F172A),
            subtitleColor: Colors.grey.shade600,
            borderColor: Colors.grey.shade300,
          ),

          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}
