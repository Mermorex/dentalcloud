import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitDetailRow extends StatelessWidget {
  final String label;
  final String? value; // Made value nullable to align with PatientDetailRow
  final Color? valueColor;
  final FontWeight? valueFontWeight;

  const VisitDetailRow({
    super.key,
    required this.label,
    this.value, // Now optional
    this.valueColor,
    this.valueFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty || value == 'N/A') {
      // Added 'N/A' check
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ), // Slightly reduced vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600, // Kept bold for emphasis
              fontSize: 15, // Slightly larger font size
              color: Colors.grey.shade800, // Darker grey for labels
            ),
          ),
          Expanded(
            child: Text(
              value!, // Use ! as we've already checked for null/empty
              style: GoogleFonts.montserrat(
                fontSize: 15, // Consistent font size with label
                color:
                    valueColor ??
                    Colors.grey.shade700, // Darker default value color
                fontWeight:
                    valueFontWeight ??
                    FontWeight.w500, // Slightly bolder default
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
