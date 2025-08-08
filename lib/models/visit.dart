// lib/models/visit.dart

import '../models/patient_document.dart'; // Assuming you'll create a similar model for visit docs or reuse PatientDocument if structure is identical

class Visit {
  final String? id;
  final String patientId;
  final String date;
  final String time;
  final String purpose;
  final String findings;
  final String treatment;
  final String notes;
  final String? nextVisitDate;
  final bool isPaid;
  final double? amountPaid;
  final double? totalAmount;
  final String? cabinetId;
  // --- NEW: Field for associated documents ---
  // This will be populated *after* fetching from the database/service
  List<PatientDocument>
  attachedDocuments; // Use PatientDocument or create VisitDocument
  // --- END OF NEW ---

  Visit({
    this.id,
    required this.patientId,
    required this.date,
    required this.time,
    required this.purpose,
    required this.findings,
    required this.treatment,
    required this.notes,
    this.nextVisitDate,
    this.isPaid = false,
    this.amountPaid,
    this.totalAmount,
    this.cabinetId,
    // --- NEW: Initialize attachedDocuments ---
    this.attachedDocuments = const [], // Initialize with an empty list
    // --- END OF NEW ---
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'patient_id': patientId,
    'date': date,
    'time': time,
    'purpose': purpose,
    'findings': findings,
    'treatment': treatment,
    'notes': notes,
    'next_visit_date': nextVisitDate,
    'is_paid': isPaid,
    'amount_paid': amountPaid,
    'total_amount': totalAmount,
    'cabinet_id': cabinetId,
    // Note: attachedDocuments are usually not stored directly in the visit table
    // They are stored in a separate table (e.g., visit_documents) linked by visit_id
  };

  factory Visit.fromMap(Map<String, dynamic> map) => Visit(
    id: map['id'] as String?,
    patientId: map['patient_id'] as String,
    date: map['date'] as String,
    time: map['time'] as String,
    purpose: map['purpose'] as String? ?? '',
    findings: map['findings'] as String? ?? '',
    treatment: map['treatment'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
    nextVisitDate: map['next_visit_date'] as String?,
    isPaid: map['is_paid'] as bool? ?? false, // Ensure default
    amountPaid: map['amount_paid'] != null
        ? (map['amount_paid'] as num).toDouble()
        : null,
    totalAmount: map['total_amount'] != null
        ? (map['total_amount'] as num).toDouble()
        : null,
    cabinetId: map['cabinet_id'],
    // attachedDocuments will be populated separately
  );

  @override
  String toString() {
    return 'Visit(id: $id, patientId: $patientId, date: $date, time: $time, attachedDocuments: ${attachedDocuments.length})';
  }

  // Add the copyWith method here
  Visit copyWith({
    String? id,
    String? patientId,
    String? date,
    String? time,
    String? purpose,
    String? findings,
    String? treatment,
    String? notes,
    String? nextVisitDate,
    bool? isPaid,
    double? amountPaid,
    double? totalAmount,
    String? cabinetId,
    List<PatientDocument>? attachedDocuments, // Add parameter
  }) {
    return Visit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      time: time ?? this.time,
      purpose: purpose ?? this.purpose,
      findings: findings ?? this.findings,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      isPaid: isPaid ?? this.isPaid,
      amountPaid: amountPaid ?? this.amountPaid,
      totalAmount: totalAmount ?? this.totalAmount,
      cabinetId: cabinetId ?? this.cabinetId,
      attachedDocuments:
          attachedDocuments ?? this.attachedDocuments, // Copy the list
    );
  }
}
