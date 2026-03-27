import 'package:flutter/material.dart';
import 'package:juristic_app/core/constants/app_colors.dart';

class RepairOverviewCard extends StatelessWidget {
  const RepairOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32), // Padding รอบนอกให้พอดีกับการ์ดอื่นๆ
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
          const SizedBox(height: 36), // ดันเนื้อหาลงมาให้มีพื้นที่หายใจ

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- ฝั่งซ้าย: 142 Total ---
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "142",
                      style: TextStyle(
                        fontSize: 48, // ตัวใหญ่
                        fontWeight: FontWeight.w800, // หนาพิเศษ
                        height: 1.0,
                        letterSpacing:
                            -1, // บีบช่องไฟตัวเลขให้ดูแน่นขึ้นแบบต้นฉบับ
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Total",
                      style: TextStyle(
                        color: Colors.grey.shade400, // สีเทาอ่อนๆ
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // --- ฝั่งขวา: แถบ Progress Bar 4 แถว ---
              Expanded(
                flex: 5, // ให้พื้นที่ฝั่งขวาเยอะกว่า เส้นจะได้ยาวสวย
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                  ), // เว้นระยะห่างจากตัวเลข 142
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // ให้ Column สูงพอดีกับเนื้อหา
                    children: [
                      _buildProgressBar(
                        "Pending Request",
                        0.25,
                        AppColors.errorRed,
                      ),
                      const SizedBox(height: 20), // ระยะห่างระหว่างแถวแบบเป๊ะๆ
                      _buildProgressBar(
                        "Pending Approval",
                        0.05,
                        AppColors.warningOrange,
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        "In Progress",
                        0.55,
                        AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 20),
                      _buildProgressBar(
                        "Completed",
                        0.15,
                        AppColors.successGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // เว้นระยะด้านล่างเผื่อไว้ให้สมดุล
        ],
      ),
    );
  }

  // Widget ย่อยสำหรับสร้างเส้นแต่ละเส้น
  Widget _buildProgressBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ส่วนจุดสีและข้อความ
            Row(
              children: [
                Container(
                  width: 6, // จุดเล็กๆ ตามต้นฉบับ
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
            // ส่วนตัวเลขเปอร์เซ็นต์
            Text(
              "${(percent * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8), // ระยะห่างระหว่างตัวหนังสือกับเส้น
        // ตัวเส้น Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // ขอบมน
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade100, // พื้นหลังสีเทาอ่อนมากๆ
            color: color,
            minHeight: 4, // ทำให้เส้น "บาง" ลงเหมือนใน Figma เป๊ะๆ
          ),
        ),
      ],
    );
  }
}
