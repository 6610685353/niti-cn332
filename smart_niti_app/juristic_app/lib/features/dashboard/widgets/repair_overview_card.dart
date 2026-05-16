import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class RepairOverviewCard extends StatelessWidget {
  final int total;
  final int submitted;
  final int assigned;
  final int inProgress;
  final int done;

  const RepairOverviewCard({
    super.key,
    required this.total,
    required this.submitted,
    required this.assigned,
    required this.inProgress,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    // คำนวณ % จาก total (ป้องกัน div/0)
    double pct(int n) => total == 0 ? 0 : n / total;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "e-Repair Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── ฝั่งซ้าย: ตัวเลข Total ──
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$total",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Total",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── ฝั่งขวา: Progress Bars ──
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProgressBar(
                        "Pending Request",
                        pct(submitted),
                        AppColors.errorRed,
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        "Pending Approval",
                        pct(assigned),
                        AppColors.warningOrange,
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        "In Progress",
                        pct(inProgress),
                        AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        "Completed",
                        pct(done),
                        AppColors.successGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              "${(percent * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade100,
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
