// lib/models/appointment.dart
import 'package:uuid/uuid.dart'; // Import uuid package

class Appointment {
  String? id;
  final String patientId;
  final String date;
  final String time;
  final String notes;
  final String status;
  String? patientName;
  final String? clientId; // Ensure this is present

  Appointment({
    String? id,
    required this.patientId,
    required this.date,
    required this.time,
    required this.notes,
    this.status = 'Scheduled',
    this.patientName,
    this.clientId, // Ensure this is present in the constructor
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'time': time,
      'notes': notes,
      'status': status,
      'client_id': clientId, // Ensure this is in toMap
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id']?.toString(),
      patientId: map['patient_id'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      notes: map['notes'] as String,
      status: map['status'] as String,
      patientName: map['patients'] != null && map['patients'] is Map
          ? (map['patients'] as Map)['name']
          : null, // Correctly handle nested patient data for join
      clientId: map['client_id'] as String?, // Ensure this is in fromMap
    );
  }

  // Add the copyWith method here
  Appointment copyWith({
    String? id,
    String? patientId,
    String? date,
    String? time,
    String? notes,
    String? status,
    String? patientName,
    String? clientId, // Add clientId here
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      clientId: clientId ?? this.clientId, // Set clientId here
    );
  }
}
