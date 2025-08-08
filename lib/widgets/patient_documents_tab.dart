// lib/screens/patient_documents_tab.dart
// (or lib/widgets/patient_documents_tab.dart if that's your structure)
import 'package:dental/db/document_service.dart';
import 'package:dental/models/patient_document.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// Import dart:html for web-specific download functionality
import 'dart:html' as html;
import 'dart:typed_data';

class PatientDocumentsTab extends StatefulWidget {
  final String patientId;
  final Future<void> Function() onRefresh;
  final DocumentService documentService;
  final String? cabinetId;
  const PatientDocumentsTab({
    super.key,
    required this.patientId,
    required this.onRefresh,
    required this.documentService,
    this.cabinetId,
  });

  @override
  State<PatientDocumentsTab> createState() => _PatientDocumentsTabState();
}

class _PatientDocumentsTabState extends State<PatientDocumentsTab> {
  late Future<List<PatientDocument>> _documentsFuture;
  late DocumentService _documentService;

  @override
  void initState() {
    super.initState();
    _documentService = widget.documentService;
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    print("Fetching documents for patient ID: '${widget.patientId}'");
    setState(() {
      _documentsFuture = _documentService.getDocumentsForPatient(
        widget.patientId,
      );
    });
  }

  // NEW METHOD: Handle picking and uploading a document from within the tab
  Future<void> _pickAndUploadDocument() async {
    try {
      if (widget.cabinetId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible de déterminer le cabinet.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        final PlatformFile file = result.files.single;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Téléchargement de ${file.name}...'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Call the injected document service to upload
        await _documentService.uploadDocument(
          patientId: widget.patientId,
          cabinetId: widget.cabinetId!,
          file: file,
          description: 'Document téléchargé depuis PatientDocumentsTab',
          category: 'General',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${file.name} téléchargé avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the document list after successful upload
          _fetchDocuments();
          // Optionally notify parent screen if needed
          await widget.onRefresh();
        }
      } else {
        // User canceled the picker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sélection du fichier annulée.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print("PatientDocumentsTab: Error uploading document: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles downloading a document for the web platform.
  /// Fetches the file data and triggers a browser download prompt.
  Future<void> _viewDocument(PatientDocument document) async {
    try {
      // --- Vérification null pour document.filePath ---
      if (document.filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Chemin du document manquant.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print(
          "PatientDocumentsTab: Document filePath is null for document ID: ${document.id}",
        );
        return;
      }

      // Affiche un snackbar de chargement
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Préparation du téléchargement de ${document.fileName}...',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 1. Obtenir l'URL signée
      final String? signedUrlString = await _documentService.getDownloadUrl(
        document.filePath!,
      );
      if (signedUrlString == null) {
        throw Exception('Impossible d\'obtenir l\'URL du document.');
      }
      final Uri signedUri = Uri.parse(signedUrlString);

      // 2. Télécharger le contenu du fichier (en bytes)
      final http.Response response = await http.get(signedUri);
      if (response.statusCode != 200) {
        throw Exception(
          'Échec du téléchargement: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      // 3. Préparer les données pour le téléchargement via le navigateur
      final Uint8List bytes = response.bodyBytes;
      final String fileName = document.fileName ?? 'document';
      // Use the document's MIME type or a default
      final String contentType =
          document.fileType ?? 'application/octet-stream';

      // 4. Créer un objet Blob et déclencher le téléchargement
      final html.Blob blob = html.Blob([bytes], contentType);
      final String url = html.Url.createObjectUrl(blob);

      // Créer un élément <a> temporaire pour déclencher le téléchargement
      final html.AnchorElement anchor = html.AnchorElement(href: url)
        // ..target = '_blank' // REMOVE this line for better mobile compatibility
        ..download = fileName; // Suggest the filename

      // Ajouter l'élément au DOM, cliquer dessus, puis le retirer
      html.document.body!.children.add(anchor);

      // --- ADD a small delay for mobile browsers ---
      await Future.delayed(Duration(milliseconds: 100));

      anchor.click();
      html.document.body!.children.remove(anchor);

      // Révoquer l'URL de l'objet pour libérer la mémoire
      html.Url.revokeObjectUrl(url);

      // 5. Informer l'utilisateur que le téléchargement a été initié
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${document.fileName} prêt pour téléchargement! Vérifiez les téléchargements de votre navigateur.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      print("Téléchargement initié via navigateur pour : $fileName");
    } catch (e) {
      if (mounted) {
        print(
          "PatientDocumentsTab: Error initiating web download for document: $e",
        );
        String userMessage = 'Erreur lors du téléchargement du document.';
        // Spécifiez des messages d'erreur plus précis si possible
        if (e is http.ClientException ||
            e.toString().contains('SocketException')) {
          userMessage = 'Erreur réseau. Vérifiez votre connexion.';
        } else if (e.toString().contains('404')) {
          userMessage = 'Document non trouvé sur le serveur.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmAndDeleteDocument(PatientDocument document) async {
    // --- Add null checks for safety ---
    if (document.id == null || document.filePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur: ID ou chemin du document manquant pour la suppression.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      print(
        "PatientDocumentsTab: Cannot delete document, missing id or filePath. ID: ${document.id}, Path: ${document.filePath}",
      );
      return;
    }

    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le document "${document.fileName}"?',
            style: GoogleFonts.montserrat(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text(
                'Annuler',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Supprimer',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (confirm == true) {
      try {
        await _documentService.deleteDocument(document.id!, document.filePath!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document "${document.fileName}" supprimé avec succès!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _fetchDocuments(); // Refresh the list after deletion
          await widget.onRefresh(); // Notify parent
        }
      } catch (e) {
        if (mounted) {
          print(
            "PatientDocumentsTab: Error deleting document (ID: ${document.id}): $e",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression du document: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _getIconForFileType(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType == 'application/pdf') {
      return Icons.picture_as_pdf;
    } else if (mimeType == 'application/msword' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchDocuments();
        await widget.onRefresh();
      },
      child: FutureBuilder<List<PatientDocument>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Erreur lors du chargement des documents:',
                    style: GoogleFonts.montserrat(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: _fetchDocuments,
                    child: Text('Réessayer', style: GoogleFonts.montserrat()),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final documents = snapshot.data!;
            return Column(
              children: [
                // --- Add Document Button ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _pickAndUploadDocument,
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Ajouter un Document',
                      style: GoogleFonts.montserrat(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // --- Document List or Empty State ---
                if (documents.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun document trouvé pour ce patient.',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final document = documents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            leading: Icon(
                              _getIconForFileType(document.fileType),
                              color: Colors.teal.shade700,
                              size: 30,
                            ),
                            title: Text(
                              document.fileName ?? 'Document sans nom',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  document.fileType ?? 'Type inconnu',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${(document.fileSize ?? 0) > 0 ? '${(document.fileSize! / 1024).toStringAsFixed(1)} KB' : 'Taille inconnue'}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (document.createdAt != null)
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                      'fr_FR',
                                    ).format(document.createdAt!),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            // onTap triggers the download for web
                            onTap: () => _viewDocument(document),
                            onLongPress: () =>
                                _confirmAndDeleteDocument(document),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          } else {
            // Fallback if snapshot has no data and no error
            return const Center(
              child: Text('Aucune donnée de document disponible.'),
            );
          }
        },
      ),
    );
  }
}
