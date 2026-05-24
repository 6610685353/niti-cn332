// lib/resident/core/user_avatar_notifier.dart
//
// Global ValueNotifier สำหรับ sync รูป avatar ระหว่าง ProfilePage ↔ HomeHeader
// โดยไม่ต้องใช้ state management library

import 'package:flutter/foundation.dart';

/// เก็บ signed URL ของรูป avatar ปัจจุบัน
/// - null  = ยังไม่โหลด / ไม่มีรูป
/// - ""    = ลบรูปแล้ว (แสดง initial แทน)
/// - URL   = มีรูป
final ValueNotifier<String?> userAvatarNotifier = ValueNotifier<String?>(null);
