// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _signupCodeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _signupCodeCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _errorMsg = message);
  }

  void _clear() {
    _emailCtrl.clear();
    _passCtrl.clear();
    _signupCodeCtrl.clear();
    setState(() => _errorMsg = null);
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    _errorMsg = null;

    try {
      final signupCode = _signupCodeCtrl.text.trim();

      // Check if the code is valid and unused.
      final codes = await Supabase.instance.client
          .from('signup_codes')
          .select()
          .eq('code', signupCode)
          .single();

      if (codes == null || codes['is_used'] == true) {
        _showError('Code d\'inscription invalide ou déjà utilisé.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Perform Supabase sign-up and pass the signup code as metadata
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        emailRedirectTo: 'https://dentalapp.smarthub.tn/set-password',
        data: {'signup_code': signupCode},
      );

      final user = response.user;
      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vérifiez votre email pour confirmer le compte.'),
              backgroundColor: Colors.orange,
            ),
          );
          _clear();
          Navigator.of(context).pop();
        }
      } else {
        _showError(
          'La création du compte a échoué. Veuillez vérifier vos règles Supabase.',
        );
      }
    } on AuthException catch (e) {
      _showError('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      _showError('Erreur inattendue: ${e.toString()}');
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
                  'Inscription',
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
                      TextFormField(
                        controller: _signupCodeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Code d\'inscription',
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Code d\'inscription requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _signUp();
                                  }
                                },
                                child: Text(
                                  'S\'inscrire',
                                  style: GoogleFonts.montserrat(fontSize: 18),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Déjà un compte ? Se connecter',
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
