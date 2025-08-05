// lib/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart'; // Import Appointment model

/// A reusable widget to display appointment information.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final Map<String, String> statusTranslations;
  final bool isImportant;
  final bool isTablet;
  final VoidCallback? onTap; // Add the onTap callback

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
    required this.statusTranslations,
    this.isImportant = false,
    required this.isTablet,
    this.onTap, // Include it in the constructor
  });

  String _getTranslatedStatus(String status) {
    return statusTranslations[status] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade700;
      case 'Completed':
        return Colors.green.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      case 'No Show':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getLightStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade50;
      case 'Completed':
        return Colors.green.shade50;
      case 'Cancelled':
        return Colors.red.shade50;
      case 'No Show':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getCardBorderColor(String status, bool isImportant) {
    if (isImportant) {
      return Colors.red.shade400;
    }
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade200;
      case 'Completed':
        return Colors.green.shade200;
      case 'Cancelled':
        return Colors.red.shade200;
      case 'No Show':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(appointment.status);
    final Color lightStatusColor = _getLightStatusColor(appointment.status);
    final Color cardBackgroundColor = isImportant
        ? Colors.red.shade50
        : Colors.white;
    final Color cardBorderColor = _getCardBorderColor(
      appointment.status,
      isImportant,
    );
    final Color patientNameColor = isImportant
        ? Colors.red.shade800
        : Colors.grey.shade800;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      // Wrap the main content with InkWell for tap handling
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback
        borderRadius: BorderRadius.circular(20), // Match card border radius
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      patientName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 22 : 20,
                        color: patientNameColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Icon(
                    Icons.access_time,
                    size: isTablet ? 24 : 20,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    appointment.time,
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 19 : 17,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isTablet ? 18 : 16,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(appointment.date))}',
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (appointment.notes.isNotEmpty) ...[
                SizedBox(height: isTablet ? 10 : 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: isTablet ? 18 : 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Expanded(
                      child: Text(
                        'Notes: ${appointment.notes}',
                        style: GoogleFonts.montserrat(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: isTablet ? 15 : 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 7 : 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Statut: ${_getTranslatedStatus(appointment.status)}',
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor.darken(0.1), // Use the extension method
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Move the ColorManipulation extension here
extension ColorManipulation on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
