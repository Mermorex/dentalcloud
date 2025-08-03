// lib/models/profile.dart
class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? defaultCabinetCode;

  Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.email,
    this.defaultCabinetCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'default_cabinet_code': defaultCabinetCode,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      defaultCabinetCode: map['default_cabinet_code'] as String?,
    );
  }
}
