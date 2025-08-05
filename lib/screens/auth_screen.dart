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
  // --- NEW: Controllers for Cabinet Details ---
  final _cabinetNameCtrl = TextEditingController();
  final _cabinetAddressCtrl = TextEditingController();
  final _cabinetPhoneCtrl = TextEditingController();
  final _cabinetEmailCtrl = TextEditingController();
  final _cabinetWebsiteCtrl = TextEditingController();
  // --- END OF NEW ---
  final _formKeyStep1 = GlobalKey<FormState>(); // Key for code/email validation
  final _formKeyStep2 =
      GlobalKey<FormState>(); // Key for full signup form (user details)
  final _formKeyStep3 = GlobalKey<FormState>(); // Key for cabinet details form
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _codeValidated = false; // Obsolete, replaced by _signupStep
  String? _errorMsg;
  String? _validatedSignupCode; // Store the validated code
  // --- MODIFIED: State for Signup Flow Steps ---
  int _signupStep =
      1; // 1: Code/Email, 2: User Details, 3: Cabinet Details (if creating)
  // --- END OF MODIFICATION ---
  // --- MODIFIED: State for Cabinet Action ---
  bool _isCreatingCabinet =
      false; // Store the action type determined during code validation
  // --- END OF MODIFICATION ---
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
    // --- NEW: Dispose Cabinet Controllers ---
    _cabinetNameCtrl.dispose();
    _cabinetAddressCtrl.dispose();
    _cabinetPhoneCtrl.dispose();
    _cabinetEmailCtrl.dispose();
    _cabinetWebsiteCtrl.dispose();
    // --- END OF NEW ---
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
    // --- NEW: Clear Cabinet Fields ---
    _cabinetNameCtrl.clear();
    _cabinetAddressCtrl.clear();
    _cabinetPhoneCtrl.clear();
    _cabinetEmailCtrl.clear();
    _cabinetWebsiteCtrl.clear();
    // --- END OF NEW ---
    setState(() {
      _errorMsg = null;
      _codeValidated = false;
      _validatedSignupCode = null;
      _isCreatingCabinet = false;
      // --- MODIFIED: Reset Signup Step ---
      _signupStep = 1;
      // --- END OF MODIFICATION ---
    });
  }

  // --- NEW: Function for Password Reset ---
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
            : 'https://dentalapp.smarthub.tn/set-password', // Adjust URL if needed
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
  // --- END OF NEW FUNCTION ---

  // --- MODIFIED: Function to validate the signup code ---
  // Determines if the user is creating or joining
  Future<void> _validateSignupCode() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMsg = null;
    final signupCode = _signupCodeCtrl.text.trim().toUpperCase();
    try {
      print('DEBUG: Validating signup code: $signupCode');
      final responseSelectQuery = await Supabase.instance.client
          .from('signup_codes')
          .select('cabinet_id, is_used, is_active')
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
      // --- MODIFIED: Determine action based on cabinet_id and usage ---
      final dynamic linkedCabinetId = signupCodeData['cabinet_id'];
      if (!isCodeAlreadyUsed && linkedCabinetId == null) {
        print('DEBUG: Code $signupCode is valid for CREATING a cabinet.');
        setState(() {
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = true;
          _signupStep = 2; // Go to user details first
        });
      } else if (isCodeAlreadyUsed && isCodeActive && linkedCabinetId != null) {
        print(
          'DEBUG: Code $signupCode is valid for JOINING an existing cabinet (ID: $linkedCabinetId).',
        );
        setState(() {
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = false;
          _signupStep = 2; // Go to user details first
        });
      } else {
        _showError(
          'Le cabinet associé à ce code est désactivé ou mal configuré.',
        );
      }
    } catch (e) {
      print('DEBUG: Error validating signup code: $e');
      _showError('Erreur lors de la vérification du code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- MODIFIED: SignUp Function ---
  Future<void> _signUp() async {
    if (_signupStep == 2) {
      if (!_formKeyStep2.currentState!.validate()) return;
      setState(() => _isLoading = true);
      _errorMsg = null;
      try {
        final signupCode = _validatedSignupCode!;
        final userRole = _isCreatingCabinet ? 'doctor' : 'secretary';
        print('DEBUG: Creating user account for ${_emailCtrl.text.trim()}...');
        final responseSignUp = await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        final user = responseSignUp.user;
        if (user != null) {
          print('DEBUG: User created successfully with ID: ${user.id}');
          await Supabase.instance.client.auth.refreshSession();
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
              await Supabase.instance.client
                  .from('profiles')
                  .upsert(profileData);
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
            return;
          }
          if (_isCreatingCabinet) {
            setState(() {
              _signupStep = 3;
              _isLoading = false;
            });
            return;
          } else {
            print(
              'DEBUG: Finalizing joining existing cabinet using code: $signupCode',
            );
            try {
              final codeResponse = await Supabase.instance.client
                  .from('signup_codes')
                  .select('cabinet_id')
                  .eq('code', signupCode)
                  .single();
              final String? cabinetId = codeResponse['cabinet_id'] as String?;
              if (cabinetId == null) {
                throw Exception(
                  'Signup code $signupCode is marked as used but has no associated cabinet ID.',
                );
              }
              print(
                'DEBUG: Adding user (role: $userRole) to cabinet_members for cabinet ID: $cabinetId',
              );
              await Supabase.instance.client.from('cabinet_members').insert({
                'cabinet_id': cabinetId,
                'user_id': user.id,
                'role': userRole,
                'is_active': true,
              });
              print('DEBUG: Successfully added user to cabinet_members.');
            } catch (memberError) {
              print(
                'DEBUG: Error adding user to cabinet_members: $memberError',
              );
              _showError(
                'Inscription réussie, mais une erreur critique s\'est produite lors de la configuration du cabinet. Veuillez contacter le support.',
              );
              return;
            }
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
              _clear();
              setState(() => _isLogin = true);
            }
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
        if (mounted && _signupStep != 3) setState(() => _isLoading = false);
      }
    }
  }

  // --- MODIFIED: Function to Create Cabinet and Finalize Signup (using RPC) ---
  Future<void> _createCabinetAndFinalizeSignup() async {
    if (!_formKeyStep3.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }
      // Call the new RPC function to handle the entire signup flow
      await supabase.rpc(
        'create_cabinet_and_member',
        params: {
          'signup_code': _validatedSignupCode!,
          'full_name': _fullNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'user_id': user.id,
          'email': user.email,
          'cabinet_name': _cabinetNameCtrl.text.trim(),
          'cabinet_address': _cabinetAddressCtrl.text.trim(),
          'cabinet_phone': _cabinetPhoneCtrl.text.trim(),
          'cabinet_email': _cabinetEmailCtrl.text.trim(),
          'cabinet_website': _cabinetWebsiteCtrl.text.trim(),
        },
      );
      // After a successful RPC call, the user is already added and the code is used.
      // Now, sign the user out to force email confirmation and a fresh login.
      print('DEBUG: Signing user out after successful RPC call.');
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
        _clear();
        setState(() => _isLogin = true);
      }
    } on PostgrestException catch (e) {
      print('DEBUG: PostgrestException during RPC call: $e');
      _showError(e.message);
    } catch (e) {
      print('DEBUG: Unexpected error during RPC call: $e');
      _showError(
        'Erreur inattendue: ${e.toString()}. Veuillez contacter le support.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- MODIFIED: Login Function ---
  Future<void> _login() async {
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      final bool userWantsToStaySignedIn = _staySignedIn;
      print(
        'DEBUG: User "Rester connecté" preference: $userWantsToStaySignedIn',
      );
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      final session = response.session;
      final user = response.user;
      if (session != null && user != null) {
        if (user.emailConfirmedAt == null) {
          await Supabase.instance.client.auth.signOut();
          _showError('Veuillez confirmer votre email avant de vous connecter.');
          return;
        }
        if (mounted) {
          try {
            final memberResponse = await Supabase.instance.client
                .from('cabinet_members')
                .select('cabinet_id, role')
                .eq('user_id', user.id)
                .eq('is_active', true)
                .limit(2);
            if (memberResponse.isEmpty) {
              _showError(
                'Votre compte n\'est associé à aucun cabinet. Veuillez contacter l\'administrateur.',
              );
              await Supabase.instance.client.auth.signOut();
              if (mounted) setState(() => _isLoading = false);
              return;
            } else if (memberResponse.length > 1) {
              print(
                'User belongs to multiple cabinets. Picking the first one or showing selector.',
              );
            }
            final cabinetId = memberResponse[0]['cabinet_id'] as String?;
            if (cabinetId == null) {
              throw Exception(
                'User membership record found but cabinet_id is null.',
              );
            }
            final patientProvider = Provider.of<PatientProvider>(
              context,
              listen: false,
            );
            patientProvider.setCurrentCabinetId(cabinetId);
            print('DEBUG: Set cabinet ID for logged in user: $cabinetId');
            if (kIsWeb) {
              html.window.history.pushState(null, 'Home', '/home');
            }
            Navigator.of(context).pushReplacementNamed('/home');
          } catch (e) {
            print('DEBUG: Error during login cabinet check: $e');
            await Supabase.instance.client.auth.signOut();
            _showError(
              'Erreur lors de la récupération des informations du cabinet. Veuillez réessayer ou contacter le support.',
            );
          }
        }
      } else {
        print('DEBUG: Login failed, session or user is null.');
        _showError('Email ou mot de passe incorrect.');
      }
    } on AuthException catch (e) {
      print('DEBUG: AuthException during login: $e');
      if (e.message.contains('Invalid login credentials')) {
        _showError('Email ou mot de passe incorrect.');
      } else {
        _showError('Erreur de connexion: ${e.message}');
      }
    } catch (e) {
      print('DEBUG: Unexpected error during login: $e');
      _showError('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Match old screen background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Match old screen padding
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), // Match old screen max width
            child: Column(
              children: [
                Text(
                  _isLogin
                      ? 'Connexion' // Match old screen title
                      : (_signupStep == 1
                            ? 'Vérifier le Code Cabinet' // Match old screen title
                            : _signupStep == 2
                            ? 'Compléter l\'inscription' // Match old screen title
                            : 'Créer un Cabinet'), // New title for step 3
                  style: GoogleFonts.montserrat(
                    fontSize: 32, // Match old screen font size
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800, // Match old screen color
                  ),
                ),
                const SizedBox(height: 32), // Match old screen spacing
                // Error Message Container (Styled like old screen)
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
                // --- Login Form ---
                if (_isLogin)
                  Form(
                    key: _formKeyStep1, // Reuse key for login
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                            ), // Match old screen icon
                          ),
                          validator: (v) => v?.isEmpty == true
                              ? 'Email requis'
                              : null, // Match old screen validator
                        ),
                        const SizedBox(height: 16), // Match old screen spacing
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(
                              Icons.lock,
                            ), // Match old screen icon
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
                          validator: (v) => v?.isEmpty == true
                              ? 'Mot de passe requis'
                              : null, // Match old screen validator
                        ),
                        // --- "Rester connecté" Checkbox (Styled like old screen) ---
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
                        // --- "Mot de passe oublié" Button (Added and styled like old screen) ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                _sendPasswordResetEmail, // Link to new function
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ),
                        const SizedBox(height: 24), // Match old screen spacing
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  child: Text(
                                    'Se connecter', // Match old screen button text
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                    ), // Match old screen font
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                // --- Signup Forms (Conditional rendering based on step) ---
                if (!_isLogin)
                  _signupStep == 1
                      ? // Step 1: Signup Code / Email (Styled like old screen)
                        Form(
                          key: _formKeyStep1,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType
                                    .emailAddress, // Added keyboardType
                                decoration: const InputDecoration(
                                  labelText: 'Email', // Match old screen label
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ), // Match old screen icon
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Email requis'
                                    : null, // Match old screen validator
                              ),
                              const SizedBox(
                                height: 16,
                              ), // Match old screen spacing
                              TextFormField(
                                controller: _signupCodeCtrl,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Code Cabinet', // Match old screen label
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                  ), // Match old screen icon
                                  hintText:
                                      'Fourni par le docteur', // Match old screen hint
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Code cabinet requis'
                                    : null, // Match old screen validator
                              ),
                              const SizedBox(
                                height: 24,
                              ), // Match old screen spacing
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _validateSignupCode,
                                        child: Text(
                                          'Vérifier le Code', // Match old screen button text
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                          ), // Match old screen font
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        )
                      : _signupStep == 2
                      ? // Step 2: User Details (Styled like old screen)
                        Form(
                          key: _formKeyStep2,
                          child: Column(
                            children: [
                              // Display validated info (Styled like old screen)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.teal.shade200,
                                  ),
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
                              const SizedBox(
                                height: 16,
                              ), // Match old screen spacing
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText:
                                      'Mot de passe', // Match old screen label
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ), // Match old screen icon
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Mot de passe requis'
                                    : null, // Match old screen validator
                              ),
                              const SizedBox(
                                height: 16,
                              ), // Match old screen spacing
                              TextFormField(
                                controller: _fullNameCtrl,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Nom complet', // Match old screen label
                                  prefixIcon: Icon(
                                    Icons.person,
                                  ), // Match old screen icon
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Nom complet requis'
                                    : null, // Match old screen validator
                              ),
                              const SizedBox(
                                height: 16,
                              ), // Match old screen spacing
                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType:
                                    TextInputType.phone, // Added keyboardType
                                decoration: const InputDecoration(
                                  labelText:
                                      'Téléphone', // Match old screen label
                                  prefixIcon: Icon(
                                    Icons.phone,
                                  ), // Match old screen icon
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Numéro de téléphone requis' // Match old screen validator
                                    : null,
                              ),
                              const SizedBox(
                                height: 24,
                              ), // Match old screen spacing
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Row(
                                      children: [
                                        // Back button to re-enter code (Styled like old screen)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _signupStep =
                                                  1; // Go back to step 1
                                              _errorMsg = null;
                                            });
                                          },
                                          child: Text(
                                            'Retour', // Match old screen button text
                                            style:
                                                GoogleFonts.montserrat(), // Match old screen font
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width:
                                              200, // Match old screen button width
                                          child: ElevatedButton(
                                            onPressed: _signUp,
                                            child: Text(
                                              'S\'inscrire', // Match old screen button text
                                              style: GoogleFonts.montserrat(
                                                fontSize:
                                                    18, // Match old screen font size
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        )
                      : // Step 3: Cabinet Details (New step, styled consistently)
                        Form(
                          key: _formKeyStep3,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _cabinetNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nom du cabinet',
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir le nom du cabinet';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetAddressCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Adresse',
                                  prefixIcon: Icon(Icons.location_on),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetPhoneCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Numéro de téléphone',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetEmailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email du cabinet',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetWebsiteCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Site web',
                                  prefixIcon: Icon(Icons.web),
                                ),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Row(
                                      children: [
                                        // Back button to user details
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _signupStep = 2;
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
                                          width: 200,
                                          child: ElevatedButton(
                                            onPressed:
                                                _createCabinetAndFinalizeSignup,
                                            child: Text(
                                              'Créer le cabinet',
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
                        ),
                const SizedBox(height: 16), // Match old screen spacing
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
                        ? 'Pas encore de compte ? S\'inscrire' // Match old screen text
                        : 'Déjà un compte ? Se connecter', // Match old screen text
                    style: GoogleFonts.montserrat(
                      color: Colors.teal.shade800,
                    ), // Match old screen style
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
