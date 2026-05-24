class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  final String role;
  final String status;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.imageUrl,
    required this.role,
    required this.status,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      role: json['role'] as String? ?? 'technician',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
