// lib/screens/add_patient_screen.dart
import 'package:dental/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../widgets/main_button.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(); // Required
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergencyContactNameCtrl = TextEditingController();
  final _emergencyContactPhoneCtrl = TextEditingController();
  final _primaryLanguageCtrl = TextEditingController();
  final _alertsCtrl = TextEditingController();
  final _systemicDiseasesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _pastSurgeriesCtrl = TextEditingController();
  final _lifestyleFactorsCtrl = TextEditingController();
  final _pregnancyLactationStatusCtrl = TextEditingController();
  final _chiefComplaintCtrl = TextEditingController();
  final _pastDentalTreatmentsCtrl = TextEditingController();
  final _previousDentalProblemsCtrl = TextEditingController();
  final _oralHygieneHabitsCtrl = TextEditingController();
  final _lastDentalVisitCtrl = TextEditingController();
  final _lastXRayCtrl = TextEditingController();
  String? _gender;
  bool isLimitReached = false;

  @override
  void initState() {
    super.initState();
    _checkPatientLimit();
  }

  Future<void> _checkPatientLimit() async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    await patientProvider.loadPatients();
    if (mounted) {
      setState(() {
        isLimitReached =
            patientProvider.patients.length >=
            PatientProvider.MAX_PATIENT_LIMIT;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? initialDate = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text)
        : null;
    initialDate ??= DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
            ),
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = picked.toIso8601String().substring(0, 10);
      setState(() {
        controller.text = formattedDate;
        // Auto-calculate age from DOB
        if (controller == _dobCtrl && formattedDate.isNotEmpty) {
          final dobYear = picked.year;
          final currentYear = DateTime.now().year;
          final age = currentYear - dobYear;
          if (age >= 0) _ageCtrl.text = age.toString();
        }
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final int? age = _ageCtrl.text.isNotEmpty
          ? int.tryParse(_ageCtrl.text)
          : null;
      if (age != null && age < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'L\'âge ne peut pas être négatif.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // --- FIXED: Removed cabinetCode from Patient constructor ---
      // The PatientProvider and DatabaseHelper will handle associating the patient
      // with the current cabinet ID.
      final newPatient = Patient(
        // id: '', // Let the database generate the ID
        name: _nameCtrl.text,
        age: age ?? 0, // Backend logic may allow 0, or you can omit default
        gender:
            _gender ??
            '', // If gender is optional but non-null in model, use empty string
        phone: _phoneCtrl.text,
        dateOfBirth: _dobCtrl.text, // Required, so not null
        email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
        address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text,
        emergencyContactName: _emergencyContactNameCtrl.text.isEmpty
            ? null
            : _emergencyContactNameCtrl.text,
        emergencyContactPhone: _emergencyContactPhoneCtrl.text.isEmpty
            ? null
            : _emergencyContactPhoneCtrl.text,
        primaryLanguage: _primaryLanguageCtrl.text.isEmpty
            ? null
            : _primaryLanguageCtrl.text,
        alerts: _alertsCtrl.text.isEmpty ? null : _alertsCtrl.text,
        systemicDiseases: _systemicDiseasesCtrl.text.isEmpty
            ? null
            : _systemicDiseasesCtrl.text,
        medications: _medicationsCtrl.text.isEmpty
            ? null
            : _medicationsCtrl.text,
        allergies: _allergiesCtrl.text.isEmpty ? null : _allergiesCtrl.text,
        pastSurgeriesHospitalizations: _pastSurgeriesCtrl.text.isEmpty
            ? null
            : _pastSurgeriesCtrl.text,
        lifestyleFactors: _lifestyleFactorsCtrl.text.isEmpty
            ? null
            : _lifestyleFactorsCtrl.text,
        pregnancyLactationStatus: _pregnancyLactationStatusCtrl.text.isEmpty
            ? null
            : _pregnancyLactationStatusCtrl.text,
        chiefComplaint: _chiefComplaintCtrl.text.isEmpty
            ? null
            : _chiefComplaintCtrl.text,
        pastDentalTreatments: _pastDentalTreatmentsCtrl.text.isEmpty
            ? null
            : _pastDentalTreatmentsCtrl.text,
        previousDentalProblems: _previousDentalProblemsCtrl.text.isEmpty
            ? null
            : _previousDentalProblemsCtrl.text,
        oralHygieneHabits: _oralHygieneHabitsCtrl.text.isEmpty
            ? null
            : _oralHygieneHabitsCtrl.text,
        lastDentalVisit: _lastDentalVisitCtrl.text.isEmpty
            ? null
            : _lastDentalVisitCtrl.text,
        lastXray: _lastXRayCtrl.text.isEmpty
            ? null
            : _lastXRayCtrl.text, // <-- Corrected line
        visitCount: 0, // New patient
        // cabinetCode: '', // <-- REMOVED: This is handled by PatientProvider/DatabaseHelper
        // --- END OF FIX ---
      );
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      if (isLimitReached) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La limite de ${PatientProvider.MAX_PATIENT_LIMIT} patients a été atteinte.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final success = await patientProvider.addPatient(newPatient);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Patient ${newPatient.name} ajouté avec succès !',
                  style: GoogleFonts.montserrat(),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Échec de l\'ajout du patient.',
                  style: GoogleFonts.montserrat(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e', style: GoogleFonts.montserrat()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? hintText,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.montserrat(fontSize: 18),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(fontSize: 18),
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: Colors.grey.shade500,
            fontSize: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.teal, width: 2.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 20.0,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: 28.0,
                    height: 28.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: IconTheme(
                        data: IconThemeData(
                          size: 28.0,
                          color: Colors.teal.shade700,
                        ),
                        child: prefixIcon,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
        textInputAction: textInputAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Ajouter un nouveau patient',
          style: GoogleFonts.montserrat(
            fontSize: (isTablet ? 32 : 24) * textScaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.teal.shade600,
              size: isTablet ? 32 : 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Retour',
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Informations de base ---
                      _buildSection(
                        title: 'Informations de base',
                        children: [
                          _buildTextField(
                            controller: _nameCtrl,
                            labelText: 'Nom *',
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Le nom est requis';
                              return null;
                            },
                            prefixIcon: const Icon(Icons.person),
                          ),
                          _buildTextField(
                            controller: _phoneCtrl,
                            labelText: 'Téléphone *',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Le téléphone est requis';
                              return null;
                            },
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          _buildTextField(
                            controller: _dobCtrl,
                            labelText:
                                'Date de naissance (optionnel)', // Updated label text
                            hintText: 'Sélectionnez la date', // Added hint text
                            readOnly: true,
                            onTap: () => _selectDate(_dobCtrl),
                            // validator: (value) { // REMOVED: Mandatory validation
                            //   if (value == null || value.isEmpty)
                            //     return 'La date de naissance est requise';
                            //   return null;
                            // },
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          _buildTextField(
                            controller: _ageCtrl,
                            labelText: 'Âge (optionnel)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.cake),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: DropdownButtonFormField<String>(
                              value: _gender,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Sexe (optionnel)',
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 18,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: SizedBox(
                                    width: 28.0,
                                    height: 28.0,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: IconTheme(
                                        data: IconThemeData(
                                          size: 28.0,
                                          color: Colors.teal.shade700,
                                        ),
                                        child: const Icon(Icons.wc_outlined),
                                      ),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                    width: 2.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 20.0,
                                ),
                              ),
                              items: ['Male', 'Female'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value == 'Male' ? 'Homme' : 'Femme',
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _gender = newValue;
                                });
                              },
                              // No validator — gender is optional
                            ),
                          ),
                        ],
                      ),
                      // --- Démographie (Facultatif) ---
                      _buildSection(
                        title: 'Démographie (Facultatif)',
                        children: [
                          _buildTextField(
                            controller: _emailCtrl,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          _buildTextField(
                            controller: _addressCtrl,
                            labelText: 'Adresse',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          _buildTextField(
                            controller: _emergencyContactNameCtrl,
                            labelText: 'Nom du contact d\'urgence',
                            prefixIcon: const Icon(Icons.contact_emergency),
                          ),
                          _buildTextField(
                            controller: _emergencyContactPhoneCtrl,
                            labelText: 'Téléphone du contact d\'urgence',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_in_talk),
                          ),
                          _buildTextField(
                            controller: _primaryLanguageCtrl,
                            labelText: 'Langue principale',
                            prefixIcon: const Icon(Icons.language),
                          ),
                        ],
                      ),
                      // --- Antécédents médicaux (Facultatif) ---
                      _buildSection(
                        title: 'Antécédents médicaux (Facultatif)',
                        children: [
                          _buildTextField(
                            controller: _alertsCtrl,
                            labelText: 'Alertes',
                            hintText: 'Ex: Diabète, problèmes cardiaques',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.warning),
                          ),
                          _buildTextField(
                            controller: _systemicDiseasesCtrl,
                            labelText: 'Maladies systémiques',
                            hintText: 'Ex: Hypertension, asthme',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(
                              Icons.medical_services_outlined,
                            ),
                          ),
                          _buildTextField(
                            controller: _medicationsCtrl,
                            labelText: 'Médicaments',
                            hintText: 'Ex: Insuline, anti-inflammatoires',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.medication),
                          ),
                          _buildTextField(
                            controller: _allergiesCtrl,
                            labelText: 'Allergies',
                            hintText: 'Ex: Pénicilline, latex',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.do_not_disturb),
                          ),
                          _buildTextField(
                            controller: _pastSurgeriesCtrl,
                            labelText:
                                'Chirurgies antérieures / Hospitalisations',
                            hintText: 'Ex: Appendicectomie, fracture',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.cut),
                          ),
                          _buildTextField(
                            controller: _lifestyleFactorsCtrl,
                            labelText:
                                'Facteurs de mode de vie (Tabac, Alcool, etc.)',
                            hintText: 'Ex: Fumeur, consommation modérée',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sports_baseball),
                          ),
                          _buildTextField(
                            controller: _pregnancyLactationStatusCtrl,
                            labelText: 'Statut de grossesse/allaitement',
                            hintText: 'Ex: Enceinte (3e trimestre), allaite',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.pregnant_woman),
                          ),
                        ],
                      ),
                      // --- Antécédents dentaires (Facultatif) ---
                      _buildSection(
                        title: 'Antécédents dentaires (Facultatif)',
                        children: [
                          _buildTextField(
                            controller: _chiefComplaintCtrl,
                            labelText: 'Plainte principale',
                            hintText: 'Ex: Mal de dents, carie',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sick),
                          ),
                          _buildTextField(
                            controller: _pastDentalTreatmentsCtrl,
                            labelText: 'Traitements dentaires antérieurs',
                            hintText: 'Ex: Plombages, extractions',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.healing_outlined),
                          ),
                          _buildTextField(
                            controller: _previousDentalProblemsCtrl,
                            labelText: 'Problèmes dentaires antérieurs',
                            hintText: 'Ex: Gencives sensibles, abcès',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sick_outlined),
                          ),
                          _buildTextField(
                            controller: _oralHygieneHabitsCtrl,
                            labelText: 'Habitudes d\'hygiène buccale',
                            hintText: 'Ex: Brossage 2x/jour, fil dentaire',
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.brush),
                          ),
                          _buildTextField(
                            controller: _lastDentalVisitCtrl,
                            labelText: 'Dernière visite dentaire',
                            readOnly: true,
                            onTap: () => _selectDate(_lastDentalVisitCtrl),
                            prefixIcon: const Icon(Icons.event_available),
                          ),
                          _buildTextField(
                            controller: _lastXRayCtrl,
                            labelText: 'Dernière radiographie',
                            readOnly: true,
                            onTap: () => _selectDate(_lastXRayCtrl),
                            prefixIcon: const Icon(Icons.medical_services),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MainButton(
        onPressed: isLimitReached ? null : _save,
        label: 'Enregistrer le patient',
        icon: Icons.save,
        backgroundColor: isLimitReached ? Colors.grey : Colors.teal,
        foregroundColor: Colors.white,
        heroTag: 'addPatientSaveButton',
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyContactNameCtrl.dispose();
    _emergencyContactPhoneCtrl.dispose();
    _primaryLanguageCtrl.dispose();
    _alertsCtrl.dispose();
    _systemicDiseasesCtrl.dispose();
    _medicationsCtrl.dispose();
    _allergiesCtrl.dispose();
    _pastSurgeriesCtrl.dispose();
    _lifestyleFactorsCtrl.dispose();
    _pregnancyLactationStatusCtrl.dispose();
    _chiefComplaintCtrl.dispose();
    _pastDentalTreatmentsCtrl.dispose();
    _previousDentalProblemsCtrl.dispose();
    _oralHygieneHabitsCtrl.dispose();
    _lastDentalVisitCtrl.dispose();
    _lastXRayCtrl.dispose();
    super.dispose();
  }
}
