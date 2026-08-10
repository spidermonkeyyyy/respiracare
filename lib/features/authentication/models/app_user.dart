import 'package:equatable/equatable.dart';

enum UserRole {
  patient,
  nurse,
  pneumologist,
  admin,
}

extension UserRoleExtension on UserRole {
  String get nameString {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.nurse:
        return 'Infirmier(e)';
      case UserRole.pneumologist:
        return 'Pneumologue';
      case UserRole.admin:
        return 'Administrateur';
    }
  }
}

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? dateOfBirth;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.patient,
      ),
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, phone, dateOfBirth];
}
