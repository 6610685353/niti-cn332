import 'package:flutter/material.dart';
import '../models/repair_request_model.dart';
import 'dart:io';

class RepairRequestProvider extends ChangeNotifier {
  // เก็บข้อมูลทั้งหมดไว้ในเครื่องหมาย _ (private)
  RepairRequestModel _requestData = RepairRequestModel();

  // ตัวควบคุมหน้าปัจจุบัน (0 = Details, 1 = Schedule, 2 = Confirm)
  int _currentStep = 0;

  // Getters
  RepairRequestModel get requestData => _requestData;
  int get currentStep => _currentStep;

  // ฟังก์ชันอัปเดตข้อมูลหน้าที่ 1 (Details)
  void updateDetails({
    String? category,
    String? title,
    String? description,
    String? location,
    List<File>? images,
  }) {
    _requestData = _requestData.copyWith(
      category: category,
      title: title,
      description: description,
      location: location,
      images: images,
    );
    notifyListeners(); // แจ้งเตือน UI ให้วาดใหม่
  }

  // ฟังก์ชันอัปเดตข้อมูลหน้าที่ 2 (Schedule)
  void updateSchedule(DateTime date, String timeSlot) {
    _requestData = _requestData.copyWith(
      selectedDate: date,
      selectedTimeSlot: timeSlot,
    );
    notifyListeners();
  }

  // ฟังก์ชันจัดการ Step การทำงาน
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // ฟังก์ชันสุดท้ายเมื่อกดยืนยัน (Submit)
  Future<bool> submitRequest() async {
    try {
      // ตรงนี้ใส่ Logic การยิง API ไปหลังบ้าน
      print(
        "Submitting: ${_requestData.title} at ${_requestData.selectedTimeSlot}",
      );

      // จำลองการหน่วงเวลา
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ล้างข้อมูลเพื่อเริ่มใหม่
  void reset() {
    _requestData = RepairRequestModel();
    _currentStep = 0;
    notifyListeners();
  }
}
