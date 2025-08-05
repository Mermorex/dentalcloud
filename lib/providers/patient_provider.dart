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
  // CHANGED: _currentCabinetCode -> _currentCabinetId
  String? _currentCabinetId;
  String? _currentCabinetName; // Store the cabinet name
  static const int MAX_PATIENT_LIMIT = 30;

  List<Patient> get patients => _patients;
  List<Patient> get filteredPatients => _filteredPatients;
  List<Appointment> get appointments => _appointments;
  String get currentSearchQuery => _currentSearchQuery;
  // CHANGED: getter currentCabinetCode -> currentCabinetId
  String? get currentCabinetId => _currentCabinetId;
  String? get currentCabinetName => _currentCabinetName; // getter for name

  // --- MODIFIED setCurrentCabinetId ---
  // Method to set current cabinet ID and load associated info
  // Ensures data is cleared when cabinet ID is set to null.
  Future<void> setCurrentCabinetId(String? cabinetId) async {
    // CHANGED: Parameter
    _currentCabinetId = cabinetId; // CHANGED: Assignment
    _currentCabinetName = null; // Reset name when ID changes
    if (cabinetId != null) {
      await _loadCabinetName(); // Load the cabinet name when ID is set
    } else {
      // Clear data lists when cabinet ID is removed (e.g., on logout or error)
      print("PatientProvider: Clearing data lists because cabinet ID is null.");
      _patients = [];
      _filteredPatients = [];
      _appointments = [];
      _currentSearchQuery = '';
    }
    notifyListeners();
    // Optionally reload data for the new cabinet
    // await loadPatients();
    // await loadAppointments();
  }
  // --- END OF MODIFIED setCurrentCabinetId ---

  // Helper method to load cabinet name from DB using cabinetId
  Future<void> _loadCabinetName() async {
    // CHANGED: Use _currentCabinetId
    if (_currentCabinetId == null) return;
    try {
      // CHANGED: Pass _currentCabinetId
      _currentCabinetName = await DatabaseHelper.instance.getCabinetName(
        _currentCabinetId!,
      );
      notifyListeners();
    } catch (e) {
      print('Failed to load cabinet name: $e');
      _currentCabinetName = null;
      notifyListeners();
    }
  }

  // Helper to get the current user ID (might be useful for other operations)
  String? get _currentUserId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  Future<void> loadPatients() async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot load patients.');
      _patients = []; // Clear patients if cabinet ID is missing
      _filteredPatients = [];
      notifyListeners();
      return;
    }
    try {
      // CHANGED: Pass cabinetId
      _patients = await DatabaseHelper.instance.getPatientsWithVisitCount(
        cabinetId,
      );
      filterPatients(_currentSearchQuery);
    } catch (e) {
      print('Failed to load patients: $e'); // Cleaner output
      _patients = [];
      _filteredPatients = [];
    }
    notifyListeners();
  }

  Future<bool> addPatient(Patient p) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot add patient.');
      return false;
    }
    await loadPatients(); // Ensure latest count
    if (_patients.length >= MAX_PATIENT_LIMIT) {
      print('Patient limit reached. Cannot add more patients.');
      return false;
    }
    try {
      // Create a new patient object with the cabinet ID
      // CHANGED: Use cabinetId in copyWith
      final patientWithCabinetId = p.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.insertPatient(patientWithCabinetId);
      await loadPatients();
      return true;
    } catch (e) {
      print('Failed to add patient: $e');
      return false;
    }
  }

  Future<void> updatePatient(Patient p) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot update patient.');
      return;
    }
    try {
      // CHANGED: Use cabinetId in copyWith
      final patientWithCabinetId = p.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.updatePatient(patientWithCabinetId);
      await loadPatients();
    } catch (e) {
      print('Failed to update patient: $e');
    }
  }

  Future<void> deletePatient(String patientId) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot delete patient.');
      return;
    }
    try {
      // CHANGED: Pass cabinetId
      await DatabaseHelper.instance.deletePatient(patientId, cabinetId);
      await loadPatients();
    } catch (e) {
      print('Failed to delete patient: $e');
    }
  }

  // --- Visit related methods ---
  Future<List<Visit>> getVisitsForPatient(String patientId) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot get visits.');
      return [];
    }
    try {
      // CHANGED: Pass cabinetId
      return await DatabaseHelper.instance.getVisitsForPatient(
        patientId,
        cabinetId,
      );
    } catch (e) {
      print('Failed to get visits: $e');
      return [];
    }
  }

  Future<void> addVisit(Visit visit) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot add visit.');
      return;
    }
    try {
      // CHANGED: Use cabinetId in copyWith
      final visitWithCabinetId = visit.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.insertVisit(visitWithCabinetId);
      await loadPatients(); // Reloads patients, updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to add visit: $e');
    }
  }

  Future<void> updateVisit(Visit visit) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot update visit.');
      return;
    }
    try {
      // CHANGED: Use cabinetId in copyWith
      final visitWithCabinetId = visit.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.updateVisit(visitWithCabinetId);
      notifyListeners();
    } catch (e) {
      print('Failed to update visit: $e');
    }
  }

  Future<void> deleteVisit(String visitId) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot delete visit.');
      return;
    }
    try {
      // CHANGED: Pass cabinetId
      await DatabaseHelper.instance.deleteVisit(visitId, cabinetId);
      await loadPatients(); // Reloads patients, updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to delete visit: $e');
    }
  }

  // --- Appointment related methods ---
  Future<void> loadAppointments() async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot load appointments.');
      _appointments = [];
      notifyListeners();
      return;
    }
    try {
      // CHANGED: Pass cabinetId
      _appointments = await DatabaseHelper.instance.getAllAppointments(
        cabinetId,
      );
      notifyListeners();
    } catch (e) {
      print('Failed to load appointments: $e');
      _appointments = []; // Ensure list is cleared on error
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot add appointment.');
      return;
    }
    try {
      // Ensure the appointment object has the correct cabinet ID
      // CHANGED: Use cabinetId in copyWith
      final appointmentWithCabinetId = appointment.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.insertAppointment(appointmentWithCabinetId);
      await loadAppointments(); // Reload the list after successful insert
    } on PostgrestException catch (e) {
      print('Error inserting appointment (Postgrest): $e');
      rethrow;
    } catch (e) {
      print('Failed to add appointment: $e');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot update appointment.');
      return;
    }
    try {
      // CHANGED: Use cabinetId in copyWith
      final appointmentWithCabinetId = appointment.copyWith(
        cabinetId: cabinetId, // <-- CRUCIAL FIX: Use cabinetId parameter name
      );
      await DatabaseHelper.instance.updateAppointment(appointmentWithCabinetId);
      await loadAppointments();
    } catch (e) {
      print('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    // CHANGED: cabinetCode -> cabinetId
    final cabinetId = _currentCabinetId;
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot delete appointment.');
      return;
    }
    try {
      // CHANGED: Pass cabinetId
      await DatabaseHelper.instance.deleteAppointment(appointmentId, cabinetId);
      await loadAppointments();
    } catch (e) {
      print('Failed to delete appointment: $e');
    }
  }

  String getPatientNameById(String patientId) {
    return _patients
        .firstWhere(
          (p) => p.id == patientId,
          orElse: () => Patient(
            id: 'unknown_id',
            name: 'Unknown',
            age: 0,
            gender: 'Other',
            phone: '',
            // cabinetId: _currentCabinetId, // Optional if needed in constructor
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
