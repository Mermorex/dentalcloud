import 'dart:typed_data';
import 'package:dental/models/patient_document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer; // Add this import for better logging

class DocumentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload a document for a patient
  Future<void> uploadDocument({
    required String patientId,
    required String cabinetId,
    required PlatformFile file,
    String? description,
    String? category,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }

    // Generate a unique file name for the storage bucket
    final fileName =
        'patient-docs/$patientId/${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
    final mimeType = _getMimeType(file.extension ?? '');

    try {
      // Upload the file's bytes to Supabase Storage
      await _supabase.storage
          .from('patient-documents')
          .uploadBinary(
            fileName,
            file.bytes!,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: mimeType,
            ),
          );

      // Insert metadata into the database
      await _supabase.from('patient_documents').insert({
        'patient_id': patientId,
        'cabinet_id': cabinetId,
        'uploaded_by': user.id,
        'file_name': file.name,
        'file_path': fileName,
        'file_type': mimeType,
        'file_size': file.size,
        'description': description,
        'category': category,
      });
    } on PostgrestException catch (e) {
      // If DB insert fails, try to remove the uploaded file to prevent orphans
      try {
        await _supabase.storage.from('patient-documents').remove([fileName]);
      } catch (storageError) {
        print('Failed to rollback storage upload: $storageError');
      }
      throw Exception('Database insert failed: ${e.message}');
    } on StorageException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      // Handle other potential errors
      throw Exception('An unexpected error occurred during upload: $e');
    }
  }

  /// Get documents for a patient
  Future<List<PatientDocument>> getDocumentsForPatient(String patientId) async {
    try {
      print(
        "DocumentService: Querying DB for patient_id = '$patientId'",
      ); // Add this line
      final response = await _supabase
          .from('patient_documents')
          .select()
          .eq('patient_id', patientId) // This line uses the logged patientId
          .order('created_at', ascending: false);
      print(
        "DocumentService: Query response length: ${response.length}",
      ); // Add this line

      return (response as List)
          .map((item) => PatientDocument.fromJson(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load documents: ${e.message}');
    }
  }

  /// Get signed URL to view a file
  Future<String?> getDownloadUrl(String filePath) async {
    try {
      final String signedUrl = await _supabase.storage
          .from('patient-documents')
          .createSignedUrl(filePath, 3600); // URL expires in 1 hour
      return signedUrl;
    } on StorageException catch (e) {
      print('Error creating signed URL: ${e.message}');
      return null;
    }
  }

  /// Delete document

  /// Delete document
  Future<void> deleteDocument(String documentId, String filePath) async {
    try {
      // 1. Delete the document record from the database
      await _supabase.from('patient_documents').delete().eq('id', documentId);

      // 2. Delete the file from storage
      await _supabase.storage.from('patient-documents').remove([filePath]);
    } on PostgrestException catch (e) {
      throw Exception('Failed to delete document from database: ${e.message}');
    } on StorageException catch (e) {
      // If the database record is deleted but the file isn't, we still want to throw an error.
      throw Exception('Failed to delete file from storage: ${e.message}');
    }
  }

  /// Helper to guess MIME type
  String _getMimeType(String ext) {
    final map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return map[ext.toLowerCase()] ?? 'application/octet-stream';
  }
}
