import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';
import 'complaint_item.dart';

class RecentComplaintsCard extends StatelessWidget {
  const RecentComplaintsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Complaints",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ตัวอย่างการเรียกใช้ Widget ที่แยกออกมา
          const ComplaintItem(
            unit: "Unit 402B",
            category: "Plumbing",
            title: "Severe kitchen leak",
            description: "Water is pooling under the sink area...",
            userName: "Sarah Jenkins",
            timeAgo: "2 mins ago",
            status: "Urgent",
            statusColor: Colors.red,
          ),

          const ComplaintItem(
            unit: "Unit 112",
            category: "Electrical",
            title: "Flickering corridor lights",
            description: "The lights near the entrance keep blinking...",
            userName: "Marcus Chen",
            timeAgo: "45 mins ago",
            status: "Normal",
            statusColor: Colors.orange,
          ),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "View All Complaint Tickets",
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
