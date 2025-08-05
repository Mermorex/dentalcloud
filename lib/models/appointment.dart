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
  final String? cabinetId;

  Appointment({
    String? id,
    required this.patientId,
    required this.date,
    required this.time,
    required this.notes,
    this.status = 'Scheduled',
    this.patientName,
    this.cabinetId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'time': time,
      'notes': notes,
      'status': status,
      'cabinet_id': cabinetId,
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
          : null,
      cabinetId: map['cabinet_id'],
    );
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? date,
    String? time,
    String? notes,
    String? status,
    String? patientName,
    String? cabinetId,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      cabinetId:
          cabinetId ?? this.cabinetId, // CHANGED: clientId -> cabinetCode
    );
  }
}
