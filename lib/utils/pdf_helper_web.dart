// lib/utils/pdf_helper_web.dart
import 'dart:js' as js;
import 'dart:html' as html; // <--- This is the missing import for 'document'
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/patient.dart';
import '../models/visit.dart';

class PdfHelper {
  static Future<void> generatePatientPdf(
    Patient patient,
    List<Visit> visits,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginBottom: 1.5 * PdfPageFormat.mm,
          marginTop: 1.5 * PdfPageFormat.mm,
          marginLeft: 1.5 * PdfPageFormat.mm,
          marginRight: 1.5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) => [
          _buildHeader(patient),
          pw.SizedBox(height: 20),
          _buildSectionTitle('Informations de base'),
          _buildInfoTable([
            ['Nom:', patient.name],
            ['Âge:', patient.age.toString()],
            ['Genre:', patient.gender],
            ['Téléphone:', patient.phone ?? 'N/A'],
            ['Email:', patient.email ?? 'N/A'],
            ['Adresse:', patient.address ?? 'N/A'],
            ['Date de naissance:', patient.dateOfBirth ?? 'N/A'],
            ['Langue principale:', patient.primaryLanguage ?? 'N/A'],
          ]),
          pw.SizedBox(height: 15),
          _buildSectionTitle('Contact d\'urgence'),
          _buildInfoTable([
            ['Nom:', patient.emergencyContactName ?? 'N/A'],
            ['Téléphone:', patient.emergencyContactPhone ?? 'N/A'],
          ]),
          pw.SizedBox(height: 15),
          _buildSectionTitle('Antécédents médicaux'),
          _buildInfoTable([
            ['Alertes:', patient.alerts ?? 'N/A'],
            ['Maladies systémiques:', patient.systemicDiseases ?? 'N/A'],
            ['Médicaments:', patient.medications ?? 'N/A'],
            ['Allergies:', patient.allergies ?? 'N/A'],
            [
              'Chirurgies passées:',
              patient.pastSurgeriesHospitalizations ?? 'N/A',
            ],
            ['Facteurs de mode de vie:', patient.lifestyleFactors ?? 'N/A'],
            [
              'Grossesse/Allaitement:',
              patient.pregnancyLactationStatus ?? 'N/A',
            ],
          ]),
          pw.SizedBox(height: 15),
          _buildSectionTitle('Antécédents dentaires'),
          _buildInfoTable([
            ['Plainte principale:', patient.chiefComplaint ?? 'N/A'],
            ['Traitements passés:', patient.pastDentalTreatments ?? 'N/A'],
            ['Problèmes antérieurs:', patient.previousDentalProblems ?? 'N/A'],
            ['Hygiène buccale:', patient.oralHygieneHabits ?? 'N/A'],
            ['Dernière visite dentaire:', patient.lastDentalVisit ?? 'N/A'],
            ['Dernière radio:', patient.lastXRay ?? 'N/A'],
          ]),
          pw.SizedBox(height: 15),
          if (visits.isNotEmpty) ...[
            _buildSectionTitle('Historique des visites'),
            ...visits.map((visit) => _buildVisitCard(visit)),
          ],
          pw.Spacer(),
          _buildFooter(),
        ],
      ),
    );

    // Generate PDF bytes
    final Uint8List pdfBytes = await pdf.save();

    // Trigger download in web browser
    final String filename = '${patient.name}_Rapport_Patient.pdf';

    // Create a Blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a temporary anchor element and trigger the download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    // Clean up the URL
    html.Url.revokeObjectUrl(url);
  }

  static pw.Widget _buildHeader(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#008080'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rapport médical du patient',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${patient.name} - ID: ${patient.id}',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E0F2F7'),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#00695C'),
        ),
      ),
    );
  }

  static pw.Widget _buildInfoTable(List<List<String>> data) {
    return pw.Table.fromTextArray(
      cellAlignment: pw.Alignment.topLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
      },
      headers: ['Champ', 'Valeur'],
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
    );
  }

  static pw.Widget _buildVisitCard(Visit visit) {
    final double totalAmount = visit.totalAmount ?? 0.0;
    final double amountPaid = visit.amountPaid ?? 0.0;
    final double remainingToPay = totalAmount - amountPaid;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Date de visite: ${visit.date} à ${visit.time}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              color: PdfColor.fromHex('#008080'),
            ),
          ),
          pw.Divider(),
          pw.Row(
            children: [
              pw.Text(
                'Objectif: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text(visit.purpose)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                'Constatations: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text(visit.findings)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                'Traitement: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text(visit.treatment)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                'Notes: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text(visit.notes)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                'Date de la prochaine visite: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text(visit.nextVisitDate ?? 'N/A')),
            ],
          ),
          if (visit.totalAmount != null && visit.totalAmount! >= 0)
            pw.Row(
              children: [
                pw.Text(
                  'Montant total: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#00695C'),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '${visit.totalAmount!.toStringAsFixed(2)} DT',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#00695C'),
                    ),
                  ),
                ),
              ],
            ),
          if (visit.amountPaid != null && visit.amountPaid! >= 0)
            pw.Row(
              children: [
                pw.Text(
                  'Montant payé: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#00695C'),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '${visit.amountPaid!.toStringAsFixed(2)} DT',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#00695C'),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Généré par l\'application Clinique Dentaire',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }
}
