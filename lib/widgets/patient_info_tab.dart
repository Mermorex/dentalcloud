// lib/screens/patient_info_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../widgets/detail_card.dart';
import '../widgets/patient_detail_row.dart';

class PatientInfoTab extends StatelessWidget {
  final Patient patient;
  final Future<void> Function() onRefresh;

  const PatientInfoTab({
    super.key,
    required this.patient,
    required this.onRefresh,
  });

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
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return RefreshIndicator(
      onRefresh: onRefresh,
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
                      : (patient.gender == 'Female' ? 'Femme' : 'N/A'),
                ),
                PatientDetailRow(label: 'Téléphone', value: patient.phone),
                PatientDetailRow(
                  label: 'Dernière radiographie',
                  value: patient.lastXray,
                ),
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
                PatientDetailRow(label: 'Email', value: patient.email),
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
                  label: 'Chirurgies antérieures / Hospitalisations',
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
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
