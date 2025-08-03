// lib/main.dart
import 'dart:async';
import 'dart:html' as html; // Import for web URL manipulation
import 'package:flutter/foundation.dart'; // Import for kIsWeb
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Supabase.initialize(
    url: 'https://jymqyezkyzzvuvqephdh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bXF5ZXpreXp6dnV2cWVwaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDkwNjcsImV4cCI6MjA2OTEyNTA2N30.CqnJ-yVjf5M_y6DzpZ5sRsBT_9HlFPPm8sn5vMThYPo',
  );

  final uri = Uri.base;

  // --- CRITICAL: Check for /set-password path FIRST ---
  // This check must happen before ANY other app initialization that might
  // trigger navigation (like AuthStateWrapper).
  if (uri.pathSegments.contains('set-password')) {
    print('🔐 Direct /set-password path detected: $uri');

    // Optional: Attempt to process the session from the URL.
    try {
      final AuthSessionUrlResponse response = await Supabase
          .instance
          .client
          .auth
          .getSessionFromUrl(uri);
      print(
        '✅ getSessionFromUrl result: Session ID: ${response.session?.user.id ?? 'null'}',
      );
    } catch (e) {
      print('⚠️ Non-fatal error in getSessionFromUrl for set-password: $e');
      // We proceed regardless because SetPasswordScreen should handle the 'code' param.
    }

    // --- Update Browser URL for Web ---
    // Ensures the address bar reflects /set-password
    if (kIsWeb) {
      html.window.history.pushState(null, 'Set Password', '/set-password');
      print('🌐 Browser URL updated to /set-password');
    }

    // --- LAUNCH APP DIRECTLY TO SetPasswordScreen ---
    // This completely bypasses MyApp and AuthStateWrapper for this specific case.
    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => PatientProvider())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dental App - Set Password',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.montserratTextTheme(ThemeData().textTheme),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
                textStyle: GoogleFonts.montserrat(),
              ),
            ),
          ),
          home: const SetPasswordScreen(), // <-- KEY: Direct Home Screen
          // No onGenerateRoute needed for direct navigation like this.
        ),
      ),
    );
    return; // <-- KEY: Exit main() immediately, do not run the rest.
  }
  // --- END OF DIRECT /set-password HANDLING ---

  // Handle other standard auth redirects (e.g., type=recovery)
  // but NOT /set-password anymore.
  final isStandardAuthRedirect = uri.queryParameters['type'] == 'recovery';

  if (isStandardAuthRedirect) {
    try {
      print('🔐 Standard auth redirect detected (type=recovery): $uri');
      final AuthSessionUrlResponse response = await Supabase
          .instance
          .client
          .auth
          .getSessionFromUrl(uri);
      print(
        '✅ Session processed from standard redirect URL. Session exists: ${response.session != null}',
      );
    } on AuthException catch (e) {
      print('❌ Auth error processing standard redirect: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error processing standard redirect: $e');
    }
  }

  // --- DEFAULT APP INITIALIZATION ---
  // This is the standard flow for users who are not coming from a /set-password link.
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
      home: const AuthStateWrapper(), // This now handles initialization
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        } else if (settings.name == '/add-patient') {
          return MaterialPageRoute(builder: (_) => const AddPatientScreen());
        } else if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const AuthScreen());
        } else if (settings.name == '/set-password') {
          // This route definition is kept for potential internal navigation
          // or if the direct path check in main somehow fails.
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

// AuthStateWrapper remains unchanged from your provided code.
// It will only be active when MyApp is run (i.e., not for /set-password direct links).
class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({super.key});

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  late final StreamSubscription<AuthState> _authSub;
  bool _checkingAuth = true;
  bool _authStateResolved = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        print("AuthStateWrapper Listener: Received event '$event'.");

        if (_authStateResolved) {
          print(
            "AuthStateWrapper Listener: Auth state already resolved, ignoring event '$event'.",
          );
          return;
        }

        if (!mounted) return;
        setState(() {
          _checkingAuth = false;
        });

        if (event == AuthChangeEvent.initialSession) {
          _authStateResolved = true;
          if (session != null) {
            print(
              "AuthStateWrapper Listener: Initial session loaded and is valid. Navigating to /home.",
            );
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            print(
              "AuthStateWrapper Listener: Initial session loaded and is null/invalid. Navigating to /login.",
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else if (event == AuthChangeEvent.signedIn) {
          _authStateResolved = true;
          if (session != null) {
            print(
              "AuthStateWrapper Listener: Signed in event received, navigating to /home.",
            );
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            print(
              "AuthStateWrapper Listener: Signed in event but session is null. Navigating to /login.",
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _authStateResolved = true;
          print(
            "AuthStateWrapper Listener: Signed out event received, navigating to /login.",
          );
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          if (!_authStateResolved && session != null) {
            _authStateResolved = true;
            print(
              "AuthStateWrapper Listener: Token refreshed, session valid. Navigating to /home.",
            );
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (!_authStateResolved && session == null) {
            _authStateResolved = true;
            print(
              "AuthStateWrapper Listener: Token refresh failed, session invalid. Navigating to /login.",
            );
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      },
      onError: (error, stackTrace) {
        print("AuthStateWrapper Listener: Error in auth state stream: $error");
        if (!_authStateResolved && mounted) {
          setState(() {
            _checkingAuth = false;
          });
          _authStateResolved = true;
          print(
            "AuthStateWrapper Listener: Stream error, navigating to /login.",
          );
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Chargement..."),
            ],
          ),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Text(
          "Gestion de l'authentification...\n(Si vous voyez ceci, veuillez actualiser la page.)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
