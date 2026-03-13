import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(24), // ความมนเท่าเดิม
        // ✅ 1. เอา boxShadow ออก และใส่ border สีเทาอ่อนแทน
        border: Border.all(
          color: Colors.grey.shade200, // สีเทาอ่อนๆ นุ่มๆ
          width: 1.0,
        ),
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
                  color: Colors.blueGrey,
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
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Colors.blueGrey.shade300,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.blueGrey.shade300,
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
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
        onPressed: () {
          // ใส่ Logic
        },
        // ✅ 2. เปลี่ยนไอคอนและสีปุ่มให้ดู Outlined ขึ้น (ตามความชอบส่วนใหญ่ของดีไซน์นี้)
        icon: const Icon(
          Icons.edit_outlined,
          size: 18,
          color: Color(0xFF1565C0),
        ),
        label: const Text(
          'Update your progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F7FF), // สีฟ้าอ่อนมาก
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                // ✅ 3. ใส่เส้นขอบให้ปุ่มด้วยเพื่อให้รับกับตัวการ์ด
                side: const BorderSide(color: Color(0xFFD0E3FF), width: 1),
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith<double>(
                (states) => 0.0,
              ),
            ),
      ),
    );
  }
}
