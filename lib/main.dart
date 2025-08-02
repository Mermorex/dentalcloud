// lib/main.dart
import 'dart:async';
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
import 'package:dental/screens/set_password_screen.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  await Supabase.initialize(
    url: 'https://jymqyezkyzzvuvqephdh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bXF5ZXpreXp6dnV2cWVwaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDkwNjcsImV4cCI6MjA2OTEyNTA2N30.CqnJ-yVjf5M_y6DzpZ5sRsBT_9HlFPPm8sn5vMThYPo',
  );

  final uri = Uri.base;
  final isRecovery = uri.queryParameters['type'] == 'recovery';

  if (isRecovery) {
    try {
      print('🔐 Recovery link detected: $uri');
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      print('✅ Recovery session created');
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PatientProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
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
      home: const AuthStateWrapper(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        } else if (settings.name == '/add-patient') {
          return MaterialPageRoute(builder: (_) => const AddPatientScreen());
        } else if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const AuthScreen());
        } else if (settings.name == '/set-password') {
          return MaterialPageRoute(builder: (_) => const SetPasswordScreen());
        } else if (settings.name == '/edit-patient') {
          final patient = settings.arguments as Patient;
          return MaterialPageRoute(
            builder: (_) => EditPatientScreen(patient: patient),
          );
        }
        return null;
      },
    );
  }
}

class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        data,
      ) async {
        final event = data.event;

        if (!mounted) return;

        if (event == AuthChangeEvent.signedIn) {
          final uri = Uri.base;
          final isRecovery = uri.queryParameters['type'] == 'recovery';

          if (!isRecovery) {
            await Future.delayed(
              const Duration(milliseconds: 50),
            ); // Small buffer

            final session = Supabase.instance.client.auth.currentSession;
            if (session != null && mounted) {
              if (kIsWeb) {
                html.window.history.pushState(null, 'Home', '/home');
              }
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          if (kIsWeb) {
            html.window.history.pushState(null, 'Login', '/login');
          }
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final hasCode = uri.queryParameters.containsKey(
      'code',
    ); // Supabase recovery token
    final session = Supabase.instance.client.auth.currentSession;

    if (hasCode) {
      return const SetPasswordScreen();
    }

    if (session != null) {
      return const HomeScreen();
    } else {
      return const AuthScreen();
    }
  }
}
