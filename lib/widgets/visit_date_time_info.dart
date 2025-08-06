// lib/widgets/visit_date_time_info.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisitDateTimeInfo extends StatelessWidget {
  final String date; // Expects format like 'yyyy-MM-dd'
  final String time; // Expects format like 'HH:mm' or 'HH:mm AM/PM'
  final bool isTablet;
  final bool showTime; // New parameter

  const VisitDateTimeInfo({
    super.key,
    required this.date,
    required this.time,
    required this.isTablet,
    this.showTime = true, // Default to showing time
  });

  @override
  Widget build(BuildContext context) {
    // You might want to parse 'date' and 'time' if you need different formatting
    // For now, assuming they are already formatted strings.
    String displayText = date;
    if (showTime) {
      displayText += ' à $time'; // Or use 'at' or any separator you prefer
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            color: Colors.teal.shade700,
            size: isTablet ? 32 : 24,
          ),
          const SizedBox(width: 12),
          Text(
            displayText,
            style: GoogleFonts.montserrat(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
