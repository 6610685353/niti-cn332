import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator → 10.0.2.2, iOS simulator → 127.0.0.1
  // Real device → ใส่ IP เครื่อง dev เช่น 'http://192.168.1.x:8000'
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _headers();
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> postMultipart(
    String path,
    List<int> fileBytes,
    String filename,
  ) async {
    final token = await _getToken();
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    ));
    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  /// แปลง response เป็น decoded body พร้อม throw ถ้า error
  static dynamic handleResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final detail = body is Map ? body['detail'] ?? 'Unknown error' : 'Error';
    throw ApiException(response.statusCode, detail.toString());
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
