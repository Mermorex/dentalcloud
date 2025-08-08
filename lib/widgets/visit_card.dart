// lib/widgets/visit_card.dart
import 'package:dental/db/document_service.dart'; // This import can potentially be removed if DocumentService is no longer used elsewhere
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart'; // Commented out as it was marked NEW but not used in the provided snippet

import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../screens/edit_visit_screen.dart';
import 'visit_detail_row.dart';
// import '../models/patient_document.dart'; // Commented out as it's related to the removed section

class VisitCard extends StatefulWidget {
  final Visit visit;
  final String patientId;
  final VoidCallback onVisitUpdated;
  const VisitCard({
    super.key,
    required this.visit,
    required this.patientId,
    required this.onVisitUpdated,
  });
  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> {
  bool _isExpanded = false;
  // --- REMOVED: State for documents ---
  // List<PatientDocument> _documents = [];
  // bool _isLoadingDocuments = false;
  // final DocumentService _documentService = DocumentService(); // REMOVED: DocumentService instance

  String _getPaymentStatus(Visit visit) {
    if (visit.totalAmount == null || visit.totalAmount == 0) {
      return 'Non spécifié';
    }
    if (visit.amountPaid == null || visit.amountPaid == 0) {
      return 'Non payé';
    }
    if (visit.amountPaid! >= visit.totalAmount!) {
      return 'Payé';
    }
    return 'Partiellement payé';
  }

  Color _getPaymentStatusColor(Visit visit) {
    final status = _getPaymentStatus(visit);
    switch (status) {
      case 'Payé':
        return Colors.green.shade600;
      case 'Partiellement payé':
        return Colors.orange.shade600;
      case 'Non payé':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPaymentStatusIcon(Visit visit) {
    final status = _getPaymentStatus(visit);
    switch (status) {
      case 'Payé':
        return Icons.check_circle_rounded;
      case 'Partiellement payé':
        return Icons.hourglass_top_rounded;
      case 'Non payé':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // --- REMOVED: Method to fetch documents for the patient ---
  // Future<void> _fetchDocuments() async { ... }

  // --- REMOVED: Method to view a document ---
  // Future<void> _viewDocument(PatientDocument document) async { ... }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = widget.visit.totalAmount ?? 0.0;
    final double amountPaid = widget.visit.amountPaid ?? 0.0;
    final double amountRemaining = totalAmount - amountPaid;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
          // --- REMOVED: Fetch documents when expanding ---
          // if (_isExpanded) {
          //   _fetchDocuments();
          // }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Visit Header (Date, Time, Expand Icon) ---
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.visit.date,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      if (_isExpanded)
                        Text(
                          widget.visit.time,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.teal.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // --- Expanded Content ---
              if (_isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Visit Information Section ---
                    _buildSectionTitle('INFORMATIONS DE VISITE'),
                    const SizedBox(height: 12),
                    VisitDetailRow(label: 'But', value: widget.visit.purpose),
                    VisitDetailRow(
                      label: 'Constatations',
                      value: widget.visit.findings,
                    ),
                    VisitDetailRow(
                      label: 'Traitement',
                      value: widget.visit.treatment,
                    ),
                    if (widget.visit.notes.isNotEmpty)
                      VisitDetailRow(label: 'Notes', value: widget.visit.notes),
                    // --- Next Visit Section ---
                    if (widget.visit.nextVisitDate != null &&
                        widget.visit.nextVisitDate!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildSectionTitle('PROCHAIN RENDEZ-VOUS'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: Colors.blue.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.visit.nextVisitDate!,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    // --- Payment Information Section ---
                    _buildSectionTitle('INFORMATIONS DE PAIEMENT'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(
                          widget.visit,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getPaymentStatusColor(
                            widget.visit,
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getPaymentStatusIcon(widget.visit),
                            color: _getPaymentStatusColor(widget.visit),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Statut: ${_getPaymentStatus(widget.visit)}',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getPaymentStatusColor(widget.visit),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (totalAmount > 0)
                      VisitDetailRow(
                        label: 'Montant total',
                        value: '${totalAmount.toStringAsFixed(2)} TND',
                        valueColor: Colors.grey.shade800,
                        valueFontWeight: FontWeight.w600,
                      ),
                    if (amountPaid > 0)
                      VisitDetailRow(
                        label: 'Montant payé',
                        value: '${amountPaid.toStringAsFixed(2)} TND',
                        valueColor: Colors.green.shade700,
                        valueFontWeight: FontWeight.bold,
                      ),
                    if (amountRemaining > 0)
                      VisitDetailRow(
                        label: 'Reste à payer',
                        value: '${amountRemaining.toStringAsFixed(2)} TND',
                        valueColor: Colors.red.shade700,
                        valueFontWeight: FontWeight.bold,
                      ),
                    // --- REMOVED: Documents Section ---
                    // _buildSectionTitle('DOCUMENTS PATIENT'),
                    // if (_isLoadingDocuments)
                    //   const Center(
                    //     child: CircularProgressIndicator(color: Colors.teal),
                    //   )
                    // else if (_documents.isEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //     child: Text(
                    //       'Aucun document trouvé pour ce patient.',
                    //       style: GoogleFonts.montserrat(
                    //         color: Colors.grey.shade600,
                    //         fontStyle: FontStyle.italic,
                    //       ),
                    //     ),
                    //   )
                    // else
                    //   Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey.shade50,
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(color: Colors.grey.shade300),
                    //     ),
                    //     child: ListView.builder(
                    //       shrinkWrap: true,
                    //       physics: const NeverScrollableScrollPhysics(),
                    //       itemCount: _documents.length,
                    //       itemBuilder: (context, index) {
                    //         final document = _documents[index];
                    //         return ListTile(
                    //           leading: Icon(
                    //             _getIconForFileType(
                    //               document.fileType ??
                    //                   'application/octet-stream',
                    //             ),
                    //             color: Colors.teal.shade700,
                    //           ),
                    //           title: Text(
                    //             document.fileName ?? 'Document sans nom',
                    //             style: GoogleFonts.montserrat(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //           contentPadding: const EdgeInsets.symmetric(
                    //             horizontal: 16.0,
                    //             vertical: 4.0,
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // --- END OF REMOVED ---
                    // --- Action Buttons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.teal.shade700,
                          backgroundColor: Colors.teal.shade50,
                          tooltip: 'Modifier',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVisitScreen(
                                  visit: widget.visit,
                                  patientId: widget.patientId,
                                ),
                              ),
                            );
                            widget.onVisitUpdated();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.delete,
                          color: Colors.red.shade700,
                          backgroundColor: Colors.red.shade50,
                          tooltip: 'Supprimer',
                          onPressed: () async {
                            final bool? confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Confirmer la suppression',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    'Êtes-vous sûr de vouloir supprimer cette visite?',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'Annuler',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Supprimer',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm == true) {
                              try {
                                await Provider.of<PatientProvider>(
                                  context,
                                  listen: false,
                                ).deleteVisit(widget.visit.id!);
                                widget.onVisitUpdated();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Visite supprimée avec succès!',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  print("VisitCard: Error deleting visit: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur lors de la suppression: $e',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.teal.shade600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  // --- REMOVED: Helper to get icon based on MIME type ---
  // IconData _getIconForFileType(String mimeType) { ... }
  // --- END OF REMOVED ---
}
