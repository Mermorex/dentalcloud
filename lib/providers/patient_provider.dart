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
  String?
  _currentCabinetCode; // CHANGED: _currentClientId -> _currentCabinetCode
  String? _currentCabinetName; // NEW: Store the cabinet name
  static const int MAX_PATIENT_LIMIT = 30;

  List<Patient> get patients => _patients;
  List<Patient> get filteredPatients => _filteredPatients;
  List<Appointment> get appointments => _appointments;
  String get currentSearchQuery => _currentSearchQuery;
  String? get currentCabinetCode => _currentCabinetCode; // CHANGED: getter
  String? get currentCabinetName => _currentCabinetName; // NEW: getter for name

  // --- MODIFIED setCurrentCabinetCode ---
  // NEW: Method to set current cabinet code and load associated info
  // Ensures data is cleared when cabinet code is set to null.
  Future<void> setCurrentCabinetCode(String? cabinetCode) async {
    _currentCabinetCode = cabinetCode;
    _currentCabinetName = null; // Reset name when code changes
    if (cabinetCode != null) {
      await _loadCabinetName(); // Load the cabinet name when code is set
    } else {
      // NEW: Clear data lists when cabinet code is removed (e.g., on logout or error)
      print(
        "PatientProvider: Clearing data lists because cabinet code is null.",
      );
      _patients = [];
      _filteredPatients = [];
      _appointments = [];
      _currentSearchQuery = '';
      // _currentCabinetName is already null
    }
    notifyListeners();
    // Optionally reload data for the new cabinet
    // await loadPatients();
    // await loadAppointments();
  }
  // --- END OF MODIFIED setCurrentCabinetCode ---

  // NEW: Helper method to load cabinet name from DB
  Future<void> _loadCabinetName() async {
    if (_currentCabinetCode == null) return;
    try {
      _currentCabinetName = await DatabaseHelper.instance.getCabinetName(
        _currentCabinetCode!,
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
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot load patients.');
      _patients = []; // Clear patients if cabinet code is missing
      _filteredPatients = [];
      notifyListeners();
      return;
    }
    try {
      _patients = await DatabaseHelper.instance.getPatientsWithVisitCount(
        cabinetCode, // CHANGED: clientId -> cabinetCode
      );
      filterPatients(_currentSearchQuery);
    } catch (e) {
      print('Failed to load patients: ${e.toString()}');
      // Consider setting an error state if you re-introduce it
      _patients = [];
      _filteredPatients = [];
    }
    notifyListeners();
  }

  Future<bool> addPatient(Patient p) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot add patient.');
      return false;
    }
    await loadPatients(); // Ensure latest count
    if (_patients.length >= MAX_PATIENT_LIMIT) {
      print('Patient limit reached. Cannot add more patients.');
      return false;
    }
    try {
      // Create a new patient object with the cabinet code
      final patientWithCabinetCode = p.copyWith(
        cabinetCode: cabinetCode,
      ); // CHANGED
      await DatabaseHelper.instance.insertPatient(patientWithCabinetCode);
      await loadPatients();
      return true;
    } catch (e) {
      print('Failed to add patient: ${e.toString()}');
      return false;
    }
  }

  Future<void> updatePatient(Patient p) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot update patient.');
      return;
    }
    try {
      final patientWithCabinetCode = p.copyWith(
        cabinetCode: cabinetCode,
      ); // CHANGED
      await DatabaseHelper.instance.updatePatient(patientWithCabinetCode);
      await loadPatients();
    } catch (e) {
      print('Failed to update patient: ${e.toString()}');
    }
  }

  Future<void> deletePatient(String patientId) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot delete patient.');
      return;
    }
    try {
      await DatabaseHelper.instance.deletePatient(
        patientId,
        cabinetCode,
      ); // CHANGED
      await loadPatients();
    } catch (e) {
      print('Failed to delete patient: ${e.toString()}');
    }
  }

  // --- Visit related methods ---
  Future<List<Visit>> getVisitsForPatient(String patientId) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot get visits.');
      return [];
    }
    try {
      return await DatabaseHelper.instance.getVisitsForPatient(
        patientId,
        cabinetCode, // CHANGED: clientId -> cabinetCode
      );
    } catch (e) {
      print('Failed to get visits: ${e.toString()}');
      return [];
    }
  }

  Future<void> addVisit(Visit visit) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot add visit.');
      return;
    }
    try {
      final visitWithCabinetCode = visit.copyWith(
        cabinetCode: cabinetCode,
      ); // CHANGED
      await DatabaseHelper.instance.insertVisit(visitWithCabinetCode);
      await loadPatients(); // This reloads patients, implicitly updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to add visit: ${e.toString()}');
    }
  }

  Future<void> updateVisit(Visit visit) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot update visit.');
      return;
    }
    try {
      final visitWithCabinetCode = visit.copyWith(
        cabinetCode: cabinetCode,
      ); // CHANGED
      await DatabaseHelper.instance.updateVisit(visitWithCabinetCode);
      notifyListeners();
    } catch (e) {
      print('Failed to update visit: ${e.toString()}');
    }
  }

  Future<void> deleteVisit(String visitId) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot delete visit.');
      return;
    }
    try {
      await DatabaseHelper.instance.deleteVisit(
        visitId,
        cabinetCode,
      ); // CHANGED
      await loadPatients(); // This reloads patients, implicitly updating visit counts.
      notifyListeners();
    } catch (e) {
      print('Failed to delete visit: ${e.toString()}');
    }
  }

  // --- Appointment related methods ---
  Future<void> loadAppointments() async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot load appointments.');
      _appointments = [];
      notifyListeners();
      return;
    }
    try {
      _appointments = await DatabaseHelper.instance.getAllAppointments(
        cabinetCode, // CHANGED: clientId -> cabinetCode
      );
      notifyListeners();
    } catch (e) {
      print('Failed to load appointments: ${e.toString()}');
      _appointments = []; // Ensure list is cleared on error
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    final cabinetCode = _currentCabinetCode;
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot add appointment.');
      // Maybe show an error message to the user via a state variable
      // notifyListeners(); // If you add an error state
      return; // Exit early
    }
    try {
      // Ensure the appointment object has the correct cabinet code
      final appointmentWithCabinetCode = appointment.copyWith(
        cabinetCode: cabinetCode,
      );
      await DatabaseHelper.instance.insertAppointment(
        appointmentWithCabinetCode,
      );
      await loadAppointments(); // Reload the list after successful insert
    } on PostgrestException catch (e) {
      print('Error inserting appointment: $e');
      // Handle the specific RLS error or show a user-friendly message
      // e.g., ScaffoldMessenger.of(context).showSnackBar(...);
      // Re-throw or handle as needed, but don't let it crash the provider state
      rethrow; // Or handle it specifically
    } catch (e) {
      print('Failed to add appointment: $e');
      // Handle other potential errors
      // Maybe show a generic error message
    }
    // notifyListeners(); is called inside loadAppointments()
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot update appointment.');
      return;
    }
    try {
      final appointmentWithCabinetCode = appointment.copyWith(
        cabinetCode: cabinetCode,
      ); // CHANGED
      await DatabaseHelper.instance.updateAppointment(
        appointmentWithCabinetCode,
      );
      await loadAppointments();
    } catch (e) {
      print('Failed to update appointment: ${e.toString()}');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final cabinetCode = _currentCabinetCode; // CHANGED: clientId -> cabinetCode
    if (cabinetCode == null) {
      print('Error: Cabinet code not found. Cannot delete appointment.');
      return;
    }
    try {
      await DatabaseHelper.instance.deleteAppointment(
        appointmentId,
        cabinetCode,
      ); // CHANGED
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
