// lib/models/visit.dart
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
  final String? cabinetCode; // CHANGED: clientId -> cabinetCode

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
    this.cabinetCode, // CHANGED: clientId -> cabinetCode
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
    'cabinet_code': cabinetCode, // CHANGED: client_id -> cabinet_code
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
    isPaid: map['is_paid'] as bool,
    amountPaid: map['amount_paid'] != null
        ? (map['amount_paid'] as num).toDouble()
        : null,
    totalAmount: map['total_amount'] != null
        ? (map['total_amount'] as num).toDouble()
        : null,
    cabinetCode:
        map['cabinet_code'] as String?, // CHANGED: client_id -> cabinet_code
  );

  @override
  String toString() {
    return 'Visit(id: $id, patientId: $patientId, date: $date, time: $time)';
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
    String? cabinetCode, // CHANGED: clientId -> cabinetCode
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
      cabinetCode:
          cabinetCode ?? this.cabinetCode, // CHANGED: clientId -> cabinetCode
    );
  }
}
