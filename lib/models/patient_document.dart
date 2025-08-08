// lib/models/patient_document.dart
class PatientDocument {
  final String? id;
  final String? patientId;
  final String? cabinetId;
  final String? uploadedBy;
  final String? fileName;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  final String? description;
  final String? category;
  final DateTime? createdAt; // <-- THIS FIELD IS CRUCIAL
  final DateTime? updatedAt;

  PatientDocument({
    this.id,
    this.patientId,
    this.cabinetId,
    this.uploadedBy,
    this.fileName,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.description,
    this.category,
    this.createdAt, // <-- MUST BE IN CONSTRUCTOR
    this.updatedAt,
  });

  // THE fromJson FACTORY MUST MAP 'created_at' TO createdAt
  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      id: json['id'],
      patientId: json['patient_id'],
      cabinetId: json['cabinet_id'],
      uploadedBy: json['uploaded_by'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      description: json['description'],
      category: json['category'],
      // --- KEY PART FOR DATE ---
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'].toString(),
            ) // Handle potential String format
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      // --- END KEY PART ---
    );
  }

  // toJson might also be needed if you plan to serialize back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'cabinet_id': cabinetId,
      'uploaded_by': uploadedBy,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'description': description,
      'category': category,
      'created_at': createdAt
          ?.toIso8601String(), // Convert DateTime back to String for JSON
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
