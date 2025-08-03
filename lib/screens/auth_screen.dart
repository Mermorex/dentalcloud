// lib/screens/auth_screen.dart
import 'package:dental/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _signupCodeCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKeyStep1 = GlobalKey<FormState>(); // Key for code/email validation
  final _formKeyStep2 = GlobalKey<FormState>(); // Key for full signup form

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _codeValidated = false; // New state to track code validation
  String? _errorMsg;
  String? _validatedSignupCode; // Store the validated code
  bool _isCreatingCabinet = false; // Store the action type

  // --- NEW: State for "Rester connecté" ---
  bool _staySignedIn = true; // Default to true
  // --- END OF NEW ---

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _signupCodeCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _errorMsg = message);
  }

  void _clear() {
    _emailCtrl.clear();
    _passCtrl.clear();
    _signupCodeCtrl.clear();
    _fullNameCtrl.clear();
    _phoneCtrl.clear();
    setState(() {
      _errorMsg = null;
      _codeValidated = false;
      _validatedSignupCode = null;
      _isCreatingCabinet = false;
    });
  }

  // --- NEW: Function to validate the signup code ---
  Future<void> _validateSignupCode() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMsg = null;
    final signupCode = _signupCodeCtrl.text.trim().toUpperCase();
    try {
      print('DEBUG: Validating signup code: $signupCode');
      final responseSelectQuery = await Supabase.instance.client
          .from('signup_codes')
          .select()
          .eq('code', signupCode);
      if (responseSelectQuery.isEmpty) {
        _showError(
          'Code cabinet introuvable. Veuillez vérifier le code fourni.',
        );
        return;
      }
      final signupCodeData = responseSelectQuery[0];
      final bool isCodeAlreadyUsed = signupCodeData['is_used'] == true;
      final bool isCodeActive = signupCodeData['is_active'] == true;
      // Determine if this user is creating the cabinet or joining
      if (!isCodeAlreadyUsed) {
        print('DEBUG: Code $signupCode is valid for CREATING a cabinet.');
        setState(() {
          _codeValidated = true;
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = true;
        });
      } else if (isCodeAlreadyUsed && isCodeActive) {
        print(
          'DEBUG: Code $signupCode is valid for JOINING an existing cabinet.',
        );
        setState(() {
          _codeValidated = true;
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = false;
        });
      } else {
        _showError('Le cabinet associé à ce code est désactivé.');
      }
    } catch (e) {
      print('DEBUG: Error validating signup code: $e');
      _showError('Erreur lors de la vérification du code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- END OF NEW FUNCTION ---

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      final signupCode = _validatedSignupCode!; // Use the validated code
      final userRole = _isCreatingCabinet ? 'doctor' : 'secretary';
      // Create the user account with email and password
      print('DEBUG: Creating user account for ${_emailCtrl.text.trim()}...');
      final responseSignUp = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      final user = responseSignUp.user;
      if (user != null) {
        print('DEBUG: User created successfully with ID: ${user.id}');
        // Authenticate the user to set the session
        await Supabase.instance.client.auth.refreshSession();
        // Insert the user's profile information
        final profileData = {
          'id': user.id,
          'full_name': _fullNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': user.email,
        };
        print('DEBUG: Preparing to insert profile: $profileData');
        try {
          await Supabase.instance.client.from('profiles').insert(profileData);
          print('DEBUG: Profile inserted successfully.');
        } on PostgrestException catch (e) {
          print('DEBUG: PostgrestException during profile insert: $e');
          if (e.code == '23505' && e.message.contains('profiles_pkey')) {
            print('DEBUG: Profile already exists, attempting upsert.');
            await Supabase.instance.client.from('profiles').upsert(profileData);
            print('DEBUG: Profile upserted successfully.');
          } else {
            print('DEBUG: Re-throwing different Postgrest error: $e');
            rethrow;
          }
        } catch (profileError) {
          print(
            'DEBUG: Unexpected error during profile creation/upsert: $profileError',
          );
          _showError(
            'Erreur lors de la création du profil: ${profileError.toString()}',
          );
          return; // Stop the process
        }
        // --- Conditional Logic for Cabinet Creation/Joining ---
        if (_isCreatingCabinet) {
          print('DEBUG: Finalizing cabinet creation...');
          try {
            await Supabase.instance.client
                .from('signup_codes')
                .update({
                  'is_used': true,
                  'used_at': DateTime.now().toIso8601String(),
                  'created_by': user.id,
                  'is_active': true,
                })
                .eq('code', signupCode);
            print(
              'DEBUG: Signup code $signupCode marked as used, activated, and creator set.',
            );
          } catch (updateCodeError) {
            print(
              'DEBUG: Error updating signup_codes during creation: $updateCodeError',
            );
            _showError('Erreur lors de l\'activation du cabinet.');
            return; // Stop the process
          }
        }
        // Add user to cabinet_members
        print(
          'DEBUG: Adding user (role: $userRole) to cabinet_members for cabinet: $signupCode',
        );
        try {
          await Supabase.instance.client.from('cabinet_members').insert({
            'cabinet_code': signupCode,
            'user_id': user.id,
            'role': userRole,
            'is_active': true,
          });
          print('DEBUG: Successfully added user to cabinet_members.');
        } catch (memberError) {
          print('DEBUG: Error adding user to cabinet_members: $memberError');
          _showError(
            'Inscription réussie, mais une erreur critique s\'est produite lors de la configuration du cabinet. Veuillez contacter le support.',
          );
          return; // Stop the process
        }
        // --- END OF LOGIC ---
        // Sign the user out
        print('DEBUG: Signing user out.');
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Inscription réussie ! Veuillez vérifier votre email pour confirmer votre compte, puis connectez-vous.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _clear(); // Reset form completely
          setState(() => _isLogin = true); // Switch back to login
        }
      } else {
        print('DEBUG: User object was null after signup.');
        _showError('La création du compte a échoué. Veuillez réessayer.');
      }
    } on AuthException catch (e) {
      print('DEBUG: AuthException during signup: $e');
      if (e.message.contains('already registered') ||
          e.message.contains('email')) {
        _showError('Cet email est déjà utilisé.');
      } else {
        _showError('Erreur d\'authentification: ${e.message}');
      }
    } catch (e) {
      print('DEBUG: Unexpected error during signup process: $e');
      _showError('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      // --- MODIFIED: Capture 'staySignedIn' preference ---
      // Note: The Supabase Flutter SDK's signInWithPassword doesn't directly
      // take a 'persistSession' flag like some other SDKs.
      // Session persistence is usually configured globally during Supabase.initialize
      // or relies on the underlying storage (localStorage vs sessionStorage).
      //
      // For now, we capture the preference. Implementing the "OFF" behavior
      // (sign out on tab close or app start) requires additional logic.
      // Standard Supabase behavior (using localStorage) acts like "Rester connecté ON".
      final bool userWantsToStaySignedIn = _staySignedIn;
      print(
        'DEBUG: User "Rester connecté" preference: $userWantsToStaySignedIn',
      );
      // --- END OF MODIFICATION ---

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        // Example of how it *might* be passed if supported (check latest SDK docs):
        // options: AuthOptions(persistSession: userWantsToStaySignedIn)
      );
      final session = response.session;
      final user = response.user;
      if (session != null && user != null) {
        if (user.emailConfirmedAt == null) {
          await Supabase.instance.client.auth.signOut();
          _showError('Veuillez confirmer votre email avant de vous connecter.');
          return;
        }
        // --- NEW: Fetch user's cabinet membership ---
        if (mounted) {
          try {
            // Query cabinet_members to find the cabinets this user belongs to
            final memberResponse = await Supabase.instance.client
                .from('cabinet_members')
                .select(
                  'cabinet_code, role',
                ) // Select code and potentially role
                .eq('user_id', user.id)
                .eq('is_active', true)
                .limit(2); // Limit to check if there's more than one
            if (memberResponse.isEmpty) {
              // Handle case where user has no cabinet membership
              _showError(
                'Votre compte n\'est associé à aucun cabinet. Veuillez contacter l\'administrateur.',
              );
              await Supabase.instance.client.auth.signOut();
              if (mounted) setState(() => _isLoading = false);
              return;
            } else if (memberResponse.length > 1) {
              // Handle case with multiple cabinets
              // For simplicity now, we can pick the first one or show an error.
              // A better approach later is to show a cabinet selection screen.
              print(
                'User belongs to multiple cabinets. Picking the first one or showing selector.',
              );
              // Example: Pick first, or navigate to selector
              // For now, proceeding but you might want to handle this explicitly.
              // You could pass a list of cabinets to the home screen via arguments.
            }
            // Get the cabinet code (assuming one or picking the first for now)
            final cabinetCode = memberResponse[0]['cabinet_code'] as String;
            // Optionally get the role: final userRole = memberResponse[0]['role'] as String?;
            // --- Get the PatientProvider and set the cabinet code ---
            // We need to access the provider. Since we are in AuthScreen,
            // and PatientProvider is likely above it in the widget tree,
            // we can use Provider.of with listen: false.
            final patientProvider = Provider.of<PatientProvider>(
              context,
              listen: false,
            );
            // Set the cabinet code in the provider.
            // Assuming you added the 'setCurrentCabinetCode' method to PatientProvider as discussed.
            patientProvider.setCurrentCabinetCode(
              cabinetCode,
            ); // This should also load cabinet name if implemented
            print('DEBUG: Set cabinet code for logged in user: $cabinetCode');

            // --- Handle "Rester connecté OFF" (Optional/Advanced) ---
            // If you need to implement the behavior where the user is signed out
            // when the tab closes because they unchecked "Rester connecté",
            // you would do something like:
            /*
            if (!userWantsToStaySignedIn) {
              // Store this preference locally
              html.window.localStorage['staySignedIn'] = 'false';
              // Add a listener for page/tab unload (requires dart:html)
              // html.window.onBeforeUnload.listen((event) async {
              //   print("Tab is closing and 'Rester connecté' is OFF. Signing out.");
              //   try {
              //     await Supabase.instance.client.auth.signOut();
              //     // Clear provider state if needed immediately
              //   } catch (e) {
              //     print("Error signing out on unload: $e");
              //   }
              // });
              // Note: beforeunload listeners and async operations can be unreliable.
            } else {
               // Ensure the flag is cleared or set to true if needed
               html.window.localStorage.remove('staySignedIn'); // Or set to 'true'
            }
            */
            // --- END OF ADVANCED HANDLING ---

            // --- Now navigate to home ---
            if (kIsWeb) {
              html.window.history.pushState(null, 'Home', '/home');
            }
            Navigator.of(context).pushReplacementNamed('/home');
          } catch (fetchError) {
            print(
              'Error fetching cabinet membership or setting provider: $fetchError',
            );
            _showError(
              'Erreur lors du chargement des informations du cabinet.',
            );
            await Supabase.instance.client.auth.signOut(); // Sign out on error
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        }
        // --- END OF NEW CODE ---
      } else {
        _showError('Échec de la connexion. Veuillez réessayer.');
      }
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        _showError('Veuillez confirmer votre email avant de vous connecter.');
      } else if (e.message.contains('Invalid login credentials')) {
        _showError('Email ou mot de passe incorrect.');
      } else {
        _showError(e.message);
      }
    } catch (e) {
      print('Unexpected error during login: $e');
      _showError('Erreur inattendue lors de la connexion.');
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
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb
            ? '${html.window.location.origin}/set-password'
            : 'https://dentalapp.smarthub.tn/set-password',
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
                  _isLogin
                      ? 'Connexion'
                      : (_codeValidated
                            ? 'Compléter l\'inscription'
                            : 'Vérifier le Code Cabinet'),
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
                // --- MODIFIED: Conditional Form Rendering ---
                if (!_isLogin && !_codeValidated) // Step 1: Validate Code
                  Form(
                    key: _formKeyStep1, // Use specific key for this step
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
                          controller: _signupCodeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Code Cabinet',
                            prefixIcon: Icon(Icons.vpn_key),
                            hintText: 'Fourni par le docteur',
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Code cabinet requis' : null,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _validateSignupCode,
                                  child: Text(
                                    'Vérifier le Code',
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )
                else if (!_isLogin && _codeValidated) // Step 2: Complete Signup
                  Form(
                    key: _formKeyStep2, // Use specific key for this step
                    child: Column(
                      children: [
                        // Display validated info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email: ${_emailCtrl.text.trim()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Action: ${_isCreatingCabinet ? 'Créer un nouveau cabinet' : 'Rejoindre un cabinet existant'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code Cabinet: $_validatedSignupCode',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
                          controller: _fullNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Nom complet requis' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (v) => v?.isEmpty == true
                              ? 'Numéro de téléphone requis'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Row(
                                children: [
                                  // Back button to re-enter code
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _codeValidated = false;
                                        _errorMsg = null;
                                      });
                                    },
                                    child: Text(
                                      'Retour',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: 200, // Constrain button width
                                    child: ElevatedButton(
                                      onPressed: _signUp,
                                      child: Text(
                                        'S\'inscrire',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  )
                else // Login Form
                  Form(
                    key: _formKeyStep1, // Reuse key for login as it's simple
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
                        // --- NEW: "Rester connecté" Checkbox ---
                        Row(
                          children: [
                            Checkbox(
                              value: _staySignedIn,
                              onChanged: (value) {
                                setState(() {
                                  _staySignedIn = value ?? true;
                                });
                              },
                            ),
                            const Text('Rester connecté'),
                          ],
                        ),
                        // --- END OF NEW ---
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
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  child: Text(
                                    'Se connecter',
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                // --- END OF MODIFICATION ---
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMsg = null;
                      _clear(); // Reset all fields and validation state
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Pas encore de compte ? S\'inscrire'
                        : 'Déjà un compte ? Se connecter',
                    style: GoogleFonts.montserrat(color: Colors.teal.shade800),
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
