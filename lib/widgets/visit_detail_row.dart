// visit_detail_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitDetailRow extends StatelessWidget {
  final String label;
  // --- FIXED: Made value nullable to align with common patterns ---
  // This allows passing potentially null values safely.
  final String? value;
  // --- END OF FIX ---
  final Color? valueColor;
  final FontWeight? valueFontWeight;

  const VisitDetailRow({
    super.key,
    required this.label,
    this.value, // Now optional/nullable
    this.valueColor,
    this.valueFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    // --- FIXED: Robust check for null, empty, or 'N/A' values ---
    // This prevents rendering empty rows.
    if (value == null || value!.isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }
    // --- END OF FIX ---
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
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value!, // Safe to unwrap after null/empty check
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color:
                    valueColor ??
                    Colors.grey.shade800, // Use provided color or default
                fontWeight:
                    valueFontWeight ??
                    FontWeight.normal, // Use provided weight or default
              ),
            ),
          ),
        ],
      ),
    );
  }
}
