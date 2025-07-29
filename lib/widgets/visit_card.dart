// visit_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../screens/edit_visit_screen.dart';
import 'visit_detail_row.dart';

class VisitCard extends StatefulWidget {
  final Visit visit;
  final String patientId;
  final VoidCallback onVisitUpdated;

  const VisitCard({
    Key? key,
    required this.visit,
    required this.patientId,
    required this.onVisitUpdated,
  }) : super(key: key);

  @override
  State<VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<VisitCard> {
  bool _isExpanded = false; // State to manage expansion

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

  @override
  Widget build(BuildContext context) {
    final double totalAmount = widget.visit.totalAmount ?? 0.0;
    final double amountPaid = widget.visit.amountPaid ?? 0.0;
    final double amountRemaining = totalAmount - amountPaid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        // Use InkWell for tap feedback
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded; // Toggle the expanded state
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade100],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Always visible Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date and Time Display
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
                                widget.visit.time,
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Action Buttons (always visible or move them inside expanded content)
                    // For this example, keeping them always visible for quick access.
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.blue.shade600,
                          backgroundColor: Colors.blue.shade100,
                          tooltip: 'Modifier la visite',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditVisitScreen(
                                  visit: widget.visit,
                                  patientId: widget.patientId,
                                ),
                              ),
                            );
                            widget.onVisitUpdated();
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.delete,
                          color: Colors.red.shade600,
                          backgroundColor: Colors.red.shade100,
                          tooltip: 'Supprimer la visite',
                          onPressed: () async {
                            final bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Supprimer la visite',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Êtes-vous sûr de vouloir supprimer cette visite ?',
                                  style: GoogleFonts.montserrat(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                    ),
                                    child: Text(
                                      'Annuler',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (widget.visit.id != null) {
                                        await Provider.of<PatientProvider>(
                                          context,
                                          listen: false,
                                        ).deleteVisit(widget.visit.id!);
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      'Supprimer',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              widget
                                  .onVisitUpdated(); // This line is crucial for refresh
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Expanded Content
              AnimatedSize(
                // Animates the size change smoothly
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Visit Information Section
                            _buildSectionTitle('INFORMATIONS DE VISITE'),
                            const SizedBox(height: 12),
                            VisitDetailRow(
                              label: 'But',
                              value: widget.visit.purpose,
                            ),
                            VisitDetailRow(
                              label: 'Constatations',
                              value: widget.visit.findings,
                            ),
                            VisitDetailRow(
                              label: 'Traitement',
                              value: widget.visit.treatment,
                            ),
                            if (widget.visit.notes != null &&
                                widget.visit.notes!.isNotEmpty)
                              VisitDetailRow(
                                label: 'Notes',
                                value: widget.visit.notes!,
                              ),

                            // Next Visit Section
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
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
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

                            // Payment Information Section
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
                                      color: _getPaymentStatusColor(
                                        widget.visit,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Payment Amount Details
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
                                value:
                                    '${amountRemaining.toStringAsFixed(2)} TND',
                                valueColor: Colors.red.shade700,
                                valueFontWeight: FontWeight.bold,
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(), // Hides content when collapsed
              ),
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
