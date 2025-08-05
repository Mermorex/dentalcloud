// lib/screens/edit_patient_screen.dart
import 'package:dental/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../widgets/main_button.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;
  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emergencyContactNameCtrl;
  late final TextEditingController _emergencyContactPhoneCtrl;
  late final TextEditingController _primaryLanguageCtrl;
  late final TextEditingController _alertsCtrl;
  late final TextEditingController _systemicDiseasesCtrl;
  late final TextEditingController _medicationsCtrl;
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _pastSurgeriesCtrl;
  late final TextEditingController _lifestyleFactorsCtrl;
  late final TextEditingController _pregnancyLactationStatusCtrl;
  late final TextEditingController _chiefComplaintCtrl;
  late final TextEditingController _pastDentalTreatmentsCtrl;
  late final TextEditingController _previousDentalProblemsCtrl;
  late final TextEditingController _oralHygieneHabitsCtrl;
  late final TextEditingController _lastDentalVisitCtrl;
  late final TextEditingController _lastXRayCtrl;
  String? _selectedGender; // This will hold the selected gender

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameCtrl = TextEditingController(text: widget.patient.name);
    _ageCtrl = TextEditingController(
      text: widget.patient.age?.toString() ?? '',
    );
    _phoneCtrl = TextEditingController(text: widget.patient.phone ?? '');
    _dobCtrl = TextEditingController(text: widget.patient.dateOfBirth ?? '');
    _emailCtrl = TextEditingController(text: widget.patient.email ?? '');
    _addressCtrl = TextEditingController(text: widget.patient.address ?? '');
    _emergencyContactNameCtrl = TextEditingController(
      text: widget.patient.emergencyContactName ?? '',
    );
    _emergencyContactPhoneCtrl = TextEditingController(
      text: widget.patient.emergencyContactPhone ?? '',
    );
    _primaryLanguageCtrl = TextEditingController(
      text: widget.patient.primaryLanguage ?? '',
    );
    _alertsCtrl = TextEditingController(text: widget.patient.alerts ?? '');
    _systemicDiseasesCtrl = TextEditingController(
      text: widget.patient.systemicDiseases ?? '',
    );
    _medicationsCtrl = TextEditingController(
      text: widget.patient.medications ?? '',
    );
    _allergiesCtrl = TextEditingController(
      text: widget.patient.allergies ?? '',
    );
    _pastSurgeriesCtrl = TextEditingController(
      text: widget.patient.pastSurgeriesHospitalizations ?? '',
    );
    _lifestyleFactorsCtrl = TextEditingController(
      text: widget.patient.lifestyleFactors ?? '',
    );
    _pregnancyLactationStatusCtrl = TextEditingController(
      text: widget.patient.pregnancyLactationStatus ?? '',
    );
    _chiefComplaintCtrl = TextEditingController(
      text: widget.patient.chiefComplaint ?? '',
    );
    _pastDentalTreatmentsCtrl = TextEditingController(
      text: widget.patient.pastDentalTreatments ?? '',
    );
    _previousDentalProblemsCtrl = TextEditingController(
      text: widget.patient.previousDentalProblems ?? '',
    );
    _oralHygieneHabitsCtrl = TextEditingController(
      text: widget.patient.oralHygieneHabits ?? '',
    );
    _lastDentalVisitCtrl = TextEditingController(
      text: widget.patient.lastDentalVisit ?? '',
    );
    _lastXRayCtrl = TextEditingController(text: widget.patient.lastXray ?? '');

    // --- POTENTIAL FIX: Ensure _selectedGender is valid ---
    // Check if the patient's gender from DB is a valid option.
    // If not, set _selectedGender to null to avoid DropdownButton assertion error.
    final validGenders = ['Male', 'Female'];
    if (widget.patient.gender != null &&
        validGenders.contains(widget.patient.gender)) {
      _selectedGender = widget.patient.gender;
    } else {
      _selectedGender = null; // Or a default like validGenders.first if desired
    }
    // --- END OF POTENTIAL FIX ---
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
                textStyle: GoogleFonts.montserrat(),
              ),
            ),
            textTheme: TextTheme(
              titleLarge: GoogleFonts.montserrat(),
              bodyLarge: GoogleFonts.montserrat(),
              bodyMedium: GoogleFonts.montserrat(),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().substring(0, 10);
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

      // --- POTENTIAL FIX: Validate gender if required ---
      // If gender is required, uncomment the next lines:
      /*
      if (_selectedGender == null || _selectedGender!.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(
               'Le sexe du patient est requis.',
               style: GoogleFonts.montserrat(),
             ),
             backgroundColor: Colors.red,
           ),
         );
         return;
       }
       */
      // --- END OF POTENTIAL FIX ---

      final updatedPatient = widget.patient.copyWith(
        name: _nameCtrl.text,
        age: age,
        gender:
            _selectedGender, // Use the potentially validated _selectedGender
        phone: _phoneCtrl.text,
        dateOfBirth: _dobCtrl.text,
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
        lastXray: _lastXRayCtrl.text.isEmpty ? null : _lastXRayCtrl.text,
      );

      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      try {
        await patientProvider.updatePatient(updatedPatient);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Patient ${updatedPatient.name} mis à jour avec succès !',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de la mise à jour : $e',
                style: GoogleFonts.montserrat(),
              ),
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
          'Modifier le patient',
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
                            // --- POTENTIAL FIX: Improved DropdownButtonFormField ---
                            child: DropdownButtonFormField<String?>(
                              value: _selectedGender, // Can now be null
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Sexe (optionnel)', // Or 'Sexe *' if required
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
                              items:
                                  <String?>[
                                    null, // Add an explicit null option for "not selected"
                                    'Male',
                                    'Female',
                                  ].map((String? value) {
                                    if (value == null) {
                                      // Represent null as an empty selection or placeholder
                                      return const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Sélectionner...'), // Or ''
                                      );
                                    }
                                    return DropdownMenuItem<String?>(
                                      value: value,
                                      child: Text(
                                        value == 'Male' ? 'Homme' : 'Femme',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue; // Can now be null
                                });
                              },
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Le sexe est requis.';
                              //   }
                              //   return null;
                              // },
                            ),
                            // --- END OF POTENTIAL FIX ---
                          ),
                        ],
                      ),
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
        onPressed: _save,
        label: 'Enregistrer les modifications',
        icon: Icons.save,
        heroTag: 'editPatientSaveButton',
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
