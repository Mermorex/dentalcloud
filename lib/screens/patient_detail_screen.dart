// lib/screens/patient_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import 'edit_patient_screen.dart';
import 'add_visit_screen.dart';
import '../utils/pdf_helper.dart';
import '../widgets/main_button.dart';
// Import the new components
import '../widgets/detail_card.dart';
import '../widgets/patient_detail_row.dart';
import '../widgets/visit_card.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({required this.patient, Key? key})
    : super(key: key);

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  Future<List<Visit>>? _visitsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      // Rebuilds the Scaffold to update the floatingActionButton visibility
      // based on _tabController.index
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _fetchVisits() {
    setState(() {
      // <--- ADDED setState here
      _visitsFuture = Provider.of<PatientProvider>(
        context,
        listen: false,
      ).getVisitsForPatient(widget.patient.id);
    }); // <--- ADDED setState here
  }

  Future<void> _confirmAndDeletePatient(
    BuildContext context,
    String patientId,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Supprimer le patient',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce patient et toutes les visites associées ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Annuler',
                style: GoogleFonts.montserrat(color: Colors.teal),
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
      await Provider.of<PatientProvider>(
        context,
        listen: false,
      ).deletePatient(patientId);
      if (!mounted) return;
      Navigator.of(context).pop(); // Go back after deletion
    }
  }

  Widget _buildVisitCountRow(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, color: Colors.teal.shade700, size: 24),
          const SizedBox(width: 10),
          Text(
            'Nombre de visites: $count',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Consistent with PatientsList
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow for a flatter look
        toolbarHeight:
            80, // Adjust height as needed, consistent with PatientsList
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.teal.shade600,
            size: isTablet ? 28 : 24,
          ), // Consistent icon style
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(
            left: 0.0,
          ), // Adjust padding for title if necessary
          child: Text(
            patient.name,
            style: GoogleFonts.montserrat(
              fontSize: isTablet ? 32 : 28, // Consistent font size
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800, // Consistent color
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.teal.shade600,
                    size: isTablet ? 32 : 28, // Consistent icon style
                  ),
                  onPressed: () async {
                    try {
                      final List<Visit> visits =
                          await Provider.of<PatientProvider>(
                            context,
                            listen: false,
                          ).getVisitsForPatient(patient.id);
                      if (!mounted) return;
                      await PdfHelper.generatePatientPdf(patient, visits);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'PDF généré avec succès!',
                            style: GoogleFonts.montserrat(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erreur lors de la génération du PDF: $e',
                            style: GoogleFonts.montserrat(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.teal.shade600,
                    size: isTablet ? 32 : 28,
                  ), // Consistent icon style
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPatientScreen(patient: patient),
                      ),
                    );
                    if (!mounted) return;
                    setState(() {
                      _fetchVisits();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade600,
                    size: isTablet ? 32 : 28,
                  ), // Consistent icon style
                  onPressed: () {
                    _confirmAndDeletePatient(context, patient.id);
                  },
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal.shade600, // Adjusted to match theme
          indicatorWeight: 3,
          labelColor: Colors.teal.shade800, // Adjusted to match theme
          unselectedLabelColor: Colors.grey.shade600, // Adjusted to match theme
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.montserrat(),
          tabs: const [
            Tab(text: 'Détails'),
            Tab(text: 'Visites'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.blue.shade50],
                ),
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              // Details Tab
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DetailCard(
                              title: 'Informations de base',
                              children: [
                                PatientDetailRow(
                                  label: 'Nom',
                                  value: patient.name,
                                ),
                                PatientDetailRow(
                                  label: 'Âge',
                                  value: patient.age.toString(),
                                ),
                                PatientDetailRow(
                                  label: 'Sexe',
                                  value: patient.gender == 'Male'
                                      ? 'Homme'
                                      : 'Femme',
                                ),
                                PatientDetailRow(
                                  label: 'Téléphone',
                                  value: patient.phone,
                                ),
                              ],
                            ),
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
                                  label: 'Contact d\'urgence',
                                  value: patient.emergencyContactName,
                                ),
                                PatientDetailRow(
                                  label: 'Téléphone d\'urgence',
                                  value: patient.emergencyContactPhone,
                                ),
                                PatientDetailRow(
                                  label: 'Langue principale',
                                  value: patient.primaryLanguage,
                                ),
                              ],
                            ),
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
                                  label: 'Chirurgies antérieures',
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
                                PatientDetailRow(
                                  label: 'Plainte principale',
                                  value: patient.chiefComplaint,
                                  isMultiLine: true,
                                ),
                              ],
                            ),
                            DetailCard(
                              title: 'Antécédents dentaires',
                              children: [
                                PatientDetailRow(
                                  label: 'Traitements dentaires passés',
                                  value: patient.pastDentalTreatments,
                                  isMultiLine: true,
                                ),
                                PatientDetailRow(
                                  label: 'Problèmes dentaires antérieurs',
                                  value: patient.previousDentalProblems,
                                  isMultiLine: true,
                                ),
                                PatientDetailRow(
                                  label: 'Habitudes d\'hygiène bucco-dentaire',
                                  value: patient.oralHygieneHabits,
                                  isMultiLine: true,
                                ),
                                PatientDetailRow(
                                  label: 'Dernière visite dentaire',
                                  value: patient.lastDentalVisit,
                                ),
                                PatientDetailRow(
                                  label: 'Dernière radiographie',
                                  value: patient.lastXRay,
                                ),
                              ],
                            ),
                            if (patient.visitCount != null)
                              _buildVisitCountRow(patient.visitCount!),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Visits Tab
              Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<Visit>>(
                      future: _visitsFuture,
                      initialData: const [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading visits: ${snapshot.error}',
                              style: GoogleFonts.montserrat(),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucune visite trouvée.',
                              style: GoogleFonts.montserrat(),
                            ),
                          );
                        } else {
                          final visits = snapshot.data!;
                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: visits.length,
                            itemBuilder: (context, index) {
                              final visit = visits[index];
                              return VisitCard(
                                visit: visit,
                                patientId: patient.id,
                                onVisitUpdated:
                                    _fetchVisits, // Pass callback to refresh
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _tabController.index == 1
          ? MainButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddVisitScreen(patientId: patient.id),
                  ),
                );
                if (!mounted) return;
                setState(() {
                  _fetchVisits();
                });
              },
              label: 'Ajouter une visite',
              icon: Icons.add,
            )
          : null,
    );
  }
}
