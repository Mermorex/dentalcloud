// add_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/patient.dart'; // Import the Patient model
import '../providers/patient_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/patient_search_sheet.dart'; // Import the new patient search sheet
import 'package:intl/intl.dart'; // Add this import for DateFormat
import '../widgets/main_button.dart'; // Import the MainButton widget

class AddAppointmentScreen extends StatefulWidget {
  final DateTime?
  initialDate; // Optional initial date passed from previous screen
  const AddAppointmentScreen({
    super.key,
    this.initialDate,
  }); // Constructor accepts initialDate

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _patientCtrl = TextEditingController(); // Controller for patient name
  String? _selectedPatientId; // Changed from int? to String?
  String? _selectedPatientName; // Store selected patient's name
  String _selectedStatus = 'Scheduled';
  final List<String> _statusOptions = [
    'Scheduled',
    'Reported', // Note: This seems to be the intended translation for 'Completed' based on your list screen. Keeping as is.
    'Cancelled',
    'No Show',
  ];
  final Map<String, String> _statusTranslations = {
    'Scheduled': 'Programmé',
    'Reported': 'Reporté',
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };

  @override
  void initState() {
    super.initState();
    print('AddAppointmentScreen: initState called.');
    print(
      'AddAppointmentScreen: widget.initialDate received: ${widget.initialDate}',
    );
    print(
      'AddAppointmentScreen: widget.initialDate type: ${widget.initialDate?.runtimeType}',
    );

    // Initialize date controller here, as it doesn't depend on context
    if (widget.initialDate != null) {
      // <-- If an initial date was passed, use it
      try {
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(widget.initialDate!);
        print(
          'AddAppointmentScreen: Successfully formatted initial date to: ${_dateCtrl.text}',
        );
      } catch (e) {
        print(
          'AddAppointmentScreen: Error formatting initial date: $e. Defaulting to today.',
        );
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
    } else {
      // <-- Otherwise, default to today's date
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      print(
        'AddAppointmentScreen: No initial date received, defaulting to today: ${_dateCtrl.text}', // Log the formatted date string
      );
    }
    // _timeCtrl.text = TimeOfDay.now().format(context); // MOVED THIS LINE
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize time controller here, as it depends on context for format()
    // Only set if it's empty to avoid re-setting on every dependency change
    if (_timeCtrl.text.isEmpty) {
      _timeCtrl.text = TimeOfDay.now().format(context);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _patientCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal, // OK/Cancel button color
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
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal, // OK/Cancel button color
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
        controller.text = picked.format(context);
      });
    }
  }

  void _saveAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_selectedPatientId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Veuillez sélectionner un patient.',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final newAppointment = Appointment(
        patientId: _selectedPatientId!,
        date: _dateCtrl.text,
        time: _timeCtrl.text,
        notes: _notesCtrl.text,
        status: _selectedStatus,
      );
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sauvegarde du rendez-vous...',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      await patientProvider.addAppointment(newAppointment);
      // Check if the widget is still mounted before using context
      if (mounted) {
        // Await the completion of the SnackBar before popping the screen
        await ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(
                  'Rendez-vous ajouté avec succès !',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            )
            .closed; // This ensures the Future returns when the SnackBar is dismissed.
        // Now it's safe to pop the screen as the SnackBar operation has completed.
        if (mounted) {
          // Re-check mounted status as it's an async gap
          Navigator.of(context).pop();
        }
      }
    }
  }

  // Modified to show a dialog instead of a bottom sheet
  Future<void> _selectPatient() async {
    final selectedPatient = await showDialog<Patient>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: PatientSearchSheet(
            isDialog: true, // Pass a flag to indicate it's in a dialog
          ),
        );
      },
    );
    if (selectedPatient != null) {
      setState(() {
        _selectedPatientId = selectedPatient.id;
        _selectedPatientName = selectedPatient.name;
        _patientCtrl.text = _selectedPatientName!;
      });
    }
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
        textInputAction: textInputAction,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
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
            'Ajouter un Rendez-vous', // Add Appointment
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
                        title: 'Détails du Rendez-vous',
                        children: [
                          _buildTextField(
                            controller: _patientCtrl,
                            labelText: 'Patient',
                            prefixIcon: const Icon(Icons.person),
                            readOnly: true,
                            onTap: _selectPatient,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner un patient.';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _dateCtrl,
                            labelText: 'Date du rendez-vous (AAAA-MM-JJ)',
                            readOnly: true,
                            onTap: () => _selectDate(_dateCtrl),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          _buildTextField(
                            controller: _timeCtrl,
                            labelText: 'Heure du rendez-vous',
                            readOnly: true,
                            onTap: () => _selectTime(_timeCtrl),
                            prefixIcon: const Icon(Icons.access_time),
                          ),
                          _buildTextField(
                            controller: _notesCtrl,
                            labelText: 'Notes (Facultatif)',
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
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
                              items: _statusOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    _statusTranslations[value]!,
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
      floatingActionButton: MainButton(
        onPressed: _saveAppointment,
        label: 'Enregistrer le rendez-vous',
        icon: Icons.save,
        // You can customize other properties here if needed, e.g.:
        // backgroundColor: Colors.green,
        // foregroundColor: Colors.yellow,
        // iconSize: 32.0,
        // fontSize: 20.0,
      ),
    );
  }
}
