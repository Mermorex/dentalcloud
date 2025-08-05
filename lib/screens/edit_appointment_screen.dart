// lib/screens/edit_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
// Import the Patient model
import '../providers/patient_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;
  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;

  late String _selectedPatientId; // Changed from int to String
  late String _selectedStatus;

  final List<String> _statusOptions = [
    'Scheduled',
    'Completed',
    'Cancelled',
    'No Show',
  ];

  final Map<String, String> _statusTranslations = {
    'Scheduled': 'Programmé',
    'Completed': 'Reporté', // Corrected translation
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.appointment.notes);
    _dateCtrl = TextEditingController(text: widget.appointment.date);
    _timeCtrl = TextEditingController(text: widget.appointment.time);
    _selectedPatientId =
        widget.appointment.patientId; // Now correctly assigned as String
    _selectedStatus = widget.appointment.status;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateCtrl.text),
      firstDate: DateTime(2000),
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
        _dateCtrl.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime;
    try {
      final parts = _timeCtrl.text.split(':');
      int hour = int.parse(parts[0].trim());
      int minute = int.parse(parts[1].split(' ')[0].trim());
      if (_timeCtrl.text.toUpperCase().contains('PM') && hour < 12) {
        hour += 12;
      } else if (_timeCtrl.text.toUpperCase().contains('AM') && hour == 12) {
        hour = 0;
      }
      initialTime = TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      initialTime = TimeOfDay.now();
      debugPrint(
        'Error parsing time for appointment ${widget.appointment.id}: $e',
      );
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
        _timeCtrl.text = picked.format(context);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedAppointment = Appointment(
        id: widget.appointment.id,
        patientId: _selectedPatientId, // Now correctly passed as String
        date: _dateCtrl.text,
        time: _timeCtrl.text,
        notes: _notesCtrl.text.trim(),
        status: _selectedStatus,
      );

      await Provider.of<PatientProvider>(
        context,
        listen: false,
      ).updateAppointment(updatedAppointment);
      if (!mounted) return;
      Navigator.pop(context);
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
    TextInputAction textInputAction =
        TextInputAction.next, // Added this parameter
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.5),
          ),
          errorStyle: GoogleFonts.montserrat(
            color: Colors.red.shade700,
            fontSize: 14,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
        textInputAction: textInputAction, // Added this parameter
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final patients = patientProvider.patients;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Consistent background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow for a flatter look
        toolbarHeight: 80, // Adjust height as needed
        title: Padding(
          padding: const EdgeInsets.only(
            left: 0.0,
          ), // Adjust padding for title if necessary
          child: Text(
            'Modifier le rendez-vous', // Edit Appointment
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
                        title: 'Détails du rendez-vous',
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: DropdownButtonFormField<String>(
                              // Changed to String
                              value: _selectedPatientId,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Sélectionner un patient',
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
                                        child: const Icon(Icons.person),
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.5,
                                  ),
                                ),
                                errorStyle: GoogleFonts.montserrat(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              items: patients.map((patient) {
                                return DropdownMenuItem<String>(
                                  // Changed to String
                                  value: patient
                                      .id, // Assuming patient.id is String
                                  child: Text(
                                    patient.name,
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  null, // Set to null to disable as per original code
                              validator: (val) => val == null
                                  ? 'Veuillez sélectionner un patient'
                                  : null,
                            ),
                          ),
                          _buildTextField(
                            controller: _dateCtrl,
                            labelText: 'Date du rendez-vous',
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          _buildTextField(
                            controller: _timeCtrl,
                            labelText: 'Heure du rendez-vous',
                            readOnly: true,
                            onTap: () => _selectTime(context),
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          _buildTextField(
                            controller: _notesCtrl,
                            labelText: 'Notes du rendez-vous',
                            hintText: 'Ajouter des notes (facultatif)',
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            textInputAction:
                                TextInputAction.newline, // Added this
                            prefixIcon: const Icon(Icons.notes),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Statut',
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
                                        child: const Icon(Icons.info_outline),
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2.5,
                                  ),
                                ),
                                errorStyle: GoogleFonts.montserrat(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              items: _statusOptions.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    _statusTranslations[status]!,
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedStatus = val!;
                                });
                              },
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveChanges,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8,
        label: Text(
          'Enregistrer les modifications',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        icon: const Icon(Icons.save, size: 28),
      ),
    );
  }
}
