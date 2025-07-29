// lib/models/patient.dart
import 'package:uuid/uuid.dart'; // Ensure uuid package is imported

class Patient {
  final String id; // Changed from int to String
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
  final String? lastXRay;
  final int? visitCount; // New field for visit count

  Patient({
    String? id, // Made optional and nullable to generate UUID if not provided
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
    this.lastXRay,
    this.visitCount, // Keep visitCount as it's from patient_provider
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'date_of_birth': dateOfBirth, // Changed to snake_case
      'email': email,
      'address': address,
      'emergency_contact_name': emergencyContactName, // Changed to snake_case
      'emergency_contact_phone': emergencyContactPhone, // Changed to snake_case
      'primary_language': primaryLanguage, // Changed to snake_case
      'alerts': alerts,
      'systemic_diseases': systemicDiseases, // Changed to snake_case
      'medications': medications,
      'allergies': allergies,
      'past_surgeries_hospitalizations':
          pastSurgeriesHospitalizations, // Changed to snake_case
      'lifestyle_factors': lifestyleFactors, // Changed to snake_case
      // IMPORTANT: Please verify if your column is 'pregnancy_lactation_status' or 'pregnancy_lactation_statusb'
      // If it's 'pregnancy_lactation_statusb' in your DB, change the key below:
      'pregnancy_lactation_status':
          pregnancyLactationStatus, // Changed to snake_case
      'chief_complaint': chiefComplaint, // Changed to snake_case
      'past_dental_treatments': pastDentalTreatments, // Changed to snake_case
      'previous_dental_problems':
          previousDentalProblems, // Changed to snake_case
      'oral_hygiene_habits': oralHygieneHabits, // Changed to snake_case
      'last_dental_visit': lastDentalVisit, // Changed to snake_case
      'last_xray': lastXRay, // Changed to snake_case
      'visit_count': visitCount, // Changed to snake_case (if stored in DB)
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      phone: map['phone'] as String,
      dateOfBirth: map['date_of_birth'] as String?, // Changed to snake_case
      email: map['email'] as String?,
      address: map['address'] as String?,
      emergencyContactName:
          map['emergency_contact_name'] as String?, // Changed to snake_case
      emergencyContactPhone:
          map['emergency_contact_phone'] as String?, // Changed to snake_case
      primaryLanguage:
          map['primary_language'] as String?, // Changed to snake_case
      alerts: map['alerts'] as String?,
      systemicDiseases:
          map['systemic_diseases'] as String?, // Changed to snake_case
      medications: map['medications'] as String?,
      allergies: map['allergies'] as String?,
      pastSurgeriesHospitalizations:
          map['past_surgeries_hospitalizations']
              as String?, // Changed to snake_case
      lifestyleFactors:
          map['lifestyle_factors'] as String?, // Changed to snake_case
      // IMPORTANT: Please verify if your column is 'pregnancy_lactation_status' or 'pregnancy_lactation_statusb'
      // If it's 'pregnancy_lactation_statusb' in your DB, change the key below:
      pregnancyLactationStatus:
          map['pregnancy_lactation_status'] as String?, // Changed to snake_case
      chiefComplaint:
          map['chief_complaint'] as String?, // Changed to snake_case
      pastDentalTreatments:
          map['past_dental_treatments'] as String?, // Changed to snake_case
      previousDentalProblems:
          map['previous_dental_problems'] as String?, // Changed to snake_case
      oralHygieneHabits:
          map['oral_hygiene_habits'] as String?, // Changed to snake_case
      lastDentalVisit:
          map['last_dental_visit'] as String?, // Changed to snake_case
      lastXRay: map['last_xray'] as String?, // Changed to snake_case
      visitCount: map['visit_count'] as int?, // Changed to snake_case
    );
  }

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
    String? lastXRay,
    int? visitCount,
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
      lastXRay: lastXRay ?? this.lastXRay,
      visitCount: visitCount ?? this.visitCount,
    );
  }
}
