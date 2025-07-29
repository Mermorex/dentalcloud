// main.dart
import 'package:dental/models/patient.dart';
import 'package:dental/providers/patient_provider.dart';
import 'package:dental/screens/add_patient_screen.dart';
import 'package:dental/screens/edit_patient_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this

import 'package:dental/screens/home_screen.dart'; // Assuming HomeScreen is your main entry point after Auth
import 'package:dental/screens/auth_screen.dart'; // Import AuthScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for 'fr_FR' (or your desired locale)
  // This needs to be called before any DateFormat operations if you plan to use specific locales.
  await initializeDateFormatting('fr_FR', null); // IMPORTANT: Add this line

  // Initialize Supabase (replace with your actual URL and Anon Key)
  await Supabase.initialize(
    url:
        'https://jymqyezkyzzvuvqephdh.supabase.co', // Replace with your Supabase Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bXF5ZXpreXp6dnV2cWVwaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDkwNjcsImV4cCI6MjA2OTEyNTA2N30.CqnJ-yVjf5M_y6DzpZ5sRsBT_9HlFPPm8sn5vMThYPo', // Replace with your Supabase Public Anon Key
    // debug: true, // Optional: Set to true for logging Supabase activities -- REMOVED
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PatientProvider())],
      child: MaterialApp(
        title: 'Dental Clinic App',
        debugShowCheckedModeBanner: false, // Add this line
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.white,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
        // Use a Consumer or check session to decide initial route
        home: const AuthScreen(), // Start with AuthScreen
        routes: {
          '/home': (context) =>
              const HomeScreen(), // Route to HomeScreen after auth
          '/add-patient': (context) => const AddPatientScreen(),
          '/edit-patient': (context) => EditPatientScreen(
            patient: ModalRoute.of(context)!.settings.arguments as Patient,
          ),
        },
      ),
    );
  }
}
