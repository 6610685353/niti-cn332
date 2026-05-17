// lib/resident/core/user_data_notifier.dart
//
// Shared user-data state ที่ทั้ง HomePage และ ProfilePage ใช้ร่วมกัน
// เมื่อ fetch หรือ update ข้อมูล → notifyListeners() ให้ทุก widget rebuild
// โดยอัตโนมัติ (realtime within-session)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

class UserDataNotifier extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Convenient getters ────────────────────────────────────────────────────

  String get displayName {
    if (_userData != null) {
      final fn = (_userData!['first_name'] ?? '') as String;
      final ln = (_userData!['last_name'] ?? '') as String;
      final full = '$fn $ln'.trim();
      if (full.isNotEmpty) return full;
    }
    return FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  String? get imageUrl => _userData?['image_url'] as String?;

  /// ตึก (building) เช่น "A", "B"
  String? get building => _userData?['building'] as String?;

  /// เลขห้อง เช่น "402"
  String? get roomNo => _userData?['room_no'] as String?;

  String? get role => _userData?['role'] as String?;

  String get memberSince {
    final createdAt = _userData?['created_at'];
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt as String);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  // ── Fetch from backend ────────────────────────────────────────────────────

  Future<void> fetchUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'ไม่พบข้อมูล User';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Optimistic fallback: ใช้ Firebase displayName ทันทีก่อน API ตอบ
      if (_userData == null) {
        _userData = {'first_name': user.displayName ?? '', 'last_name': ''};
        notifyListeners();
      }

      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/users/${user.uid}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _error = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (_) {
      // ถ้า offline ให้คงข้อมูลเดิมไว้
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Partial updates (ไม่ต้อง refetch ทั้งหมด) ────────────────────────────

  /// เรียกหลัง upload avatar สำเร็จ
  void updateImageUrl(String url) {
    _userData ??= {};
    _userData!['image_url'] = url;
    notifyListeners();
  }
}
