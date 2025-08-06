// lib/db/database_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/appointment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final SupabaseClient _supabase = Supabase.instance.client;

  DatabaseHelper._init();

  /* ---------- CRUD for Patients ---------- */

  /// Inserts a new patient.
  /// Returns 1 on success, 0 on failure.
  Future<int> insertPatient(Patient patient) async {
    try {
      final response = await _supabase
          .from('patients')
          .insert(patient.toMap())
          .select('id');

      // Check if response is a list and contains data with a non-null 'id'
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] != null) {
          // Insertion successful and ID retrieved
          return 1;
        }
      }
      print(
        'Insert patient response indicates failure or missing ID: $response',
      );
      return 0;
    } catch (e) {
      print('Error inserting patient: $e');
      // Consider rethrowing or returning a specific error code based on needs
      // rethrow; // Or handle specific Postgrest/SUPABASE errors
      return 0; // Indicate failure
    }
  }

  /// Updates an existing patient.
  /// Returns 1 on success, 0 on failure.
  Future<int> updatePatient(Patient patient) async {
    // Ensure patient.id is not null before updating
    if (patient.id == null) {
      print('Error updating patient: Patient ID is null.');
      return 0;
    }
    try {
      final response = await _supabase
          .from('patients')
          .update(patient.toMap())
          .eq('id', patient.id!) // Safe to unwrap after null check
          .select('id');

      // Check if response indicates successful update
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] != null) {
          return 1;
        }
      }
      print(
        'Update patient response indicates failure or missing ID: $response',
      );
      return 0;
    } catch (e) {
      print('Error updating patient: $e');
      return 0;
    }
  }

  /// Deletes a patient by ID within a specific cabinet.
  /// Returns 1 on success.
  Future<int> deletePatient(String id, String cabinetId) async {
    try {
      // Perform the deletion
      await _supabase
          .from('patients')
          .delete()
          .eq('id', id) // id is non-nullable String
          .eq('cabinet_id', cabinetId); // cabinetId is non-nullable String
      return 1;
    } catch (e) {
      print('Error deleting patient (ID: $id, Cabinet: $cabinetId): $e');
      rethrow; // Rethrow to let caller handle
    }
  }

  /// Retrieves patients for a cabinet, including visit counts.
  Future<List<Patient>> getPatientsWithVisitCount(String cabinetId) async {
    try {
      final patientData = await _supabase
          .from('patients')
          .select('*')
          .eq('cabinet_id', cabinetId)
          .order('name', ascending: true);

      final visitData = await _supabase
          .from('visits')
          .select('patient_id')
          .eq('cabinet_id', cabinetId);

      final Map<String, int> visitCounts = {};
      for (var visit in visitData) {
        // Ensure visit['patient_id'] is not null before using
        if (visit['patient_id'] is String) {
          final String patientId = visit['patient_id'] as String;
          visitCounts[patientId] = (visitCounts[patientId] ?? 0) + 1;
        } else {
          print("Warning: Found visit with null or invalid patient_id: $visit");
        }
      }

      // Map patient data to Patient objects, adding visit counts
      return patientData.map((map) {
        // Ensure map['id'] is not null before creating Patient
        if (map['id'] == null) {
          print("Warning: Found patient data with null id: $map");
          // Decide how to handle this - skip or create with placeholder?
          // For now, let Patient.fromMap handle it or throw if it requires non-null id
        }
        final patient = Patient.fromMap(map);
        // Use null-aware operator for patient.id
        return patient.copyWith(visitCount: visitCounts[patient.id ?? ''] ?? 0);
      }).toList();
    } catch (e) {
      print(
        'Error getting patients with visit count (Cabinet: $cabinetId): $e',
      );
      rethrow;
    }
  }

  /// Retrieves all patients for a cabinet.
  Future<List<Patient>> getAllPatients(String cabinetId) async {
    try {
      final response = await _supabase
          .from('patients')
          .select('*')
          .eq('cabinet_id', cabinetId)
          .order('name', ascending: true);
      // Map response to Patient objects
      return response.map((e) {
        // Ensure e['id'] is not null if Patient.fromMap requires it
        if (e['id'] == null) {
          print(
            "Warning: Found patient data with null id in getAllPatients: $e",
          );
          // Handle accordingly
        }
        return Patient.fromMap(e);
      }).toList();
    } catch (e) {
      print('Error getting all patients (Cabinet: $cabinetId): $e');
      rethrow;
    }
  }

  /// Retrieves a single patient by ID within a cabinet.
  Future<Patient?> getPatientById(String id, String cabinetId) async {
    try {
      final response = await _supabase
          .from('patients')
          .select('*')
          .eq('id', id) // id is non-nullable String
          .eq('cabinet_id', cabinetId) // cabinetId is non-nullable String
          .single(); // Expects a single map or throws if not found/ambiguous

      // Check if response is a Map (successful single retrieval)
      if (response is Map<String, dynamic>) {
        // Optional: Check if response['id'] matches the input id for extra safety
        // if (response['id'] == id) { ... }
        return Patient.fromMap(response);
      }
      // If response is not a map (e.g., empty list or error state from single()),
      // it implies the patient wasn't found.
      print('Patient with ID $id not found in cabinet $cabinetId.');
      return null;
    } on PostgrestException catch (e) {
      // Specific handling for Supabase errors (e.g., not found)
      if (e.code == 'PGRST116') {
        // Hypothetical code for "single() not found"
        print(
          'Patient with ID $id not found in cabinet $cabinetId (Supabase code).',
        );
        return null;
      }
      print(
        'Postgrest Error getting patient by ID (ID: $id, Cabinet: $cabinetId): $e',
      );
      return null; // Or rethrow depending on desired behavior
    } catch (e) {
      print('Error getting patient by ID (ID: $id, Cabinet: $cabinetId): $e');
      return null;
    }
  }

  /* ---------- CRUD for Visits ---------- */

  /// Inserts a new visit.
  /// Returns the new visit's ID on success, null on failure.
  Future<String?> insertVisit(Visit visit) async {
    try {
      final response = await _supabase
          .from('visits')
          .insert(visit.toMap())
          .select('id');

      // Check if response is a list and contains data with a non-null 'id'
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] is String) {
          return firstItem['id'] as String; // Return the new ID
        }
      }
      print('Insert visit response indicates failure or missing ID: $response');
      return null;
    } catch (e) {
      print('Error inserting visit: $e');
      return null;
    }
  }

  /// Updates an existing visit.
  /// Returns 1 on success, 0 on failure.
  Future<int> updateVisit(Visit visit) async {
    // Ensure visit.id is not null before updating
    if (visit.id == null) {
      print('Error updating visit: Visit ID is null.');
      return 0;
    }
    try {
      final response = await _supabase
          .from('visits')
          .update(visit.toMap())
          .eq('id', visit.id!) // Safe to unwrap after null check
          .select('id');

      // Check if response indicates successful update
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] != null) {
          return 1;
        }
      }
      print('Update visit response indicates failure or missing ID: $response');
      return 0;
    } catch (e) {
      print('Error updating visit (ID: ${visit.id}): $e');
      return 0;
    }
  }

  /// Deletes a visit by ID within a specific cabinet.
  /// Returns 1 on success.
  Future<int> deleteVisit(String id, String cabinetId) async {
    try {
      await _supabase
          .from('visits')
          .delete()
          .eq('id', id) // id is non-nullable String
          .eq('cabinet_id', cabinetId); // cabinetId is non-nullable String
      return 1;
    } catch (e) {
      print('Error deleting visit (ID: $id, Cabinet: $cabinetId): $e');
      rethrow;
    }
  }

  /// Retrieves all visits for a specific patient within a cabinet.
  Future<List<Visit>> getVisitsForPatient(
    String patientId,
    String cabinetId,
  ) async {
    try {
      final response = await _supabase
          .from('visits')
          .select('*')
          .eq('patient_id', patientId) // patientId is non-nullable String
          .eq('cabinet_id', cabinetId) // cabinetId is non-nullable String
          .order('date', ascending: false)
          .order('time', ascending: false);
      // Map response to Visit objects
      return response.map((e) {
        // Ensure e['id'] is not null if Visit.fromMap or subsequent operations require it
        if (e['id'] == null) {
          print(
            "Warning: Found visit data with null id in getVisitsForPatient: $e",
          );
          // Handle accordingly
        }
        return Visit.fromMap(e);
      }).toList();
    } catch (e) {
      print(
        'Error getting visits for patient (Patient ID: $patientId, Cabinet: $cabinetId): $e',
      );
      rethrow;
    }
  }

  // --- NEW METHOD: getAllVisitsForCabinet ---
  /// Retrieves all visits for a specific cabinet.
  Future<List<Visit>> getAllVisitsForCabinet(String cabinetId) async {
    try {
      final response = await _supabase
          .from('visits')
          .select('*') // Select all visit fields
          .eq('cabinet_id', cabinetId) // Filter by cabinet ID
          .order(
            'date',
            ascending: false,
          ) // Order by date descending (newest first)
          .order('time', ascending: false); // Then order by time descending

      // Map response to Visit objects
      return response.map((e) {
        // Optional: Add a check for null e['id'] if Visit.fromMap requires it
        // if (e['id'] == null) { print("Warning: Visit data with null id: $e"); }
        return Visit.fromMap(e);
      }).toList();
    } catch (e) {
      print(
        'Error getting all visits for cabinet (Cabinet ID: $cabinetId): $e',
      );
      rethrow; // Let the caller handle the error
    }
  }

  /* ---------- CRUD for Appointments ---------- */

  /// Inserts a new appointment.
  /// Returns 1 on success, 0 on failure.
  Future<int> insertAppointment(Appointment appointment) async {
    try {
      final response = await _supabase
          .from('appointments')
          .insert(appointment.toMap())
          .select('id');

      // Check if response is a list and contains data with a non-null 'id'
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] != null) {
          return 1;
        }
      }
      print(
        'Insert appointment response indicates failure or missing ID: $response',
      );
      return 0;
    } catch (e) {
      print('Error inserting appointment: $e');
      return 0;
    }
  }

  /// Retrieves all appointments for a cabinet, including patient names.
  Future<List<Appointment>> getAllAppointments(String cabinetId) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('*, patients!inner(name)')
          .eq('cabinet_id', cabinetId)
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((e) {
        final Map<String, dynamic> appointmentMap = Map<String, dynamic>.from(
          e,
        );
        // Safely extract patient name if available
        if (e['patients'] != null && e['patients'] is Map<String, dynamic>) {
          final patientData = e['patients'] as Map<String, dynamic>;
          appointmentMap['patientName'] =
              patientData['name'] as String?; // Handle potential null name
        } else {
          appointmentMap['patientName'] = null; // Explicitly set if not found
        }
        // Ensure e['id'] is not null if Appointment.fromMap requires it
        if (e['id'] == null) {
          print(
            "Warning: Found appointment data with null id in getAllAppointments: $e",
          );
          // Handle accordingly
        }
        return Appointment.fromMap(appointmentMap);
      }).toList();
    } catch (e) {
      print('Error getting all appointments (Cabinet: $cabinetId): $e');
      rethrow;
    }
  }

  /// Retrieves appointments for a specific patient within a cabinet.
  Future<List<Appointment>> getAppointmentsForPatient(
    String patientId,
    String cabinetId,
  ) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('*, patients!inner(name)')
          .eq('patient_id', patientId) // patientId is non-nullable String
          .eq('cabinet_id', cabinetId) // cabinetId is non-nullable String
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((e) {
        final Map<String, dynamic> appointmentMap = Map<String, dynamic>.from(
          e,
        );
        // Safely extract patient name if available
        if (e['patients'] != null && e['patients'] is Map<String, dynamic>) {
          final patientData = e['patients'] as Map<String, dynamic>;
          appointmentMap['patientName'] =
              patientData['name'] as String?; // Handle potential null name
        } else {
          appointmentMap['patientName'] = null; // Explicitly set if not found
        }
        // Ensure e['id'] is not null if Appointment.fromMap requires it
        if (e['id'] == null) {
          print(
            "Warning: Found appointment data with null id in getAppointmentsForPatient: $e",
          );
          // Handle accordingly
        }
        return Appointment.fromMap(appointmentMap);
      }).toList();
    } catch (e) {
      print(
        'Error getting appointments for patient (Patient ID: $patientId, Cabinet: $cabinetId): $e',
      );
      rethrow;
    }
  }

  /// Fetches the cabinet name using its unique identifier (UUID).
  Future<String?> getCabinetName(String cabinetId) async {
    try {
      final response = await _supabase
          .from('cabinets')
          .select('name')
          .eq('id', cabinetId) // cabinetId is non-nullable String
          .single(); // Expects a single map

      // Check if response is a Map and contains 'name'
      if (response is Map<String, dynamic> && response['name'] is String) {
        return response['name'] as String?;
      }
      print('Cabinet name not found for ID: $cabinetId. Response: $response');
      return null;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Hypothetical code for "single() not found"
        print('Cabinet with ID $cabinetId not found (Supabase code).');
        return null;
      }
      print('Postgrest Error getting cabinet name (ID: $cabinetId): $e');
      return null;
    } catch (e) {
      print('Error getting cabinet name (ID: $cabinetId): $e');
      return null;
    }
  }

  /// Updates an existing appointment.
  /// Returns 1 on success, 0 on failure.
  Future<int> updateAppointment(Appointment appointment) async {
    // Ensure appointment.id is not null before updating
    if (appointment.id == null) {
      print('Error updating appointment: Appointment ID is null.');
      return 0;
    }
    try {
      final response = await _supabase
          .from('appointments')
          .update(appointment.toMap())
          .eq('id', appointment.id!) // Safe to unwrap after null check
          .select('id');

      // Check if response indicates successful update
      if (response is List && response.isNotEmpty) {
        final firstItem = response.first;
        if (firstItem is Map<String, dynamic> && firstItem['id'] != null) {
          return 1;
        }
      }
      print(
        'Update appointment response indicates failure or missing ID: $response',
      );
      return 0;
    } catch (e) {
      print('Error updating appointment (ID: ${appointment.id}): $e');
      return 0;
    }
  }

  /// Deletes an appointment by ID within a specific cabinet.
  /// Returns 1 on success.
  Future<int> deleteAppointment(String id, String cabinetId) async {
    try {
      await _supabase
          .from('appointments')
          .delete()
          .eq('id', id) // id is non-nullable String
          .eq('cabinet_id', cabinetId); // cabinetId is non-nullable String
      return 1;
    } catch (e) {
      print('Error deleting appointment (ID: $id, Cabinet: $cabinetId): $e');
      rethrow;
    }
  }

  // --- Unused methods (can be removed if not used) ---
  Future<void> close() async {}
  Future<void> setupBackupEnvironment() async {}
  Future<void> backupDatabase() async {}
  Future<void> _cleanupOldBackups(String backupDirPath) async {}
}
