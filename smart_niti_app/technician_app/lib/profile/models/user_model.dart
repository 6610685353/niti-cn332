class UserModel {
  final String name;
  final String email;
  final String phone;
  final String unit;
  final String joinDate;
  final String avatarUrl;
  final bool isVerified;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.unit,
    required this.joinDate,
    required this.avatarUrl,
    this.isVerified = true,
  });
}

final mockUser = UserModel(
  name: 'Alex Johnson',
  email: 'alex.johnson@example.com',
  phone: '(+555) 01-234-5678',
  unit: 'Unit 402B',
  joinDate: 'Member since January 2023',
  avatarUrl: 'https://via.placeholder.com/150',
);
