// lib/models/appointment.dart
import 'package:uuid/uuid.dart'; // Import uuid package

class Appointment {
  String? id; // Changed from int? to String?
  final String patientId; // Changed from int to String
  final String date;
  final String time;
  final String notes;
  final String status;
  String? patientName; // Added for convenience when fetching with join

  Appointment({
    String? id, // Make ID nullable to allow for auto-generation
    required this.patientId,
    required this.date,
    required this.time,
    required this.notes,
    this.status = 'Scheduled',
    this.patientName,
  }) : id = id ?? const Uuid().v4(); // Generate UUID if not provided

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId, // Changed to snake_case to match DB
      'date': date,
      'time': time,
      'notes': notes,
      'status': status,
    };
  }

  // New method for inserting with a generated ID (redundant with constructor, but kept for consistency)
  Map<String, dynamic> toMapWithId(String newId) {
    return {
      'id': newId,
      'patient_id': patientId, // Changed to snake_case to match DB
      'date': date,
      'time': time,
      'notes': notes,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id']?.toString(), // Ensure id is String
      patientId: map['patient_id'] as String, // Read from snake_case
      date: map['date'] as String,
      time: map['time'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      patientName: map['patientName']
          ?.toString(), // Assuming patientName might be fetched via join
    );
  }

  // If you need a copyWith method, include it here:
  Appointment copyWith({
    String? id,
    String? patientId,
    String? date,
    String? time,
    String? notes,
    String? status,
    String? patientName,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
    );
  }
}
