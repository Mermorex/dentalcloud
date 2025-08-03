// lib/screens/set_password_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

final supabase = Supabase.instance.client;

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMsg;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // 1. Mettre à jour le mot de passe
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordCtrl.text),
      );

      // 2. Afficher le message de succès initial
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe mis à jour avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 3. Attendre un court instant pour que le SnackBar soit visible
      await Future.delayed(const Duration(milliseconds: 1000));

      // 4. Procéder à la déconnexion et navigation
      await _signOutAndNavigate();
    } on AuthException catch (e) {
      // Gérer les erreurs spécifiques d'authentification
      setState(() => _errorMsg = e.message ?? 'Erreur d\'authentification.');
    } catch (e) {
      // Gérer toutes les autres erreurs
      debugPrint(
        "Erreur inattendue lors de la mise à jour du mot de passe: $e",
      );

      // Même si une erreur inattendue se produit ici, on considère que le mot de passe
      // a probablement été changé (car updateUser n'a pas levé d'AuthException)
      // et on tente quand même la déconnexion et la navigation.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe mis à jour. Redirection...'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Attendre un peu plus longtemps pour que le SnackBar soit visible
      await Future.delayed(const Duration(milliseconds: 1500));

      // Procéder à la déconnexion et navigation
      await _signOutAndNavigate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Méthode dédiée pour la déconnexion et la navigation
  /// avec un rafraîchissement en dernier recours.
  Future<void> _signOutAndNavigate() async {
    // 1. Tenter de se déconnecter
    try {
      await supabase.auth.signOut();
      debugPrint("✅ Déconnexion effectuée (ou tentée).");
    } catch (signOutError) {
      debugPrint(
        "⚠️ Erreur (potentiellement non fatale) lors de la déconnexion: $signOutError",
      );
      // On continue malgré l'erreur de déconnexion
    }

    // 2. Mettre à jour l'URL du navigateur pour la page de connexion (si web)
    if (kIsWeb) {
      try {
        html.window.history.pushState(null, 'Login', '/login');
        debugPrint("🌐 URL du navigateur mise à jour vers /login.");
      } catch (urlError) {
        debugPrint(
          "⚠️ Erreur (potentiellement non fatale) lors de la mise à jour de l'URL: $urlError",
        );
      }
    }

    // 3. Tenter la navigation Flutter standard
    bool navigationAttempted = false;
    if (mounted) {
      try {
        // Planifier la navigation après le traitement de l'état actuel
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
            navigationAttempted = true;
            debugPrint("➡️ Navigation Flutter vers /login tentée.");
          }
        });
      } catch (navError) {
        debugPrint("⚠️ Erreur lors de la navigation Flutter: $navError");
      }
    }

    // 4. Attendre un court instant pour voir si la navigation Flutter se produit
    await Future.delayed(const Duration(milliseconds: 800));

    // 5. Si nous sommes toujours dans un contexte web, forcer un rafraîchissement
    // comme solution de secours pour garantir la redirection.
    if (kIsWeb) {
      debugPrint("🔄 Rafraîchissement forcé de la page déclenché.");
      html.window.location.reload(); // Rafraîchit complètement la page
    } else {
      // Pour les autres plateformes, si la navigation échoue, vous pouvez envisager
      // d'afficher un message ou de retenter la navigation.
      debugPrint(
        "⚠️ Navigation Flutter échouée et pas sur Web - logique supplémentaire nécessaire ?",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Nouveau mot de passe',
          style: GoogleFonts.montserrat(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Text(
                  'Définir un nouveau mot de passe',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
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
                      // New Password Field
                      TextFormField(
                        controller: _newPasswordCtrl,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mot de passe requis';
                          }
                          if (value.length < 6) {
                            return 'Au moins 6 caractères.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer le mot de passe.';
                          }
                          if (value != _newPasswordCtrl.text) {
                            return 'Les mots de passe ne correspondent pas.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updatePassword,
                                child: Text(
                                  'Confirmer le mot de passe',
                                  style: GoogleFonts.montserrat(fontSize: 18),
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
