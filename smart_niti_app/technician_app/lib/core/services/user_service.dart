import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../../profile/models/user_model.dart';

class UserService {
  /// ดึงข้อมูลโปรไฟล์ผู้ใช้ปัจจุบัน
  static Future<UserModel> getMyProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw ApiException(401, 'Not authenticated');

    final response = await ApiService.get('/users/$uid');
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// ดึงข้อมูลผู้ใช้ตาม uid
  static Future<UserModel> getUser(String uid) async {
    final response = await ApiService.get('/users/$uid');
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// อัปเดตโปรไฟล์ตัวเอง (ชื่อ, รูป)
  static Future<UserModel> updateMyProfile({
    String? firstName,
    String? lastName,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final response = await ApiService.patch('/users/me', body: body);
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// อัปโหลดรูปโปรไฟล์ไปยัง backend → PATCH /users/me/avatar
  static Future<UserModel> uploadAvatar(
    List<int> bytes,
    String filename,
  ) async {
    final response = await ApiService.postMultipart(
      '/users/me/avatar',
      bytes,
      filename,
    );
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
