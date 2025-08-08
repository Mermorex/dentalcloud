// lib/screens/patient_detail_screen.dart
import 'package:dental/db/document_service.dart';
import 'package:dental/widgets/patient_documents_tab.dart';
import 'package:dental/widgets/patient_info_tab.dart';
import 'package:dental/widgets/patient_visits_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/main_button.dart';
import '../utils/pdf_helper.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/patient_document.dart';
import '../providers/patient_provider.dart';
import '../screens/edit_patient_screen.dart';
import '../widgets/detail_card.dart';
import '../widgets/patient_detail_row.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Patient _currentPatient;
  final DocumentService _documentService = DocumentService();

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient;
    _tabController = TabController(
      length: 3, // Info, Visits, Documents
      vsync: this,
    );
  }

  Future<void> _refreshPatientInfo() async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    try {
      await patientProvider.loadPatients();
      final updatedPatient = patientProvider.patients.firstWhere(
        (p) => p.id == _currentPatient.id,
        orElse: () => _currentPatient,
      );
      if (updatedPatient.id != null && mounted) {
        setState(() {
          _currentPatient = updatedPatient;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'actualisation: $e')),
        );
      }
    }
  }

  Future<void> _confirmAndDeletePatient(
    BuildContext context,
    String patientId,
  ) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce patient?',
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
        await Provider.of<PatientProvider>(
          context,
          listen: false,
        ).deletePatient(patientId);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = _currentPatient;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.teal.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Retour',
          ),
        ),
        title: Text(
          patient.name,
          style: GoogleFonts.montserrat(
            fontSize: isTablet ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        centerTitle: true,
        actions: [
          // --- PDF Export Icon Button ---
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf,
              color: Colors.red.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () async {
              try {
                // Fetch visits directly for PDF generation
                final List<Visit> currentVisits =
                    await Provider.of<PatientProvider>(
                      context,
                      listen: false,
                    ).getVisitsForPatient(patient.id!);
                if (!mounted) return;
                final snackBar = SnackBar(
                  content: Text('Génération du PDF en cours...'),
                  duration: const Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                await PdfHelper.generatePatientPdf(patient, currentVisits);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la génération du PDF: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                debugPrint("Error generating PDF: $e");
              }
            },
            tooltip: 'Exporter en PDF',
          ),
          // --- Edit Patient Icon Button ---
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.teal.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () async {
              final updatedPatient = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPatientScreen(patient: patient),
                ),
              );
              if (!mounted) return;
              if (updatedPatient != null && updatedPatient is Patient) {
                setState(() {
                  _currentPatient = updatedPatient;
                });
              }
            },
            tooltip: 'Modifier le patient',
          ),
          // --- Delete Patient Icon Button ---
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () {
              _confirmAndDeletePatient(context, patient.id!);
            },
            tooltip: 'Supprimer le patient',
          ),
          // --- Upload Document Icon Button REMOVED ---
          // The upload button has been removed from the AppBar.
          // Upload functionality is now available within the Documents tab.
        ],
      ),
      body: Column(
        children: [
          // --- Tab Bar ---
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.teal.shade600,
              indicatorWeight: 3,
              labelColor: Colors.teal.shade800,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Informations'),
                Tab(text: 'Visites'),
                Tab(text: 'Documents'),
              ],
            ),
          ),
          // --- Tab Content ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- Patient Information Tab ---
                PatientInfoTab(
                  patient: _currentPatient,
                  onRefresh: _refreshPatientInfo,
                ),
                // --- Visits Tab ---
                PatientVisitsTab(
                  patientId: _currentPatient.id!,
                  onRefresh: () async {
                    await _refreshPatientInfo();
                  },
                  onVisitAdded: _refreshPatientInfo,
                ),
                // --- Documents Tab ---
                PatientDocumentsTab(
                  patientId: _currentPatient.id!,
                  onRefresh: () async {
                    // The tab handles its own refresh internally.
                  },
                  documentService: _documentService,
                  cabinetId: Provider.of<PatientProvider>(
                    context,
                    listen: false,
                  ).currentCabinetId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The _pickAndUploadDocumentDirect method is no longer needed in the AppBar
  // and has been removed. The upload logic is now handled within PatientDocumentsTab.

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
