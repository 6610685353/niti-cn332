// lib/resident/features/repair_request/provider/repair_request_provider.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/repair_request_model.dart';
import '../../../core/app_config.dart';

class RepairRequestProvider extends ChangeNotifier {
  RepairRequestModel _requestData = RepairRequestModel();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Upload progress ─────────────────────────────────────────────────────
  /// จำนวนรูปที่ upload เสร็จแล้ว (สำหรับแสดง progress)
  int _uploadedImageCount = 0;
  int get uploadedImageCount => _uploadedImageCount;

  // Getters
  RepairRequestModel get requestData => _requestData;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Update data ────────────────────────────────────────────────────────

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
    notifyListeners();
  }

  void updateSchedule(DateTime date, String timeSlot) {
    _requestData = _requestData.copyWith(
      selectedDate: date,
      selectedTimeSlot: timeSlot,
    );
    notifyListeners();
  }

  // ── Step navigation ────────────────────────────────────────────────────

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

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<bool> submitRequest() async {
    _isLoading = true;
    _errorMessage = null;
    _uploadedImageCount = 0;
    notifyListeners();

    try {
      // 1. ดึง UID จาก Firebase Auth
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('ยังไม่ได้ Login กรุณา Login ก่อน');

      // 2. แปลง Category
      const categoryMap = {
        'Plumbing': 'plumbing',
        'Electric': 'electric',
        'HVAC': 'hvac',
        'Other': 'other',
      };
      final backendCategory = categoryMap[_requestData.category];
      if (backendCategory == null) {
        throw Exception('Category ไม่ถูกต้อง: ${_requestData.category}');
      }

      // 3. แปลง Time Slot
      if (_requestData.selectedTimeSlot == null ||
          !_requestData.selectedTimeSlot!.contains(' - ')) {
        throw Exception('กรุณาเลือกช่วงเวลา');
      }
      final timeParts = _requestData.selectedTimeSlot!.split(' - ');
      final startTime = '${timeParts[0].trim()}:00';
      final endTime = '${timeParts[1].trim()}:00';

      // 4. แปลง Date
      if (_requestData.selectedDate == null)
        throw Exception('กรุณาเลือกวันที่');
      final targetDate = DateFormat(
        'yyyy-MM-dd',
      ).format(_requestData.selectedDate!);

      // 5. POST สร้าง Ticket
      final body = {
        'req_user_id': uid,
        'category': backendCategory,
        'title': _requestData.title.trim(),
        'detail_desc': _requestData.description.trim().isEmpty
            ? null
            : _requestData.description.trim(),
        'in_unit_location': _requestData.location,
        'target_date': targetDate,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tickets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorDetail = 'เกิดข้อผิดพลาด (${response.statusCode})';
        try {
          final errorBody = jsonDecode(response.body);
          errorDetail = errorBody['detail']?.toString() ?? errorDetail;
        } catch (_) {}
        throw Exception(errorDetail);
      }

      // 6. Upload รูปภาพ (ถ้ามี)
      if (_requestData.images.isNotEmpty) {
        final ticketData = jsonDecode(response.body);
        final ticketId = ticketData['id'] as int;

        final imageErrors = await _uploadImages(ticketId, _requestData.images);
        if (imageErrors.isNotEmpty) {
          // Ticket สร้างสำเร็จแล้ว แต่รูปบางรูป upload ไม่ได้
          // Log ไว้แต่ไม่ throw (ไม่อยากให้ user ต้องทำใหม่ทั้งหมด)
          debugPrint('[RepairRequest] Image upload errors: $imageErrors');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Image upload ───────────────────────────────────────────────────────

  /// อัปโหลดรูปทีละรูป ไปที่ POST /tickets/{ticketId}/images
  /// คืนค่า list ของ error messages (ถ้าสำเร็จทั้งหมด จะ return [])
  Future<List<String>> _uploadImages(int ticketId, List<File> images) async {
    final errors = <String>[];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      try {
        // ตรวจสอบว่าไฟล์ยังอยู่
        if (!await file.exists()) {
          errors.add('รูปที่ ${i + 1}: ไม่พบไฟล์');
          continue;
        }

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${AppConfig.baseUrl}/tickets/$ticketId/images'),
        );

        // ระบุ content type ตาม extension
        final ext = file.path.split('.').last.toLowerCase();
        final mimeType = ext == 'png'
            ? 'image/png'
            : ext == 'webp'
            ? 'image/webp'
            : 'image/jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            // contentType: MediaType.parse(mimeType), // ต้อง import http_parser ถ้าจะใช้
          ),
        );

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout'),
        );
        final res = await http.Response.fromStream(streamedResponse);

        if (res.statusCode == 200 || res.statusCode == 201) {
          _uploadedImageCount++;
          notifyListeners();
          debugPrint(
            '[RepairRequest] Uploaded image ${i + 1}/${images.length} for ticket $ticketId',
          );
        } else {
          errors.add('รูปที่ ${i + 1}: server ตอบ ${res.statusCode}');
          debugPrint(
            '[RepairRequest] Image ${i + 1} upload failed: ${res.statusCode} ${res.body}',
          );
        }
      } catch (e) {
        errors.add('รูปที่ ${i + 1}: $e');
        debugPrint('[RepairRequest] Image ${i + 1} upload error: $e');
      }
    }

    return errors;
  }

  // ── Image management ───────────────────────────────────────────────────

  void addImage(File image) {
    if (_requestData.images.length < 4) {
      final updated = List<File>.from(_requestData.images)..add(image);
      _requestData = _requestData.copyWith(images: updated);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    final updated = List<File>.from(_requestData.images)..removeAt(index);
    _requestData = _requestData.copyWith(images: updated);
    notifyListeners();
  }

  // ── Validation ─────────────────────────────────────────────────────────

  bool get isStep1Valid {
    return _requestData.category.isNotEmpty &&
        _requestData.title.trim().isNotEmpty &&
        _requestData.description.trim().isNotEmpty &&
        _requestData.location.isNotEmpty;
  }

  bool get isStep2Valid {
    return _requestData.selectedDate != null &&
        (_requestData.selectedTimeSlot != null &&
            _requestData.selectedTimeSlot!.isNotEmpty);
  }

  bool get canMoveToNext {
    if (_currentStep == 0) return isStep1Valid;
    if (_currentStep == 1) return isStep2Valid;
    return true;
  }

  // ── Reset ──────────────────────────────────────────────────────────────

  void reset() {
    _requestData = RepairRequestModel();
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    _uploadedImageCount = 0;
    notifyListeners();
  }
}
