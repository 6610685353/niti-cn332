import 'package:flutter/material.dart';

class RepairBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int currentStep;
  final bool isLoading; // รับสถานะ Loading เข้ามาด้วย

  const RepairBottomButton({
    super.key,
    required this.onPressed,
    required this.currentStep,
    this.isLoading = false,
  });

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
          // ถ้า isLoading ให้ปุ่มกดไม่ได้
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF94A3B8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: isLoading
              // แสดง Loading Spinner เมื่อกำลัง Submit
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getButtonText(),
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
