import 'package:flutter/material.dart';
import 'package:mobile_app/resident/features/repair_request/provider/repair_request_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/repair_stepper.dart';
import './views/steps/step_1_details_view.dart';
import './views/steps/step_2_schedule_view.dart';
import './views/steps/step_3_confirm_view.dart';
import './widgets/repair_bottom_button.dart';

class RepairRequestPage extends StatelessWidget {
  const RepairRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairRequestProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: provider.isLoading
              ? null // ล็อคปุ่ม Back ระหว่างกำลัง Submit
              : () {
                  if (provider.currentStep > 0) {
                    provider.previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
        title: const Text(
          "e-Repair Request",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          RepairStepper(currentStep: provider.currentStep + 1),

          Expanded(
            child: IndexedStack(
              index: provider.currentStep,
              children: const [
                Step1DetailsView(),
                Step2ScheduleView(),
                Step3ConfirmView(),
              ],
            ),
          ),

          // ปุ่มด้านล่าง — รับ isLoading เข้าไปด้วย
          RepairBottomButton(
            currentStep: provider.currentStep,
            isLoading: provider.isLoading,
            onPressed: () => _handleButtonPress(context, provider),
          ),
        ],
      ),
    );
  }

  Future<void> _handleButtonPress(
    BuildContext context,
    RepairRequestProvider provider,
  ) async {
    // ไม่ทำอะไรถ้ากำลัง Loading อยู่
    if (provider.isLoading) return;

    if (!provider.canMoveToNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกข้อมูลให้ครบถ้วน"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ถ้ายังไม่ถึง Step สุดท้าย → ไป Step ถัดไป
    if (provider.currentStep < 2) {
      provider.nextStep();
      return;
    }

    // Step สุดท้าย → Submit ไป Backend
    final success = await provider.submitRequest();

    if (!context.mounted) return;

    if (success) {
      _showSuccessDialog(context, provider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog(
    BuildContext context,
    RepairRequestProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "ส่งคำขอแจ้งซ่อมแล้ว!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "เจ้าหน้าที่จะติดต่อกลับภายใน 24 ชั่วโมง",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.reset();
                  Navigator.of(context)
                    ..pop() // ปิด Dialog
                    ..pop(); // กลับหน้าก่อนหน้า
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "กลับหน้าหลัก",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
