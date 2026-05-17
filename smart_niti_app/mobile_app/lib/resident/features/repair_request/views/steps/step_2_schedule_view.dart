import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // อย่าลืมเพิ่ม intl: ^0.18.0 ใน pubspec.yaml
import '../../provider/repair_request_provider.dart';

class Step2ScheduleView extends StatelessWidget {
  const Step2ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairRequestProvider>();
    final data = provider.requestData;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Date",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Horizontal Date Selector
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().add(Duration(days: index));
                bool isSelected = data.selectedDate?.day == date.day;

                return GestureDetector(
                  onTap: () => provider.updateSchedule(
                    date,
                    data.selectedTimeSlot ?? "",
                  ),
                  child: Container(
                    width: 68,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isSelected ? 0.1 : 0.05,
                          ),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),
          _buildTimeSection(
            context,
            "Morning", // ชื่ออย่างเดียว
            Icons.wb_sunny, // ส่ง Icon เข้าไป
            ["09:00 - 11:00", "11:00 - 13:00"],
            provider,
          ),

          const SizedBox(height: 25), // เพิ่ม gap เล็กน้อย

          _buildTimeSection(
            context,
            "Afternoon", // ชื่ออย่างเดียว
            Icons.wb_twilight_rounded, // ส่ง Icon เข้าไป
            ["13:00 - 15:00", "15:00 - 17:00", "17:00 - 19:00"],
            provider,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    String title,
    IconData sectionIcon, // เพิ่ม parameter รับ Icon
    List<String> slots,
    RepairRequestProvider provider,
  ) {
    String? selectedSlot = provider.requestData.selectedTimeSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ส่วนหัวข้อใหม่ที่มี Icon และขนาดใหญ่ขึ้น
        Row(
          children: [
            Icon(
              sectionIcon,
              color: const Color(0xFFF59E0B),
              size: 22,
            ), // สีเหลืองทอง/ส้ม
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18, // ปรับขนาดตามต้องการ
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B), // สี Slate 800
              ),
            ),
          ],
        ),

        const SizedBox(height: 16), // เพิ่มช่องว่างระหว่างหัวข้อกับรายการ

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) {
            bool isSelected = selectedSlot == slot;
            bool isFull = false;

            return GestureDetector(
              onTap: isFull
                  ? null
                  : () => provider.updateSchedule(
                      provider.requestData.selectedDate ?? DateTime.now(),
                      slot,
                    ),
              child: Container(
                width:
                    (MediaQuery.of(context).size.width / 2) -
                    26, // ปรับให้พอดีขึ้น
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEFF6FF)
                      : Colors.white, // ฟ้าอ่อนมาก
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFF1F5F9),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFull ? Colors.grey : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFull ? "• Fully Booked" : "• Available",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isFull ? Colors.red : const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
