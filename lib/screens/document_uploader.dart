import 'package:dental/db/document_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming you have these files in your project

class PatientDocumentUploader extends StatefulWidget {
  final String patientId;
  final String cabinetId; // Added cabinetId to the constructor

  const PatientDocumentUploader({
    super.key,
    required this.patientId,
    required this.cabinetId,
  });

  @override
  _PatientDocumentUploaderState createState() =>
      _PatientDocumentUploaderState();
}

class _PatientDocumentUploaderState extends State<PatientDocumentUploader> {
  final DocumentService _documentService = DocumentService();
  final _supabase = Supabase.instance.client;

  FilePickerResult? _pickedFileResult;
  bool _isLoading = false;
  String? _uploadStatusMessage;

  // Handles picking a file from the device
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
        'doc',
        'docx',
      ], // Allow various file types
    );

    if (result != null) {
      setState(() {
        _pickedFileResult = result;
        _uploadStatusMessage = null; // Clear previous status message
      });
    }
  }

  // Handles the full upload and database insert flow using the DocumentService
  Future<void> _handleUpload() async {
    if (_pickedFileResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatusMessage = 'Uploading...';
    });

    final platformFile = _pickedFileResult!.files.first;
    if (platformFile.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File data is not available.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _documentService.uploadDocument(
        patientId: widget.patientId,
        cabinetId: widget.cabinetId,
        file: platformFile,
      );

      setState(() {
        _pickedFileResult = null;
        _uploadStatusMessage = 'File uploaded and record created successfully!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully!')),
      );
    } catch (e) {
      print('Upload failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      setState(() {
        _isLoading = false;
        _uploadStatusMessage = 'Upload failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the selected file is an image
    bool isImage = false;
    String? fileName;
    if (_pickedFileResult != null) {
      final extension = _pickedFileResult!.files.first.extension?.toLowerCase();
      isImage = ['jpg', 'jpeg', 'png'].contains(extension);
      fileName = _pickedFileResult!.files.first.name;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Document Uploader')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display a placeholder, the selected file, or the uploaded file
              if (_pickedFileResult != null && isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _pickedFileResult!.files.first.bytes!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_pickedFileResult != null)
                Column(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      size: 200,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fileName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              else
                const Icon(Icons.person, size: 200, color: Colors.grey),

              if (_uploadStatusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(_uploadStatusMessage!),
                ),

              const SizedBox(height: 20),

              // Button to pick a file
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Select File'),
              ),

              const SizedBox(height: 20),

              // Button to upload and save
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _pickedFileResult == null
                          ? null
                          : _handleUpload,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload & Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// NOTE: This version assumes you have a slightly modified `DocumentService`
// that accepts a `PlatformFile` directly, and handles the `supabase.storage.from`
// and database insert logic internally.
// A simplified `DocumentService` that would work with this code could look like this:
/*
class DocumentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> uploadDocument({
    required String patientId,
    required String cabinetId,
    required PlatformFile file,
    String? description,
    String? category,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileName = 'patient-docs/$patientId/${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
    final mimeType = _getMimeType(file.extension ?? '');

    try {
      await _supabase.storage.from('documents').uploadBinary(
        fileName,
        file.bytes!,
        fileOptions: const FileOptions(contentType: 'application/octet-stream'),
      );

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
      }).select();

    } on StorageException {
      // Handle storage errors
      rethrow;
    } catch (e) {
      // Handle other errors
      rethrow;
    }
  }

  String _getMimeType(String ext) {
    final map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return map[ext.toLowerCase()] ?? 'application/octet-stream';
  }
}
*/
