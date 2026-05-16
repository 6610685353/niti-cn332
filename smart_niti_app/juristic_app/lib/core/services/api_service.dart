import 'dart:convert';
import 'package:http/http.dart' as http;

/// เปลี่ยน baseUrl ให้ตรงกับ IP/port ที่ backend รัน
/// เช่น ถ้ารันบนเครื่องเดียวกัน ใช้ http://localhost:8000
/// ถ้า Flutter Web ใช้ http://127.0.0.1:8000
/// ถ้าเป็น Android Emulator ใช้ http://10.0.2.2:8000
const String kBaseUrl = 'http://localhost:8000';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ─── Tickets ───────────────────────────────────────────────────

  /// ดึง ticket ทั้งหมด หรือกรองตาม req_user_id
  Future<List<Map<String, dynamic>>> getTickets({String? reqUserId}) async {
    final uri = Uri.parse('$kBaseUrl/tickets/').replace(
      queryParameters: reqUserId != null ? {'req_user_id': reqUserId} : null,
    );
    final res = await _client.get(uri, headers: _headers);
    _checkStatus(res);
    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// ดึง ticket เดี่ยวตาม id
  Future<Map<String, dynamic>> getTicket(int ticketId) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/tickets/$ticketId'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// อัปเดต status ของ ticket
  Future<Map<String, dynamic>> updateTicketStatus(
    int ticketId,
    String status,
  ) async {
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/status?status=$status'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// ยกเลิก ticket
  Future<Map<String, dynamic>> cancelTicket(int ticketId) async {
    final res = await _client.patch(
      Uri.parse('$kBaseUrl/tickets/$ticketId/cancel'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─── Users ─────────────────────────────────────────────────────

  /// ดึงข้อมูล user ตาม uid
  Future<Map<String, dynamic>> getUser(String uid) async {
    final res = await _client.get(
      Uri.parse('$kBaseUrl/users/$uid'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
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
