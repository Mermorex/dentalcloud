// lib/models/patient.dart
class Patient {
  final String? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String? dateOfBirth;
  final String? email;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? primaryLanguage;
  final String? alerts;
  final String? systemicDiseases;
  final String? medications;
  final String? allergies;
  final String? pastSurgeriesHospitalizations;
  final String? lifestyleFactors;
  final String? pregnancyLactationStatus;
  final String? chiefComplaint;
  final String? pastDentalTreatments;
  final String? previousDentalProblems;
  final String? oralHygieneHabits;
  final String? lastDentalVisit;
  final String? lastXray;
  final int visitCount;
  final String? cabinetId; // ✅ Now cabinetId (UUID), not cabinetCode

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.dateOfBirth,
    this.email,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.primaryLanguage,
    this.alerts,
    this.systemicDiseases,
    this.medications,
    this.allergies,
    this.pastSurgeriesHospitalizations,
    this.lifestyleFactors,
    this.pregnancyLactationStatus,
    this.chiefComplaint,
    this.pastDentalTreatments,
    this.previousDentalProblems,
    this.oralHygieneHabits,
    this.lastDentalVisit,
    this.lastXray,
    this.visitCount = 0,
    this.cabinetId, // ✅
  });

  // Convert to Map for database insertion
  // ✅ FIXED: Conditionally include 'id' only if it's not null
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      // Add non-nullable fields and nullable fields that should always be included
      // Note: 'id' is deliberately omitted if null
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'email': email,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'primary_language': primaryLanguage,
      'alerts': alerts,
      'systemic_diseases': systemicDiseases,
      'medications': medications,
      'allergies': allergies,
      'past_surgeries_hospitalizations': pastSurgeriesHospitalizations,
      'lifestyle_factors': lifestyleFactors,
      'pregnancy_lactation_status': pregnancyLactationStatus,
      'chief_complaint': chiefComplaint,
      'past_dental_treatments': pastDentalTreatments,
      'previous_dental_problems': previousDentalProblems,
      'oral_hygiene_habits': oralHygieneHabits,
      'last_dental_visit': lastDentalVisit,
      'last_xray': lastXray,
      'visit_count': visitCount,
      'cabinet_id': cabinetId, // ✅ DB column is cabinet_id
    };

    // Conditionally add fields that might be null and should be omitted if null
    // Crucially, omit 'id' if it's null
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
  // ✅ END OF FIX

  // Create from Map (from DB)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      phone: map['phone'],
      dateOfBirth: map['date_of_birth'],
      email: map['email'],
      address: map['address'],
      emergencyContactName: map['emergency_contact_name'],
      emergencyContactPhone: map['emergency_contact_phone'],
      primaryLanguage: map['primary_language'],
      alerts: map['alerts'],
      systemicDiseases: map['systemic_diseases'],
      medications: map['medications'],
      allergies: map['allergies'],
      pastSurgeriesHospitalizations: map['past_surgeries_hospitalizations'],
      lifestyleFactors: map['lifestyle_factors'],
      pregnancyLactationStatus: map['pregnancy_lactation_status'],
      chiefComplaint: map['chief_complaint'],
      pastDentalTreatments: map['past_dental_treatments'],
      previousDentalProblems: map['previous_dental_problems'],
      oralHygieneHabits: map['oral_hygiene_habits'],
      lastDentalVisit: map['last_dental_visit'],
      lastXray: map['last_xray'],
      visitCount: map['visit_count'] ?? 0,
      cabinetId: map['cabinet_id'], // ✅
    );
  }

  // ✅ Updated copyWith to use cabinetId
  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? dateOfBirth,
    String? email,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? primaryLanguage,
    String? alerts,
    String? systemicDiseases,
    String? medications,
    String? allergies,
    String? pastSurgeriesHospitalizations,
    String? lifestyleFactors,
    String? pregnancyLactationStatus,
    String? chiefComplaint,
    String? pastDentalTreatments,
    String? previousDentalProblems,
    String? oralHygieneHabits,
    String? lastDentalVisit,
    String? lastXray,
    int? visitCount,
    String? cabinetId, // ✅ Parameter name corrected
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      alerts: alerts ?? this.alerts,
      systemicDiseases: systemicDiseases ?? this.systemicDiseases,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      pastSurgeriesHospitalizations:
          pastSurgeriesHospitalizations ?? this.pastSurgeriesHospitalizations,
      lifestyleFactors: lifestyleFactors ?? this.lifestyleFactors,
      pregnancyLactationStatus:
          pregnancyLactationStatus ?? this.pregnancyLactationStatus,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      pastDentalTreatments: pastDentalTreatments ?? this.pastDentalTreatments,
      previousDentalProblems:
          previousDentalProblems ?? this.previousDentalProblems,
      oralHygieneHabits: oralHygieneHabits ?? this.oralHygieneHabits,
      lastDentalVisit: lastDentalVisit ?? this.lastDentalVisit,
      lastXray: lastXray ?? this.lastXray,
      visitCount: visitCount ?? this.visitCount,
      cabinetId: cabinetId ?? this.cabinetId, // ✅
    );
  }
}
