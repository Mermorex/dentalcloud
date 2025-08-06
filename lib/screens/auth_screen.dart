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
  // Cabinet Details
  final _cabinetNameCtrl = TextEditingController();
  final _cabinetAddressCtrl = TextEditingController();
  final _cabinetPhoneCtrl = TextEditingController();
  final _cabinetEmailCtrl = TextEditingController();
  final _cabinetWebsiteCtrl = TextEditingController();
  // Form Keys
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  int _signupStep = 1; // 1: Code, 2: User, 3: Cabinet
  bool _isCreatingCabinet = false;
  bool _staySignedIn = true;
  String? _errorMsg;
  String? _validatedSignupCode;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _signupCodeCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cabinetNameCtrl.dispose();
    _cabinetAddressCtrl.dispose();
    _cabinetPhoneCtrl.dispose();
    _cabinetEmailCtrl.dispose();
    _cabinetWebsiteCtrl.dispose();
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
    _cabinetNameCtrl.clear();
    _cabinetAddressCtrl.clear();
    _cabinetPhoneCtrl.clear();
    _cabinetEmailCtrl.clear();
    _cabinetWebsiteCtrl.clear();
    setState(() {
      _errorMsg = null;
      _validatedSignupCode = null;
      _isCreatingCabinet = false;
      _signupStep = 1;
    });
  }

  // --- Password Reset ---
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
            : 'https://dentypro.smarthub.tn/set-password',
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

  // --- Validate Signup Code ---
  Future<void> _validateSignupCode() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMsg = null;
    final signupCode = _signupCodeCtrl.text.trim().toUpperCase();
    try {
      final response = await Supabase.instance.client
          .from('signup_codes')
          .select('cabinet_id, is_used, is_active')
          .eq('code', signupCode);
      if (response.isEmpty) {
        _showError(
          'Code cabinet introuvable. Veuillez vérifier le code fourni.',
        );
        return;
      }
      final data = response[0];
      final bool isUsed = data['is_used'] == true;
      final bool isActive = data['is_active'] == true;
      final dynamic cabinetId = data['cabinet_id'];
      if (!isUsed && cabinetId == null) {
        // Doctor creating new cabinet
        setState(() {
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = true;
          _signupStep = 2;
        });
      } else if (isUsed && isActive && cabinetId != null) {
        // Secretary joining existing cabinet
        setState(() {
          _validatedSignupCode = signupCode;
          _isCreatingCabinet = false;
          _signupStep = 2;
        });
      } else {
        _showError(
          'Le cabinet associé à ce code est désactivé ou indisponible.',
        );
      }
    } catch (e) {
      _showError('Erreur lors de la vérification du code.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Sign Up (Step 2) ---
  Future<void> _signUp() async {
    if (_signupStep == 2) {
      if (!_formKeyStep2.currentState!.validate()) return;
      setState(() => _isLoading = true);
      _errorMsg = null;
      try {
        final signupCode = _validatedSignupCode!;
        final userRole = _isCreatingCabinet ? 'doctor' : 'secretary';
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        final user = response.user;
        if (user == null) {
          _showError('La création du compte a échoué. Veuillez réessayer.');
          return;
        }
        await Supabase.instance.client.auth.refreshSession();
        final profileData = {
          'id': user.id,
          'full_name': _fullNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': user.email,
        };
        try {
          await Supabase.instance.client.from('profiles').insert(profileData);
        } on PostgrestException catch (e) {
          if (e.code == '23505') {
            await Supabase.instance.client.from('profiles').upsert(profileData);
          } else {
            rethrow;
          }
        }
        if (_isCreatingCabinet) {
          setState(() {
            _signupStep = 3;
            _isLoading = false;
          });
        } else {
          final codeResponse = await Supabase.instance.client
              .from('signup_codes')
              .select('cabinet_id')
              .eq('code', signupCode)
              .single();
          final String? cabinetId = codeResponse['cabinet_id'];
          if (cabinetId == null) throw Exception('Cabinet ID manquant.');
          await Supabase.instance.client.from('cabinet_members').insert({
            'cabinet_id': cabinetId,
            'user_id': user.id,
            'role': userRole,
            'is_active': true,
          });
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Inscription réussie ! Veuillez confirmer votre email, puis vous connecter.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            _clear();
            setState(() => _isLogin = true);
          }
        }
      } on AuthException catch (e) {
        if (e.message.contains('already registered')) {
          _showError('Cet email est déjà utilisé.');
        } else {
          _showError('Erreur d\'authentification: ${e.message}');
        }
      } catch (e) {
        _showError('Erreur inattendue: ${e.toString()}');
      } finally {
        if (mounted && _signupStep != 3) setState(() => _isLoading = false);
      }
    }
  }

  // --- Create Cabinet and Finalize Signup (Step 3) ---
  Future<void> _createCabinetAndFinalizeSignup() async {
    if (!_formKeyStep3.currentState!.validate()) return;
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utilisateur non authentifié.');
      await Supabase.instance.client.rpc(
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
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Inscription réussie ! Veuillez confirmer votre email, puis vous connecter.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _clear();
        setState(() => _isLogin = true);
      }
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIN with Cabinet Active Check ---
  Future<void> _login() async {
    setState(() => _isLoading = true);
    _errorMsg = null;
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      final user = response.user;
      final session = response.session;
      if (session == null || user == null) {
        _showError('Email ou mot de passe incorrect.');
        return;
      }
      if (user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();
        _showError('Veuillez confirmer votre email avant de vous connecter.');
        return;
      }
      // 🔑 Check cabinet membership AND if cabinet is active
      final memberResponse = await Supabase.instance.client
          .from('cabinet_members')
          .select('cabinet_id, role, cabinets(is_active)')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .limit(1);
      if (memberResponse.isEmpty) {
        _showError(
          'Votre compte n\'est associé à aucun cabinet actif. Contactez l\'administrateur.',
        );
        await Supabase.instance.client.auth.signOut();
        setState(() => _isLoading = false);
        return;
      }
      final data = memberResponse[0];
      final cabinetId = data['cabinet_id'] as String?;
      final cabinetIsActive =
          ((data['cabinets'] as Map?)?['is_active'] ?? false) as bool;
      if (cabinetId == null) {
        _showError('Erreur interne : cabinet introuvable.');
        await Supabase.instance.client.auth.signOut();
        setState(() => _isLoading = false);
        return;
      }
      if (!cabinetIsActive) {
        _showError(
          'Accès refusé : ce cabinet est désactivé. Veuillez contacter l\'administrateur.',
        );
        await Supabase.instance.client.auth.signOut();
        setState(() => _isLoading = false);
        return;
      }
      // ✅ All checks passed — proceed to home
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      patientProvider.setCurrentCabinetId(cabinetId);
      if (kIsWeb) {
        html.window.history.pushState(null, 'Home', '/home');
      }
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        _showError('Email ou mot de passe incorrect.');
      } else {
        _showError('Erreur de connexion: ${e.message}');
      }
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
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo ---
                Image.asset(
                  'assets/images/dentypro_logo.png',
                  height: 200, // Adjust height as needed
                  width: 200, // Adjust width to fit your logo naturally
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                // --- Title ---
                Text(
                  _isLogin
                      ? 'Connexion'
                      : (_signupStep == 1
                            ? 'Vérifier le Code Cabinet'
                            : _signupStep == 2
                            ? 'Compléter l\'inscription'
                            : 'Créer un Cabinet'),
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),

                // --- Error Message ---
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

                // --- LOGIN FORM ---
                if (_isLogin)
                  Form(
                    key: _formKeyStep1,
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
                        Row(
                          children: [
                            Checkbox(
                              value: _staySignedIn,
                              onChanged: (value) {
                                setState(() => _staySignedIn = value ?? true);
                              },
                            ),
                            const Text('Rester connecté'),
                          ],
                        ),
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
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Se connecter',
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                // --- SIGNUP FLOW ---
                if (!_isLogin)
                  _signupStep == 1
                      ? Form(
                          key: _formKeyStep1,
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
                                validator: (v) => v?.isEmpty == true
                                    ? 'Code cabinet requis'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _validateSignupCode,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        child: Text(
                                          'Vérifier le Code',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        )
                      : _signupStep == 2
                      ? Form(
                          key: _formKeyStep2,
                          child: Column(
                            children: [
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
                                    Text('Email: ${_emailCtrl.text.trim()}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Action: ${_isCreatingCabinet ? 'Créer un cabinet' : 'Rejoindre un cabinet'}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Code Cabinet: $_validatedSignupCode'),
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
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Mot de passe requis'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _fullNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nom complet',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Nom complet requis'
                                    : null,
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
                                        TextButton(
                                          onPressed: () => setState(() {
                                            _signupStep = 1;
                                            _errorMsg = null;
                                          }),
                                          child: Text(
                                            'Retour',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                            onPressed: _signUp,
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
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
                      : Form(
                          key: _formKeyStep3,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _cabinetNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nom du cabinet',
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Nom du cabinet requis'
                                    : null,
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
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone du cabinet',
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                validator: (v) => v?.isEmpty == true
                                    ? 'Téléphone du cabinet requis'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetEmailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email du cabinet',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                validator: (v) {
                                  if (v?.isEmpty == true)
                                    return 'Email du cabinet requis';
                                  if (!v!.contains('@'))
                                    return 'Email invalide';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _cabinetWebsiteCtrl,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                  labelText: 'Site web',
                                  prefixIcon: Icon(Icons.web),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => setState(() {
                                            _signupStep = 2;
                                            _errorMsg = null;
                                          }),
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
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
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

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _clear();
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
