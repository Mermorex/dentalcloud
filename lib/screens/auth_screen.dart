// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'signup_screen.dart'; // Import the new signup screen

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _serverIp; // To store the server IP

  static const String SERVER_PORT = '8000';

  @override
  void initState() {
    super.initState();
    _loadServerIp();
  }

  void _loadServerIp() {
    if (html.window.location.protocol.startsWith('http')) {
      try {
        final uri = Uri.parse(html.window.location.href);
        final ip = uri.queryParameters['serverIp'];
        setState(() {
          _serverIp = ip;
          print('[AuthScreen] Server IP from URL: $_serverIp');
        });
      } catch (e) {
        print('[AuthScreen] Error parsing URL or extracting serverIp: $e');
        setState(() {
          _serverIp = null;
        });
      }
    } else {
      print(
        '[AuthScreen] Not running in a web environment or protocol is not http/https.',
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthResponse res = await Supabase.instance.client.auth
          .signInWithPassword(
            email: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (res.user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[AuthScreen] Building widget. Current _serverIp: $_serverIp');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal.shade50, Colors.blue.shade50],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/tooth_logo.png',
                        height: 120,
                        width: 120,
                        errorBuilder: (context, error, stackTrace) {
                          print('[AuthScreen] Error loading image: $error');
                          return const Icon(Icons.broken_image, size: 120);
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Bienvenue',
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      Text(
                        'Connectez-vous à votre compte',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: 350.0,
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Entrez votre email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.teal.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 20.0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email.';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Veuillez entrer une adresse email valide.';
                            }
                            return null;
                          },
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 350.0,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: 'Entrez votre mot de passe',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.teal.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 20.0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe.';
                            }
                            return null;
                          },
                          style: GoogleFonts.montserrat(),
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.teal,
                              ),
                            )
                          : SizedBox(
                              width: 350.0,
                              child: ElevatedButton(
                                onPressed: _submit, // Existing login method
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Se connecter',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20), // Added spacing
                      TextButton(
                        onPressed: () {
                          // Navigate to the signup screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Pas encore de compte ? S\'inscrire',
                          style: GoogleFonts.montserrat(
                            color: Colors.teal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_serverIp != null && _serverIp!.isNotEmpty)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Scannez pour mobile:',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    QrImageView(
                      data: 'http://$_serverIp:$SERVER_PORT',
                      version: QrVersions.auto,
                      size: 100.0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade800,
                      errorStateBuilder: (cxt, err) {
                        print('[AuthScreen] QrImageView Error: $err');
                        return Center(
                          child: Text(
                            "Erreur QR",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.red,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'http://$_serverIp:$SERVER_PORT',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
