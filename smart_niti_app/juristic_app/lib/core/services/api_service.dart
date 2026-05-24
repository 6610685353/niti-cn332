import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // 👈 1. อย่าลืม import firebase_auth

/// เปลี่ยน baseUrl ให้ตรงกับ IP/port ที่ backend รัน
/// เช่น ถ้ารันบนเครื่องเดียวกัน ใช้ http://localhost:8000
/// ถ้า Flutter Web ใช้ http://127.0.0.1:8000
/// ถ้าเป็น Android Emulator ใช้ http://10.0.2.2:8000
const String kBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:8000', // ใช้ตอนรัน local
);

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // 👈 2. เปลี่ยนจาก Map ธรรมดา เป็น Future function เพื่อให้ดึง Token ได้
  Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // ดึงผู้ใช้ปัจจุบันและขอ Token
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token'; // แนบ Token ไปกับ Header
      }
    }

    return headers;
  }

  // ─── Tickets ───────────────────────────────────────────────────

  /// ดึง ticket ทั้งหมด หรือกรองตาม req_user_id
  Future<List<Map<String, dynamic>>> getTickets({String? reqUserId}) async {
    final uri = Uri.parse('$kBaseUrl/tickets/').replace(
      queryParameters: reqUserId != null ? {'req_user_id': reqUserId} : null,
    );
    final headers = await getHeaders(); // 👈 3. เรียกใช้ Header ใหม่
    final res = await _client.get(uri, headers: headers);
    _checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// ดึง ticket เดี่ยวตาม id
  Future<Map<String, dynamic>> getTicket(int ticketId) async {
    final headers = await getHeaders();
    final res = await _client.get(
      Uri.parse('$kBaseUrl/tickets/$ticketId'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // api_service.dart — เพิ่มใต้ unassignTicket

  Future<List<Map<String, dynamic>>> getTicketImages(int ticketId) async {
    final headers = await getHeaders();
    final res = await _client.get(
      Uri.parse('$kBaseUrl/tickets/$ticketId/images'),
      headers: headers,
    );
    _checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  Future<String> getTicketImageSignedUrl(int ticketId, String filename) async {
    final headers = await getHeaders();
    final res = await _client.get(
      Uri.parse('$kBaseUrl/tickets/$ticketId/images/$filename'),
      headers: headers,
    );
    _checkStatus(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['signed_url'] as String;
  }

  /// อัปเดต status ของ ticket
  Future<Map<String, dynamic>> updateTicketStatus(
    int ticketId,
    String status,
  ) async {
    final headers = await getHeaders();
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/status?status=$status'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// ยกเลิก ticket
  Future<Map<String, dynamic>> cancelTicket(int ticketId) async {
    final headers = await getHeaders();
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/cancel'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─── Users ─────────────────────────────────────────────────────

  /// ดึงข้อมูล user ตาม uid
  Future<Map<String, dynamic>> getUser(String uid) async {
    final headers = await getHeaders();
    final res = await _client.get(
      Uri.parse('$kBaseUrl/users/$uid'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// ดึงรายชื่อ technician ทั้งหมด
  Future<List<Map<String, dynamic>>> getTechnicians() async {
    final uri = Uri.parse(
      '$kBaseUrl/users/',
    ).replace(queryParameters: {'role': 'technician'});

    final headers = await getHeaders();
    final res = await _client.get(uri, headers: headers);
    _checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// assign ticket ให้ช่าง
  Future<Map<String, dynamic>> assignTicket(
    int ticketId,
    String technicianId,
  ) async {
    final headers = await getHeaders();
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/assign'),
      headers: headers,
      body: jsonEncode({'technician_id': technicianId}),
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// unassign ticket
  Future<Map<String, dynamic>> unassignTicket(int ticketId) async {
    final headers = await getHeaders();
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/unassign'),
      headers: headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─── Users (เพิ่มเติม) ──────────────────────────────────────────

  /// ดึงรายชื่อผู้ใช้งานตาม Role (resident หรือ technician)
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final uri = Uri.parse(
      '$kBaseUrl/users/',
    ).replace(queryParameters: {'role': role});

    final headers = await getHeaders(); // เรียกใช้ getHeaders ที่เราเพิ่งแก้ไป
    final res = await _client.get(uri, headers: headers);
    _checkStatus(res);

    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// ลบผู้ใช้งาน
  Future<void> deleteUser(String uid) async {
    final headers = await getHeaders(); // เรียกใช้ getHeaders ที่เราเพิ่งแก้ไป
    final res = await _client.delete(
      Uri.parse('$kBaseUrl/users/$uid'),
      headers: headers,
    );
    _checkStatus(res);
  }

  // ─── Helpers ───────────────────────────────────────────────────

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(res.statusCode, res.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}
