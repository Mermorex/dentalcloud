// lib/providers/patient_provider.dart
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/appointment.dart';
import '../db/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for auth.uid()

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

  // Helper to get the current client ID.
  // This assumes the `auth.uid()` from Supabase corresponds to your client_id.
  // If your client_id is stored in a different part of user metadata or a separate table,
  // adjust this logic accordingly.
  String? get _currentClientId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> loadPatients() async {
    final clientId = _currentClientId;
    if (clientId == null) {
      // Handle case where client ID is not available (e.g., not logged in)
      print('Error: Client ID not found. Cannot load patients.');
      _patients = []; // Clear patients if client ID is missing
      _filteredPatients = [];
      notifyListeners();
      return;
    }
    try {
      _patients = await DatabaseHelper.instance.getPatientsWithVisitCount(
        clientId,
      );
      filterPatients(_currentSearchQuery);
    } catch (e) {
      print('Failed to load patients: ${e.toString()}');
      // Consider setting an error state if you re-introduce it
    }
    notifyListeners();
  }

  Future<bool> addPatient(Patient p) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot add patient.');
      return false;
    }
    await loadPatients(); // Ensure latest count
    if (_patients.length >= MAX_PATIENT_LIMIT) {
      print('Patient limit reached. Cannot add more patients.');
      return false;
    }
    try {
      // Create a new patient object with the client ID
      final patientWithClientId = p.copyWith(clientId: clientId);
      await DatabaseHelper.instance.insertPatient(patientWithClientId);
      await loadPatients();
      return true;
    } catch (e) {
      print('Failed to add patient: ${e.toString()}');
      return false;
    }
  }

  Future<void> updatePatient(Patient p) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot update patient.');
      return;
    }
    try {
      final patientWithClientId = p.copyWith(clientId: clientId);
      await DatabaseHelper.instance.updatePatient(patientWithClientId);
      await loadPatients();
    } catch (e) {
      print('Failed to update patient: ${e.toString()}');
    }
  }

  Future<void> deletePatient(String patientId) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot delete patient.');
      return;
    }
    try {
      await DatabaseHelper.instance.deletePatient(patientId, clientId);
      await loadPatients();
    } catch (e) {
      print('Failed to delete patient: ${e.toString()}');
    }
  }

  // --- Visit related methods ---
  Future<List<Visit>> getVisitsForPatient(String patientId) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot get visits.');
      return [];
    }
    try {
      return await DatabaseHelper.instance.getVisitsForPatient(
        patientId,
        clientId,
      );
    } catch (e) {
      print('Failed to get visits: ${e.toString()}');
      return [];
    }
  }

  Future<void> addVisit(Visit visit) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot add visit.');
      return;
    }
    try {
      final visitWithClientId = visit.copyWith(clientId: clientId);
      await DatabaseHelper.instance.insertVisit(visitWithClientId);
      await loadPatients(); // This reloads patients, implicitly updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to add visit: ${e.toString()}');
    }
  }

  Future<void> updateVisit(Visit visit) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot update visit.');
      return;
    }
    try {
      final visitWithClientId = visit.copyWith(clientId: clientId);
      await DatabaseHelper.instance.updateVisit(visitWithClientId);
      notifyListeners();
    } catch (e) {
      print('Failed to update visit: ${e.toString()}');
    }
  }

  Future<void> deleteVisit(String visitId) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot delete visit.');
      return;
    }
    try {
      await DatabaseHelper.instance.deleteVisit(visitId, clientId);
      await loadPatients(); // This reloads patients, implicitly updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to delete visit: ${e.toString()}');
    }
  }

  // --- Appointment related methods ---
  Future<void> loadAppointments() async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot load appointments.');
      _appointments = [];
      notifyListeners();
      return;
    }
    try {
      _appointments = await DatabaseHelper.instance.getAllAppointments(
        clientId,
      );
      notifyListeners();
    } catch (e) {
      print('Failed to load appointments: ${e.toString()}');
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot add appointment.');
      return;
    }
    try {
      final appointmentWithClientId = appointment.copyWith(clientId: clientId);
      await DatabaseHelper.instance.insertAppointment(appointmentWithClientId);
      await loadAppointments();
    } catch (e) {
      print('Failed to add appointment: ${e.toString()}');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot update appointment.');
      return;
    }
    try {
      final appointmentWithClientId = appointment.copyWith(clientId: clientId);
      await DatabaseHelper.instance.updateAppointment(appointmentWithClientId);
      await loadAppointments();
    } catch (e) {
      print('Failed to update appointment: ${e.toString()}');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final clientId = _currentClientId;
    if (clientId == null) {
      print('Error: Client ID not found. Cannot delete appointment.');
      return;
    }
    try {
      await DatabaseHelper.instance.deleteAppointment(appointmentId, clientId);
      await loadAppointments();
    } catch (e) {
      print('Failed to delete appointment: ${e.toString()}');
    }
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
