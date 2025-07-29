// lib/screens/edit_patient_screen.dart
import 'package:dental/providers/patient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import '../models/patient.dart';
import '../widgets/main_button.dart'; // Import the MainButton widget

class EditPatientScreen extends StatefulWidget {
  final Patient patient;
  const EditPatientScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _phoneCtrl;

  late TextEditingController _dobCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emergencyContactNameCtrl;
  late TextEditingController _emergencyContactPhoneCtrl;
  late TextEditingController _primaryLanguageCtrl;
  late TextEditingController _alertsCtrl;
  late TextEditingController _systemicDiseasesCtrl;
  late TextEditingController _medicationsCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _pastSurgeriesCtrl;
  late TextEditingController _lifestyleFactorsCtrl;
  late TextEditingController _pregnancyLactationStatusCtrl;
  late TextEditingController _chiefComplaintCtrl;
  late TextEditingController _pastDentalTreatmentsCtrl;
  late TextEditingController _previousDentalProblemsCtrl;
  late TextEditingController _oralHygieneHabitsCtrl;
  late TextEditingController _lastDentalVisitCtrl;
  late TextEditingController _lastXRayCtrl;

  late String _selectedGender; // Default gender

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    _nameCtrl = TextEditingController(text: patient.name);
    _ageCtrl = TextEditingController(text: patient.age.toString());
    _phoneCtrl = TextEditingController(text: patient.phone);
    _dobCtrl = TextEditingController(text: patient.dateOfBirth);
    _emailCtrl = TextEditingController(text: patient.email);
    _addressCtrl = TextEditingController(text: patient.address);
    _emergencyContactNameCtrl = TextEditingController(
      text: patient.emergencyContactName,
    );
    _emergencyContactPhoneCtrl = TextEditingController(
      text: patient.emergencyContactPhone,
    );
    _primaryLanguageCtrl = TextEditingController(text: patient.primaryLanguage);
    _alertsCtrl = TextEditingController(text: patient.alerts);
    _systemicDiseasesCtrl = TextEditingController(
      text: patient.systemicDiseases,
    );
    _medicationsCtrl = TextEditingController(text: patient.medications);
    _allergiesCtrl = TextEditingController(text: patient.allergies);
    _pastSurgeriesCtrl = TextEditingController(
      text: patient.pastSurgeriesHospitalizations,
    );
    _lifestyleFactorsCtrl = TextEditingController(
      text: patient.lifestyleFactors,
    );
    _pregnancyLactationStatusCtrl = TextEditingController(
      text: patient.pregnancyLactationStatus,
    );
    _chiefComplaintCtrl = TextEditingController(text: patient.chiefComplaint);
    _pastDentalTreatmentsCtrl = TextEditingController(
      text: patient.pastDentalTreatments,
    );
    _previousDentalProblemsCtrl = TextEditingController(
      text: patient.previousDentalProblems,
    );
    _oralHygieneHabitsCtrl = TextEditingController(
      text: patient.oralHygieneHabits,
    );
    _lastDentalVisitCtrl = TextEditingController(text: patient.lastDentalVisit);
    _lastXRayCtrl = TextEditingController(text: patient.lastXRay);

    // Set _selectedGender, ensuring it's one of 'Male' or 'Female'
    if (patient.gender == 'Other') {
      _selectedGender =
          'Male'; // Default to Male if patient's gender was 'Other'
    } else {
      _selectedGender = patient.gender;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedPatient = Patient(
        id: widget.patient.id, // Keep the existing ID
        name: _nameCtrl.text,
        age: int.parse(_ageCtrl.text),
        gender: _selectedGender,
        phone: _phoneCtrl.text,
        dateOfBirth: _dobCtrl.text,
        email: _emailCtrl.text,
        address: _addressCtrl.text,
        emergencyContactName: _emergencyContactNameCtrl.text,
        emergencyContactPhone: _emergencyContactPhoneCtrl.text,
        primaryLanguage: _primaryLanguageCtrl.text,
        alerts: _alertsCtrl.text,
        systemicDiseases: _systemicDiseasesCtrl.text,
        medications: _medicationsCtrl.text,
        allergies: _allergiesCtrl.text,
        pastSurgeriesHospitalizations: _pastSurgeriesCtrl.text,
        lifestyleFactors: _lifestyleFactorsCtrl.text,
        pregnancyLactationStatus: _pregnancyLactationStatusCtrl.text,
        chiefComplaint: _chiefComplaintCtrl.text,
        pastDentalTreatments: _pastDentalTreatmentsCtrl.text,
        previousDentalProblems: _previousDentalProblemsCtrl.text,
        oralHygieneHabits: _oralHygieneHabitsCtrl.text,
        lastDentalVisit: _lastDentalVisitCtrl.text,
        lastXRay: _lastXRayCtrl.text,
      );

      Provider.of<PatientProvider>(
        context,
        listen: false,
      ).updatePatient(updatedPatient);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Patient modifié avec succès !',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Go back after saving
    }
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

  // Modified _buildSection to include card-like styling
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0), // Space between sections
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
          padding: const EdgeInsets.all(20.0), // Inner padding for the card
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
            borderSide: BorderSide(color: Colors.teal, width: 2.5),
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

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? initialDate;
    if (controller.text.isNotEmpty) {
      initialDate = DateTime.tryParse(controller.text);
    }
    initialDate ??= DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow for a flatter look
        toolbarHeight: 80, // Adjust height as needed
        title: Padding(
          padding: const EdgeInsets.only(
            left: 0.0,
          ), // Adjust padding for title if necessary
          child: Text(
            'Modifier le patient', // Edit patient
            style: GoogleFonts.montserrat(
              fontSize:
                  (isTablet ? 32 : 24) * textScaleFactor, // Adjusted font size
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
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
                            labelText: 'Nom',
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nom';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _ageCtrl,
                            labelText: 'Âge',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.cake),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un âge';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Veuillez entrer un nombre valide';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Sexe',
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
                                  borderSide: BorderSide(
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
                              items: <String>['Male', 'Female'].map((
                                String value,
                              ) {
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
                                  _selectedGender = newValue!;
                                });
                              },
                            ),
                          ),
                          _buildTextField(
                            controller: _phoneCtrl,
                            labelText: 'Téléphone',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                        ],
                      ),
                      _buildSection(
                        title: 'Démographie (Facultatif)',
                        children: [
                          _buildTextField(
                            controller: _dobCtrl,
                            labelText: 'Date de naissance (AAAA-MM-JJ)',
                            readOnly: true,
                            onTap: () => _selectDate(_dobCtrl),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          _buildTextField(
                            controller: _emailCtrl,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          _buildTextField(
                            controller: _addressCtrl,
                            labelText: 'Adresse',
                            maxLines: null, // Allow multiple lines
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
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.warning),
                          ),
                          _buildTextField(
                            controller: _systemicDiseasesCtrl,
                            labelText: 'Maladies systémiques',
                            hintText: 'Ex: Hypertension, asthme',
                            maxLines: null, // Allow multiple lines
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
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.medication),
                          ),
                          _buildTextField(
                            controller: _allergiesCtrl,
                            labelText: 'Allergies',
                            hintText: 'Ex: Pénicilline, latex',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.do_not_disturb),
                          ),
                          _buildTextField(
                            controller: _pastSurgeriesCtrl,
                            labelText:
                                'Chirurgies antérieures / Hospitalisations',
                            hintText: 'Ex: Appendicectomie, fracture',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.cut),
                          ),
                          _buildTextField(
                            controller: _lifestyleFactorsCtrl,
                            labelText:
                                'Facteurs de mode de vie (Tabac, Alcool, etc.)',
                            hintText: 'Ex: Fumeur, consommation modérée',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sports_baseball),
                          ),
                          _buildTextField(
                            controller: _pregnancyLactationStatusCtrl,
                            labelText: 'Statut de grossesse/allaitement',
                            hintText: 'Ex: Enceinte (3e trimestre), allaite',
                            maxLines: null, // Allow multiple lines
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
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sick),
                          ),
                          _buildTextField(
                            controller: _pastDentalTreatmentsCtrl,
                            labelText: 'Traitements dentaires antérieurs',
                            hintText: 'Ex: Plombages, extractions',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.healing_outlined),
                          ),
                          _buildTextField(
                            controller: _previousDentalProblemsCtrl,
                            labelText: 'Problèmes dentaires antérieurs',
                            hintText: 'Ex: Gencives sensibles, abcès',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.sick_outlined),
                          ),
                          _buildTextField(
                            controller: _oralHygieneHabitsCtrl,
                            labelText: 'Habitudes d\'hygiène buccale',
                            hintText: 'Ex: Brossage 2x/jour, fil dentaire',
                            maxLines: null, // Allow multiple lines
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            prefixIcon: const Icon(Icons.brush),
                          ),
                          _buildTextField(
                            controller: _lastDentalVisitCtrl,
                            labelText: 'Dernière visite dentaire (AAAA-MM-JJ)',
                            readOnly: true,
                            onTap: () => _selectDate(_lastDentalVisitCtrl),
                            prefixIcon: const Icon(Icons.event_available),
                          ),
                          _buildTextField(
                            controller: _lastXRayCtrl,
                            labelText: 'Dernière radiographie (AAAA-MM-JJ)',
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
        heroTag: 'editPatientSaveButton', // Unique heroTag
      ),
    );
  }
}
