enum UserRole { student, admin }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? institution;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.institution,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? 'User',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.student,
      avatarUrl: json['avatar_url'],
      institution: json['institution'] ?? 'Makerere University',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role == UserRole.admin ? 'admin' : 'student',
      'avatar_url': avatarUrl,
      'institution': institution,
    };
  }
}
