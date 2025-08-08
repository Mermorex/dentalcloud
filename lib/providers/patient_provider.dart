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
  // Ensures data is loaded BEFORE notifying listeners for the main change.
  Future<void> setCurrentCabinetId(String? cabinetId) async {
    print("PatientProvider: Setting currentCabinetId to '$cabinetId'");

    // Store the old ID to determine if it's actually changing
    final String? oldCabinetId = _currentCabinetId;

    // If the ID is being set to null, clear data immediately and notify.
    if (cabinetId == null) {
      _currentCabinetId = null;
      _currentCabinetName = null;
      print("PatientProvider: Clearing data lists because cabinet ID is null.");
      _patients = [];
      _filteredPatients = [];
      _appointments = [];
      _currentSearchQuery = '';
      notifyListeners(); // Notify that everything is cleared
      return;
    }

    // If the ID is the same as the current one, potentially reload data.
    if (cabinetId == oldCabinetId) {
      print("PatientProvider: Cabinet ID is the same. Reloading data...");
      try {
        await loadPatients();
        await loadAppointments();
        print("PatientProvider: Data reloaded for existing cabinet ID.");
        notifyListeners(); // Notify after data reload
      } catch (e) {
        print(
          "PatientProvider Error: Failed to reload data for existing ID: $e",
        );
        notifyListeners(); // Still notify
      }
      return;
    }

    // --- NEW LOGIC: ID is changing to a new, non-null value ---

    // 1. Clear old data lists immediately to prevent showing stale data
    _patients = [];
    _filteredPatients = [];
    _appointments = [];
    _currentSearchQuery = '';
    _currentCabinetName = null; // Reset name as ID is changing

    // 2. Set the new ID *internally* but DON'T notify main listeners yet
    _currentCabinetId = cabinetId;

    // 3. Load the essential data (patients, appointments) associated with the NEW ID
    //    This is the crucial step: Do the loading BEFORE the main notifyListeners.
    bool dataLoadedSuccessfully = true;
    try {
      print("PatientProvider: Loading initial data for new cabinet ID...");
      await loadPatients(); // Load patients for the new cabinet
      await loadAppointments(); // Load appointments for the new cabinet
      // Load cabinet name for the new cabinet
      await _loadCabinetName();
      print(
        "PatientProvider: Initial data loaded successfully for new cabinet ID.",
      );
    } catch (loadError) {
      dataLoadedSuccessfully = false;
      print(
        "PatientProvider Error: Failed to load initial data for new cabinet ID '$cabinetId': $loadError",
      );
      // Ensure data lists are cleared on failure
      _patients = [];
      _filteredPatients = [];
      _appointments = [];
      _currentCabinetName = null;
    }

    // 4. NOW, notify all listeners that the ID has changed AND the initial data load status.
    print(
      "PatientProvider: Notifying listeners about cabinet ID change and data load status: $dataLoadedSuccessfully",
    );
    notifyListeners();
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

  // --- NEW METHOD: getAllVisits ---
  /// Fetches all visits for the currently selected cabinet.
  /// Returns an empty list if no cabinet is selected or on error.
  Future<List<Visit>> getAllVisits() async {
    final cabinetId = _currentCabinetId; // Get the current cabinet ID
    if (cabinetId == null) {
      print('Error: Cabinet ID not found. Cannot get all visits.');
      return []; // Return empty list if no cabinet ID
    }
    try {
      // Call the DatabaseHelper method to get all visits for the cabinet
      return await DatabaseHelper.instance.getAllVisitsForCabinet(cabinetId);
    } catch (e) {
      print('Failed to get all visits: $e');
      return []; // Return empty list on error
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
