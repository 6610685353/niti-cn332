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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // Horizontal Date Selector
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().add(Duration(days: index));
                bool isSelected = data.selectedDate?.day == date.day;

                return GestureDetector(
                  onTap: () => provider.updateSchedule(
                    date,
                    data.selectedTimeSlot ?? "",
                  ),
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
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
                        const SizedBox(height: 5),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 18,
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
          _buildTimeSection(context, "☀️ Morning", [
            "09:00 - 11:00",
            "11:00 - 13:00",
          ], provider),
          const SizedBox(height: 20),
          _buildTimeSection(context, "🌇 Afternoon", [
            "13:00 - 15:00",
            "15:00 - 17:00",
            "17:00 - 19:00",
          ], provider),
        ],
      ),
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    String title,
    List<String> slots,
    RepairRequestProvider provider,
  ) {
    String? selectedSlot = provider.requestData.selectedTimeSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) {
            bool isSelected = selectedSlot == slot;
            bool isFull = slot == "13:00 - 15:00"; // สมมติว่าห้องนี้เต็ม

            return GestureDetector(
              onTap: isFull
                  ? null
                  : () => provider.updateSchedule(
                      provider.requestData.selectedDate ?? DateTime.now(),
                      slot,
                    ),
              child: Container(
                width: (MediaQuery.of(context).size.width / 2) - 30,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isFull ? Colors.grey : Colors.black,
                      ),
                    ),
                    Text(
                      isFull ? "Fully Booked" : "Available",
                      style: TextStyle(
                        fontSize: 10,
                        color: isFull ? Colors.red : Colors.blue,
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
