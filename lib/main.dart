// lib/main.dart
import 'package:dental/models/patient.dart';
import 'package:dental/providers/patient_provider.dart';
import 'package:dental/screens/add_patient_screen.dart';
import 'package:dental/screens/edit_patient_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dental/screens/home_screen.dart';
import 'package:dental/screens/auth_screen.dart';
import 'package:dental/screens/signup_screen.dart'; // Make sure to import your SignUpScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

  await Supabase.initialize(
    url:
        'https://jymqyezkyzzvuvqephdh.supabase.co', // Replace with your Supabase Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bXF5ZXpreXp6dnV2cWVwaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDkwNjcsImV4cCI6MjA2OTEyNTA2N30.CqnJ-yVjf5M_y6DzpZ5sRsBT_9HlFPPm8sn5vMThYPo', // Replace with your Supabase Anon Key
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PatientProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // We no longer need to listen to onAuthStateChange here for navigation.
  // The onGenerateRoute will handle the initial screen based on session.
  // When a user logs in/out from AuthScreen/SignUpScreen, those screens
  // will push/replace the route as needed.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dental App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey[400]),
          labelStyle: GoogleFonts.montserrat(color: Colors.teal[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal,
            textStyle: GoogleFonts.montserrat(),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // This is the core logic for initial route based on auth state
        final session = Supabase.instance.client.auth.currentSession;
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) =>
                session != null ? const HomeScreen() : const AuthScreen(),
            settings: settings,
          );
        } else if (settings.name == '/home') {
          // Ensure that if someone tries to navigate directly to /home,
          // they are logged in. Otherwise, redirect to AuthScreen.
          return MaterialPageRoute(
            builder: (context) =>
                session != null ? const HomeScreen() : const AuthScreen(),
            settings: settings,
          );
        } else if (settings.name == '/add-patient') {
          return MaterialPageRoute(
            builder: (context) => const AddPatientScreen(),
            settings: settings,
          );
        } else if (settings.name == '/edit-patient') {
          final patient = settings.arguments as Patient;
          return MaterialPageRoute(
            builder: (context) => EditPatientScreen(patient: patient),
            settings: settings,
          );
        }
        // Add your SignUpScreen route here
        else if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => const AuthScreen(),
            settings: settings,
          );
        }
        // You can add more named routes here as needed
        return MaterialPageRoute(
          builder: (context) => const Text('Error: Unknown route'),
        );
      },
    );
  }
}
