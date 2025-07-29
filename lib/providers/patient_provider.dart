// lib/providers/patient_provider.dart
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/appointment.dart';
import '../db/database_helper.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  List<Appointment> _appointments = [];
  String _currentSearchQuery = '';

  static const int MAX_PATIENT_LIMIT = 30;

  List<Patient> get patients => _patients;
  List<Patient> get filteredPatients => _filteredPatients;
  List<Appointment> get appointments => _appointments;
  String get currentSearchQuery => _currentSearchQuery;

  Future<void> loadPatients() async {
    // This will now call the Supabase-backed getPatientsWithVisitCount
    // This assumes your DatabaseHelper.instance.getPatientsWithVisitCount()
    // correctly returns a list of Patient objects with visitCount (if your Patient model supports it).
    _patients = await DatabaseHelper.instance.getPatientsWithVisitCount();
    filterPatients(_currentSearchQuery);
    notifyListeners();
  }

  Future<bool> addPatient(Patient p) async {
    await loadPatients(); // Ensure latest count
    if (_patients.length >= MAX_PATIENT_LIMIT) {
      return false;
    }
    await DatabaseHelper.instance.insertPatient(p);
    await loadPatients();
    return true;
  }

  Future<void> updatePatient(Patient p) async {
    await DatabaseHelper.instance.updatePatient(p);
    await loadPatients();
  }

  Future<void> deletePatient(String patientId) async {
    await DatabaseHelper.instance.deletePatient(patientId);
    await loadPatients();
  }

  // --- Visit related methods ---
  Future<List<Visit>> getVisitsForPatient(String patientId) async {
    return await DatabaseHelper.instance.getVisitsForPatient(patientId);
  }

  Future<void> addVisit(Visit visit) async {
    await DatabaseHelper.instance.insertVisit(visit);
    // After adding a visit, you might want to refresh the patient's visit count
    // and notify listeners for any UI that displays visit counts.
    await loadPatients(); // This reloads patients, implicitly updating visit counts.
    // If you're on the patient detail screen, you'll need to re-fetch visits there
    // using _fetchVisits() call in initState or after a navigation.
    notifyListeners();
  }

  Future<void> updateVisit(Visit visit) async {
    await DatabaseHelper.instance.updateVisit(visit);
    // After updating a visit, notify listeners for any UI that displays visit data.
    // The PatientDetailScreen will typically re-fetch visits after this.
    notifyListeners();
  }

  Future<void> deleteVisit(String visitId) async {
    await DatabaseHelper.instance.deleteVisit(visitId);
    // After deleting a visit, you might want to refresh the patient's visit count
    // and notify listeners for any UI that displays visit counts.
    await loadPatients(); // This reloads patients, implicitly updating visit counts.
    notifyListeners();
  }

  // --- Appointment related methods ---
  Future<void> loadAppointments() async {
    _appointments = await DatabaseHelper.instance.getAllAppointments();
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    await DatabaseHelper.instance.insertAppointment(appointment);
    await loadAppointments();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await DatabaseHelper.instance.updateAppointment(appointment);
    await loadAppointments();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await DatabaseHelper.instance.deleteAppointment(appointmentId);
    await loadAppointments();
  }

  String getPatientNameById(String patientId) {
    return _patients
        .firstWhere(
          (p) => p.id == patientId,
          orElse: () => Patient(
            id: 'unknown_id', // Provide a dummy String ID for orElse
            name: 'Unknown',
            age: 0,
            gender: 'Other',
            phone: '',
          ),
        )
        .name;
  }

  void filterPatients(String query) {
    _currentSearchQuery = query;
    if (query.isEmpty) {
      _filteredPatients = List.from(_patients);
    } else {
      _filteredPatients = _patients
          .where(
            (patient) =>
                patient.name.toLowerCase().contains(query.toLowerCase()) ||
                (patient.phone.contains(query)) ||
                (patient.email != null &&
                    patient.email!.toLowerCase().contains(query.toLowerCase())),
          )
          .toList();
    }
    notifyListeners();
  }
}
