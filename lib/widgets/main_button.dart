// lib/widgets/main_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double iconSize;
  final double fontSize;
  final Object? heroTag;

  const MainButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor = Colors.teal,
    this.foregroundColor = Colors.white,
    this.iconSize = 28.0,
    this.fontSize = 18.0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
      icon: Icon(icon, size: iconSize),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      // Modern button enhancements
      hoverColor: backgroundColor.withOpacity(0.8), // Slightly darker on hover
      splashColor: foregroundColor.withOpacity(0.2), // Subtle splash effect
      elevation: 6.0, // More pronounced shadow
      highlightElevation: 12.0, // Even more pronounced shadow when pressed
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Snug tap area
      heroTag: heroTag,
    );
  }
}
