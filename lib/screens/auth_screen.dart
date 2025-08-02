// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

final supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _errorMsg = message);
  }

  void _clear() {
    _emailCtrl.clear();
    _passCtrl.clear();
    setState(() => _errorMsg = null);
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    _errorMsg = null;

    try {
      await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        emailRedirectTo:
            'https://dentalapp.smarthub.tn/set-password', // ✅ No trailing space
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vérifiez votre email pour confirmer le compte.'),
          backgroundColor: Colors.orange,
        ),
      );
      _clear();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Erreur inattendue');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    _errorMsg = null;

    try {
      // Perform sign-in
      final response = await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      // ✅ Explicitly check session after login
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;

      if (session != null && user != null && mounted) {
        // ✅ Force redirect to home
        if (kIsWeb) {
          html.window.history.pushState(null, 'Home', '/home');
        }
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // This should not happen — but just in case
        _showError('Échec de la connexion. Veuillez réessayer.');
      }
    } on AuthException catch (e) {
      _showError(
        e.message.contains('Email not confirmed')
            ? 'Veuillez confirmer votre email avant de vous connecter.'
            : e.message,
      );
    } catch (e) {
      _showError('Erreur inattendue');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Veuillez entrer votre email');
      return;
    }

    setState(() => _isLoading = true);
    _errorMsg = null;

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo:
            'https://dentalapp.smarthub.tn/set-password', // ✅ No trailing space
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un lien de réinitialisation a été envoyé par email.'),
          backgroundColor: Colors.green,
        ),
      );
      _clear();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Erreur lors de l\'envoi de l\'email.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Text(
                  _isLogin ? 'Connexion' : 'Inscription',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMsg != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMsg!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Email requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Mot de passe requis' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _sendPasswordResetEmail,
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _isLogin ? _login() : _signUp();
                                }
                              },
                              child: Text(
                                _isLogin ? 'Se connecter' : 'S\'inscrire',
                                style: GoogleFonts.montserrat(fontSize: 18),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMsg = null;
                            _clear();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Pas encore de compte ? S\'inscrire'
                              : 'Déjà un compte ? Se connecter',
                          style: GoogleFonts.montserrat(
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
