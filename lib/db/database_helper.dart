// lib/db/database_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/appointment.dart';
// For generating UUIDs for local inserts

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  final SupabaseClient _supabase = Supabase.instance.client;

  DatabaseHelper._init();

  /* ---------- CRUD for Patients ---------- */

  Future<int> insertPatient(Patient patient) async {
    try {
      final response = await _supabase
          .from('patients')
          .insert(patient.toMap())
          .select('id');
      if (response.isNotEmpty) {
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error inserting patient: $e');
      rethrow;
    }
  }

  Future<int> updatePatient(Patient patient) async {
    try {
      final response = await _supabase
          .from('patients')
          .update(patient.toMap())
          .eq('id', patient.id)
          .select('id');
      if (response.isNotEmpty) {
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  Future<int> deletePatient(String id, String clientId) async {
    // Added clientId
    try {
      await _supabase
          .from('patients')
          .delete()
          .eq('id', id)
          .eq('client_id', clientId);
      return 1;
    } catch (e) {
      print('Error deleting patient: $e');
      rethrow;
    }
  }

  Future<List<Patient>> getPatientsWithVisitCount(String clientId) async {
    // Added clientId
    try {
      final patientData = await _supabase
          .from('patients')
          .select('*')
          .eq('client_id', clientId) // Filter by client_id
          .order('name', ascending: true);
      final visitData = await _supabase
          .from('visits')
          .select('patient_id')
          .eq('client_id', clientId); // Filter by client_id

      final Map<String, int> visitCounts = {};
      for (var visit in visitData) {
        final String patientId = visit['patient_id'] as String;
        visitCounts[patientId] = (visitCounts[patientId] ?? 0) + 1;
      }

      return patientData.map((map) {
        final patient = Patient.fromMap(map);
        return patient.copyWith(visitCount: visitCounts[patient.id] ?? 0);
      }).toList();
    } catch (e) {
      print('Error getting patients with visit count: $e');
      rethrow;
    }
  }

  Future<List<Patient>> getAllPatients(String clientId) async {
    // Added clientId
    try {
      final response = await _supabase
          .from('patients')
          .select('*')
          .eq('client_id', clientId) // Filter by client_id
          .order('name', ascending: true);
      return response.map((e) => Patient.fromMap(e)).toList();
    } catch (e) {
      print('Error getting all patients: $e');
      rethrow;
    }
  }

  Future<Patient?> getPatientById(String id, String clientId) async {
    // Added clientId
    try {
      final response = await _supabase
          .from('patients')
          .select('*')
          .eq('id', id)
          .eq('client_id', clientId) // Filter by client_id
          .single();
      if (response.isNotEmpty) {
        return Patient.fromMap(response);
      }
      return null;
    } catch (e) {
      print('Error getting patient by ID: $e');
      return null; // Return null if not found or error
    }
  }

  /* ---------- CRUD for Visits ---------- */

  Future<String?> insertVisit(Visit visit) async {
    try {
      final response = await _supabase
          .from('visits')
          .insert(visit.toMap())
          .select('id');
      if (response.isNotEmpty) {
        return response.first['id'] as String;
      }
      return null;
    } catch (e) {
      print('Error inserting visit: $e');
      rethrow;
    }
  }

  Future<int> updateVisit(Visit visit) async {
    try {
      final response = await _supabase
          .from('visits')
          .update(visit.toMap())
          .eq('id', visit.id!)
          .select('id');
      if (response.isNotEmpty) {
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating visit: $e');
      rethrow;
    }
  }

  Future<int> deleteVisit(String id, String clientId) async {
    // Added clientId
    try {
      await _supabase
          .from('visits')
          .delete()
          .eq('id', id)
          .eq('client_id', clientId);
      return 1;
    } catch (e) {
      print('Error deleting visit: $e');
      rethrow;
    }
  }

  Future<List<Visit>> getVisitsForPatient(
    String patientId,
    String clientId,
  ) async {
    // Added clientId
    try {
      final response = await _supabase
          .from('visits')
          .select('*')
          .eq('patient_id', patientId)
          .eq('client_id', clientId) // Filter by client_id
          .order('date', ascending: false)
          .order('time', ascending: false);
      return response.map((e) => Visit.fromMap(e)).toList();
    } catch (e) {
      print('Error getting visits for patient: $e');
      rethrow;
    }
  }

  /* ---------- CRUD for Appointments ---------- */

  Future<int> insertAppointment(Appointment appointment) async {
    try {
      final response = await _supabase
          .from('appointments')
          .insert(appointment.toMap())
          .select('id');
      if (response.isNotEmpty) {
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error inserting appointment: $e');
      rethrow;
    }
  }

  Future<List<Appointment>> getAllAppointments(String clientId) async {
    // Added clientId
    try {
      final response = await _supabase
          .from('appointments')
          .select('*, patients!inner(name)')
          .eq('client_id', clientId) // Filter by client_id
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((e) {
        final Map<String, dynamic> appointmentMap = Map<String, dynamic>.from(
          e,
        );
        if (e['patients'] != null && e['patients'] is Map) {
          appointmentMap['patientName'] = (e['patients'] as Map)['name'];
        }
        return Appointment.fromMap(appointmentMap);
      }).toList();
    } catch (e) {
      print('Error getting all appointments: $e');
      rethrow;
    }
  }

  Future<List<Appointment>> getAppointmentsForPatient(
    String patientId,
    String clientId,
  ) async {
    // Added clientId
    try {
      final response = await _supabase
          .from('appointments')
          .select('*, patients!inner(name)')
          .eq('patient_id', patientId)
          .eq('client_id', clientId) // Filter by client_id
          .order('date', ascending: true)
          .order('time', ascending: true);

      return response.map((e) {
        final Map<String, dynamic> appointmentMap = Map<String, dynamic>.from(
          e,
        );
        if (e['patients'] != null && e['patients'] is Map) {
          appointmentMap['patientName'] = (e['patients'] as Map)['name'];
        }
        return Appointment.fromMap(appointmentMap);
      }).toList();
    } catch (e) {
      print('Error getting appointments for patient: $e');
      rethrow;
    }
  }

  Future<int> updateAppointment(Appointment appointment) async {
    try {
      final response = await _supabase
          .from('appointments')
          .update(appointment.toMap())
          .eq('id', appointment.id!)
          .select('id');
      if (response.isNotEmpty) {
        return 1;
      }
      return 0;
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<int> deleteAppointment(String id, String clientId) async {
    // Added clientId
    try {
      await _supabase
          .from('appointments')
          .delete()
          .eq('id', id)
          .eq('client_id', clientId);
      return 1;
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    print('Supabase client does not require explicit closing like sqflite.');
  }

  Future<void> setupBackupEnvironment() async {
    print('Backup environment setup is not applicable for Supabase.');
  }

  Future<void> backupDatabase() async {
    print('Local database backup is not applicable when using Supabase.');
    print('Use Supabase\'s built-in backup features for your data.');
  }

  Future<void> _cleanupOldBackups(String backupDirPath) async {
    print('Local backup cleanup is not applicable for Supabase.');
  }
}
