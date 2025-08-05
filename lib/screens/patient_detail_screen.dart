// lib/screens/patient_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for date formatting
// --- NEW/UPDATED: Import MainButton and PdfHelper ---
import '../widgets/main_button.dart'; // Adjust path if needed
import '../utils/pdf_helper.dart'; // Adjust path if needed. Ensure PdfHelper has a generatePatientPdf method that accepts (Patient, List<Visit>).
// --- END OF NEW/UPDATED ---

import '../models/patient.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../screens/edit_patient_screen.dart';
import '../screens/add_visit_screen.dart';
// Import UI components
import '../widgets/detail_card.dart';
import '../widgets/patient_detail_row.dart';
import '../widgets/visit_card.dart'; // Assuming this is the correct path

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Visit>> _visitsFuture;
  late TabController _tabController;
  late Patient
  _currentPatient; // Holds the current patient data for potential updates

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient; // Initialize with the passed patient
    _fetchVisits();
    _tabController = TabController(length: 2, vsync: this);
    // Removed _tabController.addListener/_handleTabSelection as it wasn't fully implemented
    // and StreamBuilder (below) is a better approach for conditional FAB.
  }

  // --- FIXED: Ensure _fetchVisits returns Future<void> ---
  Future<void> _fetchVisits() async {
    setState(() {
      // --- FIXED: Pass the patient ID correctly ---
      _visitsFuture = Provider.of<PatientProvider>(
        context,
        listen: false,
      ).getVisitsForPatient(_currentPatient.id!); // Use _currentPatient.id
      // --- END OF FIX ---
    });
  }

  // --- END OF FIX ---
  // --- FIXED: Create a separate refresh function returning Future<void> ---
  Future<void> _refreshPatientInfo() async {
    // --- FIXED: Get patient list and find the specific patient ---
    // Since PatientProvider doesn't seem to have getPatientById,
    // reload the list and find the patient.
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    try {
      await patientProvider.loadPatients(); // Reload the patient list
      // Find the updated patient data in the refreshed list
      final updatedPatient = patientProvider.patients.firstWhere(
        (p) => p.id == _currentPatient.id,
        orElse: () =>
            _currentPatient, // Fallback to current if not found (shouldn't happen)
      );
      if (updatedPatient.id != null && mounted) {
        setState(() {
          _currentPatient = updatedPatient; // Update the local state
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
  // --- END OF FIX ---

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
        // Navigate back to the patient list after successful deletion
        Navigator.of(context).pop(); // Or Navigator.of(context).pop(true)
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la suppression: $e')),
          );
        }
      }
    }
  }

  Widget _buildVisitCountRow(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note, color: Colors.teal.shade700),
          const SizedBox(width: 10),
          Text(
            'Nombre total de visites: $count',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use _currentPatient for displaying patient details
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
        // --- MODIFIED: Updated AppBar actions to include PDF export ---
        actions: [
          // --- NEW: PDF Export Icon Button ---
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf, // Use the PDF icon
              color: Colors.red.shade600, // Or your preferred color
              size: isTablet ? 32 : 28,
            ),
            onPressed: () async {
              try {
                // Show a loading indicator while generating the PDF
                if (!mounted) return;
                final snackBar = SnackBar(
                  content: Text('Génération du PDF en cours...'),
                  duration: const Duration(seconds: 1), // Show briefly
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                // Fetch visits for the PDF. We need the actual list, not the Future.
                // We can await the _visitsFuture to get the current list.
                final List<Visit> currentVisits = await _visitsFuture;

                // Call the PDF helper function.
                // Pass the current patient data and the fetched visits.
                await PdfHelper.generatePatientPdf(
                  patient,
                  currentVisits,
                ); // Pass patient and visits
                // The PdfHelper should handle the download in web environments.
              } catch (e) {
                // Handle potential errors during PDF generation
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la génération du PDF: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                debugPrint("Error generating PDF: $e"); // Log for debugging
              }
            },
            tooltip: 'Exporter en PDF',
          ),
          // --- END OF NEW ---
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.teal.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () async {
              // Expect a result back from EditPatientScreen
              final updatedPatient = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPatientScreen(patient: patient),
                ),
              );
              if (!mounted) return;
              // If an updated patient object is returned, update the state
              if (updatedPatient != null && updatedPatient is Patient) {
                setState(() {
                  _currentPatient = updatedPatient; // Update the patient object
                  // Optionally, refresh visits if editing might affect them
                  // _fetchVisits();
                });
              }
            },
            tooltip: 'Modifier le patient',
          ),
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
        ],
        // --- END OF MODIFICATION ---
      ),
      body: Column(
        children: [
          // --- Tab Bar ---
          Container(
            color: Colors.white, // Background for tabs
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
              ],
            ),
          ),
          // --- Tab Content ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- Patient Information Tab ---
                // --- FIXED: Use the correct refresh function ---
                RefreshIndicator(
                  onRefresh:
                      _refreshPatientInfo, // Use the Future<void> returning function
                  // --- END OF FIX ---
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DetailCard(
                          title: 'Informations de base',
                          children: [
                            PatientDetailRow(label: 'Nom', value: patient.name),
                            PatientDetailRow(
                              label: 'Âge',
                              value: patient.age?.toString() ?? 'N/A',
                            ),
                            PatientDetailRow(
                              label: 'Sexe',
                              value: patient.gender == 'Male'
                                  ? 'Homme'
                                  : (patient.gender == 'Female'
                                        ? 'Femme'
                                        : 'N/A'),
                            ),
                            PatientDetailRow(
                              label: 'Téléphone',
                              value: patient.phone,
                            ),
                            // --- FIXED: Use the correct model parameter name for lastXray ---
                            PatientDetailRow(
                              label: 'Dernière radiographie',
                              value: patient.lastXray,
                            ), // <-- CHANGED from lastXRay
                            // --- END OF FIX ---
                            // --- Display Visit Count ---
                            if (patient.visitCount != null)
                              _buildVisitCountRow(patient.visitCount!),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DetailCard(
                          title: 'Démographie',
                          children: [
                            PatientDetailRow(
                              label: 'Date de naissance',
                              value: patient.dateOfBirth,
                            ),
                            PatientDetailRow(
                              label: 'Email',
                              value: patient.email,
                            ),
                            PatientDetailRow(
                              label: 'Adresse',
                              value: patient.address,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Contact d\'urgence (Nom)',
                              value: patient.emergencyContactName,
                            ),
                            PatientDetailRow(
                              label: 'Contact d\'urgence (Téléphone)',
                              value: patient.emergencyContactPhone,
                            ),
                            PatientDetailRow(
                              label: 'Langue principale',
                              value: patient.primaryLanguage,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DetailCard(
                          title: 'Antécédents médicaux',
                          children: [
                            PatientDetailRow(
                              label: 'Alertes',
                              value: patient.alerts,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Maladies systémiques',
                              value: patient.systemicDiseases,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Médicaments',
                              value: patient.medications,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Allergies',
                              value: patient.allergies,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label:
                                  'Chirurgies antérieures / Hospitalisations',
                              value: patient.pastSurgeriesHospitalizations,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Facteurs de mode de vie',
                              value: patient.lifestyleFactors,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Statut de grossesse/allaitement',
                              value: patient.pregnancyLactationStatus,
                              isMultiLine: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DetailCard(
                          title: 'Antécédents dentaires',
                          children: [
                            PatientDetailRow(
                              label: 'Plainte principale',
                              value: patient.chiefComplaint,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Traitements dentaires antérieurs',
                              value: patient.pastDentalTreatments,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Problèmes dentaires antérieurs',
                              value: patient.previousDentalProblems,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Habitudes d\'hygiène buccale',
                              value: patient.oralHygieneHabits,
                              isMultiLine: true,
                            ),
                            PatientDetailRow(
                              label: 'Dernière visite dentaire',
                              value: patient.lastDentalVisit,
                            ),
                            // Ensure lastXray is displayed correctly here too if needed
                            // It's already shown in 'Informations de base' above based on snippets
                          ],
                        ),
                        const SizedBox(height: 80), // Spacer at the bottom
                      ],
                    ),
                  ),
                ),
                // --- Visits Tab ---
                // --- MODIFIED: Replaced FAB with MainButton inside the tab content, aligned to the right ---
                RefreshIndicator(
                  onRefresh: _fetchVisits,
                  child: FutureBuilder<List<Visit>>(
                    future: _visitsFuture,
                    builder: (context, snapshot) {
                      Widget content;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        content = const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        content = Center(
                          child: Text('Erreur: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        final visits = snapshot.data!;
                        if (visits.isEmpty) {
                          content = const Center(
                            child: Text(
                              'Aucune visite enregistrée pour ce patient.',
                            ),
                          );
                        } else {
                          content = ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: visits.length,
                            itemBuilder: (context, index) {
                              final visit = visits[index];
                              // --- Ensure VisitCard gets required arguments ---
                              return VisitCard(
                                visit: visit,
                                patientId: patient.id!, // Pass patient ID
                                onVisitUpdated:
                                    _fetchVisits, // Refresh callback
                              );
                              // --- END OF FIX ---
                            },
                          );
                        }
                      } else {
                        content = const Center(
                          child: Text('Aucune donnée de visite disponible.'),
                        );
                      }

                      // --- Simplified: MainButton placed directly inside the tab content ---
                      // Wrap content and button in a Column.
                      // The button area is a Row with a Spacer to push the button right.
                      return Column(
                        children: [
                          Expanded(child: content),
                          // Show the MainButton row only on the Visits tab (index 1)
                          // Padding is handled within the Row for better control
                          if (_tabController.index == 1) ...[
                            const SizedBox(height: 16),
                            // Use a Row for horizontal layout
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  const Spacer(), // This pushes the button to the right
                                  // --- Use MainButton widget ---
                                  MainButton(
                                    label:
                                        'Ajouter une visite', // Use 'label' as per your MainButton widget
                                    icon: Icons.add, // Pass icon
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddVisitScreen(
                                            patientId: _currentPatient
                                                .id!, // Use _currentPatient.id
                                          ),
                                        ),
                                      );
                                      if (!mounted) return;
                                      _fetchVisits(); // Refresh visits
                                    },
                                    // backgroundColor, foregroundColor, iconSize, fontSize use defaults from MainButton
                                    // You can override them here if needed, e.g.:
                                    // backgroundColor: Colors.blue, // Example override
                                  ),
                                  // --- END OF MainButton usage ---
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      );
                      // --- END OF NEW ---
                    },
                  ),
                ),
                // --- END OF MODIFICATION ---
              ],
            ),
          ),
        ],
      ),
      // --- REMOVED: The old floatingActionButton ---
      // floatingActionButton: AnimatedSwitcher(...),
      // --- END OF REMOVAL ---
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
