// lib/widgets/patient_detail_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool isMultiLine;

  const PatientDetailRow({
    Key? key,
    required this.label,
    this.value,
    this.isMultiLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
              maxLines: isMultiLine ? null : 1,
              overflow: isMultiLine ? TextOverflow.clip : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
