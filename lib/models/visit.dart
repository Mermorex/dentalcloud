// lib/models/visit.dart
class Visit {
  final String? id; // Changed from int? to String?
  final String patientId; // Changed from int to String
  final String date;
  final String time;
  final String purpose;
  final String findings;
  final String treatment;
  final String notes;
  final String? nextVisitDate;
  final bool isPaid; // Directly use bool type
  final double? amountPaid;
  final double? totalAmount;

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
  });

  Map<String, dynamic> toMap() => {
    // Supabase auto-generates 'id' on insert, send only if updating
    if (id != null) 'id': id,
    'patient_id': patientId, // Use snake_case to match DB
    'date': date,
    'time': time,
    'purpose': purpose,
    'findings': findings,
    'treatment': treatment,
    'notes': notes,
    'next_visit_date': nextVisitDate, // Use snake_case
    'is_paid': isPaid, // Send boolean directly
    'amount_paid': amountPaid, // Use snake_case
    'total_amount': totalAmount, // Use snake_case
  };

  factory Visit.fromMap(Map<String, dynamic> map) => Visit(
    id: map['id'] as String?, // Cast to String?
    patientId:
        map['patient_id'] as String, // Read from snake_case, cast to String
    date: map['date'] as String,
    time: map['time'] as String,
    purpose: map['purpose'] as String? ?? '',
    findings: map['findings'] as String? ?? '',
    treatment: map['treatment'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
    nextVisitDate: map['next_visit_date'] as String?, // Read from snake_case
    isPaid: map['is_paid'] as bool, // Read boolean directly
    amountPaid: map['amount_paid'] != null
        ? (map['amount_paid'] as num).toDouble()
        : null, // Handle double
    totalAmount: map['total_amount'] != null
        ? (map['total_amount'] as num).toDouble()
        : null, // Handle double
  );

  @override
  String toString() {
    return 'Visit(id: $id, patientId: $patientId, date: $date, time: $time)';
  }
}
