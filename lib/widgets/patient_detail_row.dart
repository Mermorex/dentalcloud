// lib/widgets/patient_detail_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isMultiLine;

  const PatientDetailRow({
    super.key,
    required this.label,
    this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink(); // Hides the row if the value is null or empty
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isMultiLine
          ? Column(
              // Use Column for multi-line display
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: ',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade800, // Changed color for emphasis
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ), // Spacing between label and multiline value
                Text(
                  value!,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  // No maxLines or overflow needed here, as it's a multiline text field
                ),
              ],
            )
          : Row(
              // Keep Row for single-line display
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: ',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: Text(
                    value!,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                    maxLines: 1, // Restrict to single line
                    overflow:
                        TextOverflow.ellipsis, // Use ellipsis for overflow
                  ),
                ),
              ],
            ),
    );
  }
}
