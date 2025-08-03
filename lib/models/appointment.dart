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
  final String? cabinetCode; // CHANGED: clientId -> cabinetCode

  Appointment({
    String? id,
    required this.patientId,
    required this.date,
    required this.time,
    required this.notes,
    this.status = 'Scheduled',
    this.patientName,
    this.cabinetCode, // CHANGED: clientId -> cabinetCode
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'time': time,
      'notes': notes,
      'status': status,
      'cabinet_code': cabinetCode, // CHANGED: client_id -> cabinet_code
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
      cabinetCode:
          map['cabinet_code'] as String?, // CHANGED: client_id -> cabinet_code
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
    String? cabinetCode, // CHANGED: clientId -> cabinetCode
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      cabinetCode:
          cabinetCode ?? this.cabinetCode, // CHANGED: clientId -> cabinetCode
    );
  }
}
