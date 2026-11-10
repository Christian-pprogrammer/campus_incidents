enum UserRole {
  student,
  staff;

  static UserRole fromName(String? name) => name == 'staff' ? staff : student;
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.program = '',
  });

  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String program;

  bool get isStaff => role == UserRole.staff;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromName(map['role'] as String?),
      program: map['program'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'role': role.name,
        'program': program,
      };
}
