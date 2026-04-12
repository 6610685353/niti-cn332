import 'package:flutter/material.dart';

class RepairStepper extends StatelessWidget {
  final int currentStep; // 1, 2, หรือ 3

  const RepairStepper({super.key, required this.currentStep});

  @override
  @override
  Widget build(BuildContext context) {
    // คำนวณความยาวของเส้นสีเข้ม (0.0 ถึง 1.0)
    // Step 1: 0% (0.0)
    // Step 2: 50% (0.5)
    // Step 3: 100% (1.0)
    double progress = (currentStep - 1) / 2;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Stack(
        children: [
          // 1. เส้นพื้นหลัง (สีเทา)
          Positioned(
            top: 15,
            left: 20,
            right: 20,
            child: Container(
              height: 2, // เพิ่มความหนาเล็กน้อยให้เห็นชัด
              color: Colors.grey.shade200,
            ),
          ),

          // 2. เส้นสีเข้ม (Active Line)
          Positioned(
            top: 15,
            left: 20,
            right: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    // ใช้ Animated เพื่อให้เส้นค่อยๆ เลื่อน
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    height: 2,
                    color: const Color(0xFF0F172A),
                  ),
                );
              },
            ),
          ),

          // 3. วงกลมและตัวหนังสือ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepCircle(1, "Details"),
              _buildStepCircle(2, "Schedule"),
              _buildStepCircle(3, "Confirm"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = step <= currentStep;
    bool isCurrent = step == currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E293B) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF1E293B) : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF0F172A) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
