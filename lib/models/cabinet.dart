// lib/models/cabinet.dart
class Cabinet {
  final String code;
  final String? cabinetName;
  final String? createdBy;
  final DateTime? createdAt;
  final bool isUsed;
  final DateTime? usedAt;
  final bool isActive;

  Cabinet({
    required this.code,
    this.cabinetName,
    this.createdBy,
    this.createdAt,
    this.isUsed = false,
    this.usedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'cabinet_name': cabinetName,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'is_used': isUsed,
      'used_at': usedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory Cabinet.fromMap(Map<String, dynamic> map) {
    return Cabinet(
      code: map['code'] as String,
      cabinetName: map['cabinet_name'] as String?,
      createdBy: map['created_by'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      isUsed: map['is_used'] as bool,
      usedAt: map['used_at'] != null
          ? DateTime.parse(map['used_at'] as String)
          : null,
      isActive: map['is_active'] as bool,
    );
  }
}
