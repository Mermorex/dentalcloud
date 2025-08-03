// lib/models/cabinet_member.dart
class CabinetMember {
  final String id;
  final String cabinetCode;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final bool isActive;

  CabinetMember({
    required this.id,
    required this.cabinetCode,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cabinet_code': cabinetCode,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory CabinetMember.fromMap(Map<String, dynamic> map) {
    return CabinetMember(
      id: map['id'] as String,
      cabinetCode: map['cabinet_code'] as String,
      userId: map['user_id'] as String,
      role: map['role'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      isActive: map['is_active'] as bool,
    );
  }
}
