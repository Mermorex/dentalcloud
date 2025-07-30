// lib/models/patient.dart
import 'package:uuid/uuid.dart';

class Patient {
  final String id;
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
  final int? visitCount;
  final String? clientId; // Ensure this is nullable (String?)

  Patient({
    String? id,
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
    this.visitCount,
    this.clientId, // Ensure this is a normal optional parameter (no 'required')
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'last_xray': lastXRay,
      'visit_count': visitCount,
      'client_id': clientId, // Included in toMap for the database column
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      phone: map['phone'] as String,
      dateOfBirth: map['date_of_birth'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactPhone: map['emergency_contact_phone'] as String?,
      primaryLanguage: map['primary_language'] as String?,
      alerts: map['alerts'] as String?,
      systemicDiseases: map['systemic_diseases'] as String?,
      medications: map['medications'] as String?,
      allergies: map['allergies'] as String?,
      pastSurgeriesHospitalizations:
          map['past_surgeries_hospitalizations'] as String?,
      lifestyleFactors: map['lifestyle_factors'] as String?,
      pregnancyLactationStatus: map['pregnancy_lactation_status'] as String?,
      chiefComplaint: map['chief_complaint'] as String?,
      pastDentalTreatments: map['past_dental_treatments'] as String?,
      previousDentalProblems: map['previous_dental_problems'] as String?,
      oralHygieneHabits: map['oral_hygiene_habits'] as String?,
      lastDentalVisit: map['last_dental_visit'] as String?,
      lastXRay: map['last_xray'] as String?,
      visitCount: map['visit_count'] as int?,
      clientId: map['client_id'] as String?, // Reads from the database column
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
    String? clientId, // Ensure this is nullable here too
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
      clientId:
          clientId ?? this.clientId, // Ensure proper handling of nullability
    );
  }
}
