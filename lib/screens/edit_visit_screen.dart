// lib/screens/edit_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../models/appointment.dart'; // Import Appointment model

class EditVisitScreen extends StatefulWidget {
  final Visit visit;
  final String patientId;

  const EditVisitScreen({
    super.key,
    required this.visit,
    required this.patientId,
  });

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _purposeCtrl;
  late TextEditingController _findingsCtrl;
  late TextEditingController _treatmentCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _nextVisitDateCtrl;
  late TextEditingController _nextVisitTimeCtrl; // Added for next visit time
  late bool _isPaid;
  late TextEditingController _amountPaidCtrl;
  late TextEditingController _totalAmountCtrl;

  // Store original values to detect changes for appointment management
  String? _originalNextVisitDate;
  String? _originalNextVisitTime;
  String? _originalVisitId; // To link the appointment back to the visit

  @override
  void initState() {
    super.initState();
    _dateCtrl = TextEditingController(text: widget.visit.date);
    _timeCtrl = TextEditingController(text: widget.visit.time);
    _purposeCtrl = TextEditingController(text: widget.visit.purpose);
    _findingsCtrl = TextEditingController(text: widget.visit.findings);
    _treatmentCtrl = TextEditingController(text: widget.visit.treatment);
    _notesCtrl = TextEditingController(text: widget.visit.notes);
    _nextVisitDateCtrl = TextEditingController(
      text: widget.visit.nextVisitDate,
    );
    _nextVisitTimeCtrl =
        TextEditingController(); // Initialize as empty, will set in _loadInitialAppointmentTime

    _isPaid = widget.visit.isPaid;
    _amountPaidCtrl = TextEditingController(
      text: widget.visit.amountPaid.toString(),
    );
    _totalAmountCtrl = TextEditingController(
      text: widget.visit.totalAmount.toString(),
    );

    // Store original values
    _originalNextVisitDate = widget.visit.nextVisitDate;
    _originalVisitId = widget.visit.id; // Store original visit ID

    // Load initial next visit time asynchronously if there's a next visit date
    if (widget.visit.nextVisitDate != null &&
        widget.visit.nextVisitDate!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialAppointmentTime();
      });
    }
  }

  Future<void> _loadInitialAppointmentTime() async {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final appointmentsForNextVisitDate = patientProvider.appointments
        .where(
          (appt) =>
              appt.patientId == widget.patientId &&
              appt.date == widget.visit.nextVisitDate &&
              appt.notes == 'Prochaine visite (auto-générée)',
        )
        .toList();

    if (appointmentsForNextVisitDate.isNotEmpty) {
      setState(() {
        _nextVisitTimeCtrl.text = appointmentsForNextVisitDate.first.time;
        _originalNextVisitTime =
            _nextVisitTimeCtrl.text; // Store this as original
      });
    } else {
      setState(() {
        _nextVisitTimeCtrl.text =
            '09:00 AM'; // Default if no matching appointment found
        _originalNextVisitTime = _nextVisitTimeCtrl.text;
      });
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _purposeCtrl.dispose();
    _findingsCtrl.dispose();
    _treatmentCtrl.dispose();
    _notesCtrl.dispose();
    _nextVisitDateCtrl.dispose();
    _nextVisitTimeCtrl.dispose();
    _amountPaidCtrl.dispose();
    _totalAmountCtrl.dispose();
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

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isPaid && _totalAmountCtrl.text.isNotEmpty) {
        _amountPaidCtrl.text = _totalAmountCtrl.text;
      }

      final updatedVisit = Visit(
        id: widget.visit.id,
        patientId: widget.patientId,
        date: _dateCtrl.text,
        time: _timeCtrl.text,
        purpose: _purposeCtrl.text,
        findings: _findingsCtrl.text,
        treatment: _treatmentCtrl.text,
        notes: _notesCtrl.text,
        nextVisitDate: _nextVisitDateCtrl.text.isEmpty
            ? null
            : _nextVisitDateCtrl.text,
        isPaid: _isPaid,
        amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0.0,
        totalAmount: double.tryParse(_totalAmountCtrl.text) ?? 0.0,
      );

      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sauvegarde des modifications...',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 1),
        ),
      );

      await patientProvider.updateVisit(updatedVisit);

      // --- Start of Appointment Management Logic for auto-generated next visit appointment ---
      final currentNextVisitDate = _nextVisitDateCtrl.text;
      final currentNextVisitTime = _nextVisitTimeCtrl.text.isNotEmpty
          ? _nextVisitTimeCtrl.text
          : '09:00 AM';

      final bool nextVisitDateChanged =
          _originalNextVisitDate != currentNextVisitDate ||
          _originalNextVisitTime != currentNextVisitTime;
      final bool nextVisitDateWasPresent =
          _originalNextVisitDate != null && _originalNextVisitDate!.isNotEmpty;
      final bool nextVisitDateIsNowPresent = currentNextVisitDate.isNotEmpty;

      // If next visit date was present, and now it's either removed or changed
      if (nextVisitDateWasPresent &&
          (nextVisitDateChanged || !nextVisitDateIsNowPresent)) {
        // Try to find and delete the old auto-generated appointment
        final List<Appointment> oldAutoAppointments = patientProvider
            .appointments
            .where(
              (appt) =>
                  appt.patientId == widget.patientId &&
                  appt.date == _originalNextVisitDate &&
                  appt.time == _originalNextVisitTime && // Use original time
                  appt.notes == 'Prochaine visite (auto-générée)',
            )
            .toList();

        for (var appt in oldAutoAppointments) {
          await patientProvider.deleteAppointment(appt.id!);
          break; // Assuming only one auto-generated appointment for this next visit
        }
      }

      // If next visit date is now present, and it was either not present before
      // or the date/time actually changed
      if (nextVisitDateIsNowPresent &&
          (nextVisitDateChanged || !nextVisitDateWasPresent)) {
        // Create a new appointment based on the updated next visit details
        final newAppointment = Appointment(
          patientId: widget.patientId,
          date: currentNextVisitDate,
          time: currentNextVisitTime,
          notes: 'Prochaine visite (auto-générée)',
          status: 'Scheduled',
        );
        await patientProvider.addAppointment(newAppointment);
      }
      // --- End of Appointment Management Logic ---

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Visite mise à jour avec succès !',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // Helper method to build consistent TextFormFields, adapted from edit_patient_screen
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
    String? prefixText,
    bool enabled = true,
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
          prefixText: prefixText,
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
        enabled: enabled,
      ),
    );
  }

  // Helper method to build consistent section headers
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

  // Helper method to build consistent sections
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier la Visite',
          style: GoogleFonts.montserrat(
            fontSize: 26, // Larger font size from edit_patient_screen
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Center title from edit_patient_screen
        backgroundColor: Colors.teal, // Consistent AppBar color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.blue.shade50],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(
                  20.0,
                ), // Padding from edit_patient_screen
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSection(
                            title: 'Détails de la Visite',
                            children: [
                              _buildTextField(
                                controller: _dateCtrl,
                                labelText: 'Date de la visite',
                                prefixIcon: const Icon(Icons.calendar_today),
                                readOnly: true,
                                onTap: () => _selectDate(_dateCtrl),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer une date';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              _buildTextField(
                                controller: _timeCtrl,
                                labelText: 'Heure de la visite',
                                prefixIcon: const Icon(Icons.access_time),
                                readOnly: true,
                                onTap: () => _selectTime(_timeCtrl),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer une heure';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              _buildTextField(
                                controller: _purposeCtrl,
                                labelText: 'Motif',
                                prefixIcon: const Icon(Icons.description),
                                maxLines: null, // Allows multiple lines
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer le motif de la visite';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _findingsCtrl,
                                labelText: 'Constatations',
                                prefixIcon: const Icon(Icons.search),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer les constatations';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _treatmentCtrl,
                                labelText: 'Traitement',
                                prefixIcon: const Icon(Icons.healing),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer le traitement';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _notesCtrl,
                                labelText: 'Notes',
                                prefixIcon: const Icon(Icons.note),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                              ),
                              _buildTextField(
                                controller: _nextVisitDateCtrl,
                                labelText:
                                    'Date de la Prochaine Visite (Optionnel)',
                                prefixIcon: const Icon(Icons.event_available),
                                readOnly: true,
                                onTap: () => _selectDate(_nextVisitDateCtrl),
                                textInputAction: TextInputAction
                                    .next, // Changed to next because of new time field
                              ),
                              _buildTextField(
                                // New field for next visit time
                                controller: _nextVisitTimeCtrl,
                                labelText:
                                    'Heure de la Prochaine Visite (Optionnel)',
                                prefixIcon: const Icon(Icons.access_time),
                                readOnly: true,
                                onTap: () => _selectTime(_nextVisitTimeCtrl),
                                textInputAction: TextInputAction
                                    .done, // Last field in section
                              ),
                            ],
                          ),
                          _buildSection(
                            title: 'Informations de Paiement',
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _totalAmountCtrl,
                                      labelText: 'Montant Total (Optionnel)',
                                      prefixText: '\$',
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (double.tryParse(value) == null) {
                                            return 'Montant invalide';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _amountPaidCtrl,
                                      labelText: 'Montant Payé (Optionnel)',
                                      prefixText: '\$',
                                      prefixIcon: const Icon(Icons.payments),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      enabled:
                                          !_isPaid, // Disable if fully paid is checked
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final paid = double.tryParse(value);
                                          final total = double.tryParse(
                                            _totalAmountCtrl.text,
                                          );
                                          if (paid == null) {
                                            return 'Montant invalide';
                                          }
                                          if (total != null && paid > total) {
                                            return 'Ne peut dépasser le total';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _isPaid,
                                      onChanged: (value) {
                                        setState(() {
                                          _isPaid = value ?? false;
                                          if (_isPaid) {
                                            if (_totalAmountCtrl
                                                .text
                                                .isNotEmpty) {
                                              _amountPaidCtrl.text =
                                                  _totalAmountCtrl.text;
                                            }
                                          } else {
                                            _amountPaidCtrl.clear();
                                          }
                                        });
                                      },
                                      activeColor: Colors.teal,
                                      checkColor: Colors.white,
                                    ),
                                    Text(
                                      'Payé entièrement',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
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
        ],
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
