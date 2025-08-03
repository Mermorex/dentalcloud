// lib/widgets/disconnect_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable Disconnect button widget.
///
/// Takes a required [onPressed] callback to handle the disconnection logic.
class DisconnectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isTablet; // Or use MediaQuery directly inside if preferred
  final bool isInAppBar; // Optional: To adjust style slightly if needed

  const DisconnectButton({
    super.key,
    required this.onPressed,
    this.isTablet = false,
    this.isInAppBar = false, // Default style
  });

  @override
  Widget build(BuildContext context) {
    // Determine size based on isTablet or screen width if not passed
    final bool useTabletSize =
        isTablet; // Or MediaQuery.of(context).size.width >= 600;
    final double iconSize = useTabletSize ? 32.0 : 28.0;
    final double buttonPadding = useTabletSize ? 12.0 : 8.0;

    return IconButton(
      icon: Icon(Icons.logout, size: iconSize, color: Colors.teal.shade700),
      onPressed: onPressed, // Call the provided function
      tooltip: 'Déconnexion',
      padding: EdgeInsets.all(buttonPadding), // Adjust padding if needed
      // You can add visual tweaks based on isInAppBar if necessary
      // For example, different padding or background on app bar vs rail
    );
  }
}
