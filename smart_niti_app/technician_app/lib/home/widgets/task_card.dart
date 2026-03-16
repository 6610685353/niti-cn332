import 'package:flutter/material.dart';
import '../../core/constants/app_color.dart';

class TaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String tag;
  final String time;
  final String location;
  final Color tagColor;

  const TaskCard({
    required this.id,
    required this.title,
    required this.tag,
    required this.time,
    required this.location,
    required this.tagColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bgLight, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'ID: $id',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
        label: const Text(
          'Update your progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
