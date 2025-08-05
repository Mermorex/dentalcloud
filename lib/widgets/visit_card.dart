// visit_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../screens/edit_visit_screen.dart';
import 'visit_detail_row.dart'; // Ensure this import is correct

class VisitCard extends StatefulWidget {
  // --- Ensure the constructor explicitly defines required parameters ---
  final Visit visit;
  final String patientId; // This parameter is required based on previous errors
  final VoidCallback onVisitUpdated; // Callback for refresh logic

  const VisitCard({
    super.key,
    required this.visit,
    required this.patientId, // Explicitly required
    required this.onVisitUpdated, // Explicitly required
  });
  // --- END OF FIX ---

  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> {
  bool _isExpanded = false; // State to manage expansion

  String _getPaymentStatus(Visit visit) {
    // --- FIXED: Use consistent property names (amountPaid, totalAmount) ---
    // Ensure these property names match your Visit model definition
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
    // --- END OF FIX ---
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

  @override
  Widget build(BuildContext context) {
    // --- FIXED: Use consistent property names from Visit model ---
    // Ensure these property names match your Visit model definition
    final double totalAmount = widget.visit.totalAmount ?? 0.0;
    final double amountPaid = widget.visit.amountPaid ?? 0.0;
    // --- END OF FIX ---
    final double amountRemaining = totalAmount - amountPaid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                        widget.visit.date, // Display only date initially
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      if (_isExpanded) // Show time only when expanded
                        Text(
                          widget
                              .visit
                              .time, // Ensure 'time' property exists on Visit
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
                    // --- FIXED: Use consistent property names from Visit model ---
                    // Ensure these property names match your Visit model definition
                    VisitDetailRow(label: 'But', value: widget.visit.purpose),
                    VisitDetailRow(
                      label: 'Constatations',
                      value: widget.visit.findings,
                    ),
                    VisitDetailRow(
                      label: 'Traitement',
                      value: widget.visit.treatment,
                    ),
                    if (widget.visit.notes.isNotEmpty) // Check notes content
                      VisitDetailRow(label: 'Notes', value: widget.visit.notes),
                    // --- END OF FIX ---

                    // --- Next Visit Section ---
                    if (widget.visit.nextVisitDate != null &&
                        widget
                            .visit
                            .nextVisitDate!
                            .isNotEmpty) // Check next visit date
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
                                    // --- FIXED: Use consistent property name ---
                                    // Ensure 'nextVisitDate' property exists on Visit
                                    widget.visit.nextVisitDate!,
                                    // --- END OF FIX ---
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
                    const SizedBox(height: 20),
                    _buildSectionTitle('INFORMATIONS DE PAIEMENT'),
                    const SizedBox(height: 12),
                    // Payment Status
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
                    // Payment Amount Details
                    if (totalAmount >
                        0) // Show details only if total amount exists
                      VisitDetailRow(
                        label: 'Montant total',
                        value: '${totalAmount.toStringAsFixed(2)} TND',
                        valueColor: Colors.grey.shade800,
                        valueFontWeight: FontWeight.w600,
                      ),
                    if (amountPaid > 0) // Show paid amount only if it exists
                      VisitDetailRow(
                        label: 'Montant payé',
                        value: '${amountPaid.toStringAsFixed(2)} TND',
                        valueColor: Colors.green.shade700,
                        valueFontWeight: FontWeight.bold,
                      ),
                    if (amountRemaining >
                        0) // Show remaining amount only if it exists
                      VisitDetailRow(
                        label: 'Reste à payer',
                        value: '${amountRemaining.toStringAsFixed(2)} TND',
                        valueColor: Colors.red.shade700,
                        valueFontWeight: FontWeight.bold,
                      ),

                    // --- Action Buttons ---
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.teal.shade700,
                          backgroundColor: Colors.teal.shade50,
                          tooltip: 'Modifier',
                          onPressed: () async {
                            // --- FIXED: Pass the required patientId to EditVisitScreen ---
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVisitScreen(
                                  visit: widget.visit,
                                  patientId: widget
                                      .patientId, // <-- PASS THE REQUIRED patientId
                                ),
                              ),
                            );
                            // Refresh parent list after editing
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
                                // --- FIXED: Use PatientProvider for deletion, it handles cabinetId ---
                                await Provider.of<PatientProvider>(
                                  context,
                                  listen: false,
                                ).deleteVisit(widget.visit.id!);
                                // Refresh parent list after deletion
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
                const SizedBox.shrink(), // Hides content when collapsed
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
}
