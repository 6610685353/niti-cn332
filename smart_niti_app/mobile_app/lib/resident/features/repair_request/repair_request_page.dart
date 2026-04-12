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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
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
        backgroundColor: Color(0xFFF8FAFC),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // เรียกใช้ Stepper ตรงนี้ (Provider เริ่มที่ 0 แต่ Stepper เราเริ่มโชว์ที่ 1)
          RepairStepper(currentStep: provider.currentStep + 1),

          Expanded(
            child: IndexedStack(
              index: provider.currentStep,
              children: const [
                Step1DetailsView(), // หน้ากรอกรายละเอียด
                Step2ScheduleView(), // หน้าเลือกวันเวลา
                Step3ConfirmView(), // หน้าสรุป
              ],
            ),
          ),

          // ปุ่มด้านล่าง
          RepairBottomButton(
            currentStep: provider.currentStep,
            onPressed: () {
              // เช็คก่อนว่า Step ปัจจุบันกรอกครบหรือยัง
              if (provider.canMoveToNext) {
                if (provider.currentStep < 2) {
                  provider.nextStep();
                } else {
                  provider.submitRequest();
                }
              } else {
                // ถ้าไม่ครบ ให้โชว์ SnackBar เตือน
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in all required fields"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
