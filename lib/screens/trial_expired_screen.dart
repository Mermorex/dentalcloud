// lib/screens/trial_expired_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrialExpiredScreen extends StatelessWidget {
  // Optional: Accept a callback for actions like "Contact Admin" or navigation
  // if initiated from within the app context.
  // final VoidCallback? onContactPressed;
  // const TrialExpiredScreen({super.key, this.onContactPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Consistent background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center items
            children: [
              // Warning Icon
              Icon(
                Icons.lock_clock, // Or Icons.hourglass_bottom, Icons.warning
                size: 100,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 30),

              // Title
              Text(
                'Période d\'essai terminée',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Message
              Text(
                'Votre période d\'essai gratuite est terminée. '
                'Pour continuer à utiliser l\'application, veuillez contacter l\'administrateur ou souscrire à un abonnement.',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Action Button (Optional, e.g., for retrying check or navigating externally)
              // ElevatedButton(
              //   onPressed: onContactPressed ??
              //       () {
              //         // Example action: Open email, show snackbar, etc.
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(content: Text("Contactez l'administrateur")),
              //         );
              //       },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.teal, // Use your app's primary color
              //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text(
              //     'Contacter l\'administrateur',
              //     style: GoogleFonts.montserrat(
              //       fontSize: 18,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
