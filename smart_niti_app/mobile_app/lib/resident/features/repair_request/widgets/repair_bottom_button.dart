import 'package:flutter/material.dart';

class RepairBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int currentStep; // เปลี่ยนมารับเป็นเลข Step (0, 1, 2)

  const RepairBottomButton({
    super.key,
    required this.onPressed,
    required this.currentStep,
  });

  // ฟังก์ชันช่วยเลือกข้อความตาม Step
  String _getButtonText() {
    switch (currentStep) {
      case 0:
        return "Continue to Schedule";
      case 1:
        return "Continue to Confirmation";
      case 2:
        return "Confirm Your Request";
      default:
        return "Continue";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 28),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getButtonText(), // เรียกใช้ฟังก์ชันที่สร้างไว้
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
