// lib/screens/edit_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../models/appointment.dart';
import '../providers/patient_provider.dart';
import '../widgets/main_button.dart';

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
  late TextEditingController _nextVisitTimeCtrl;
  bool _isPaid = false;
  late TextEditingController _amountPaidCtrl;
  late TextEditingController _totalAmountCtrl;

  // Track original values for appointment logic
  String? _originalNextVisitDate;
  String? _originalNextVisitTime;

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
    _nextVisitTimeCtrl = TextEditingController();

    _isPaid = widget.visit.isPaid;
    _amountPaidCtrl = TextEditingController(
      text: widget.visit.amountPaid?.toStringAsFixed(3) ?? '',
    );
    _totalAmountCtrl = TextEditingController(
      text: widget.visit.totalAmount?.toStringAsFixed(3) ?? '',
    );

    _originalNextVisitDate = widget.visit.nextVisitDate;

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
    final appointments = patientProvider.appointments
        .where(
          (appt) =>
              appt.patientId == widget.patientId &&
              appt.date == widget.visit.nextVisitDate &&
              appt.notes == 'Prochaine visite (auto-générée)',
        )
        .toList();

    if (appointments.isNotEmpty) {
      setState(() {
        _nextVisitTimeCtrl.text = appointments.first.time;
        _originalNextVisitTime = _nextVisitTimeCtrl.text;
      });
    } else {
      setState(() {
        _nextVisitTimeCtrl.text = '09:00 AM';
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

      // --- Appointment Management ---
      final currentNextVisitDate = _nextVisitDateCtrl.text;
      final currentNextVisitTime = _nextVisitTimeCtrl.text.isNotEmpty
          ? _nextVisitTimeCtrl.text
          : '09:00 AM';
      final bool dateChanged =
          _originalNextVisitDate != currentNextVisitDate ||
          _originalNextVisitTime != currentNextVisitTime;
      final bool wasScheduled =
          _originalNextVisitDate != null && _originalNextVisitDate!.isNotEmpty;
      final bool isNowScheduled = currentNextVisitDate.isNotEmpty;

      if (wasScheduled && (!isNowScheduled || dateChanged)) {
        final oldAppointments = patientProvider.appointments
            .where(
              (appt) =>
                  appt.patientId == widget.patientId &&
                  appt.date == _originalNextVisitDate &&
                  appt.time == _originalNextVisitTime &&
                  appt.notes == 'Prochaine visite (auto-générée)',
            )
            .toList();
        for (var appt in oldAppointments) {
          await patientProvider.deleteAppointment(appt.id!);
          break;
        }
      }

      if (isNowScheduled && (!wasScheduled || dateChanged)) {
        final newAppointment = Appointment(
          patientId: widget.patientId,
          date: currentNextVisitDate,
          time: currentNextVisitTime,
          notes: 'Prochaine visite (auto-générée)',
          status: 'Scheduled',
        );
        await patientProvider.addAppointment(newAppointment);
      }
      // --- End Appointment Management ---

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
          'Modifier la Visite',
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
                        title: 'Détails de la Visite',
                        children: [
                          _buildTextField(
                            controller: _dateCtrl,
                            labelText: 'Date de la visite',
                            prefixIcon: const Icon(Icons.calendar_today),
                            readOnly: true,
                            onTap: () => _selectDate(_dateCtrl),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez entrer une date';
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _timeCtrl,
                            labelText: 'Heure de la visite',
                            prefixIcon: const Icon(Icons.access_time),
                            readOnly: true,
                            onTap: () => _selectTime(_timeCtrl),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Veuillez entrer une heure';
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _purposeCtrl,
                            labelText: 'Motif',
                            prefixIcon: const Icon(Icons.description),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _findingsCtrl,
                            labelText: 'Constatations',
                            prefixIcon: const Icon(Icons.search),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _treatmentCtrl,
                            labelText: 'Traitement',
                            prefixIcon: const Icon(Icons.healing),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _notesCtrl,
                            labelText: 'Notes',
                            prefixIcon: const Icon(Icons.note),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _nextVisitDateCtrl,
                            labelText:
                                'Date de la Prochaine Visite (Optionnel)',
                            prefixIcon: const Icon(Icons.event_available),
                            readOnly: true,
                            onTap: () => _selectDate(_nextVisitDateCtrl),
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _nextVisitTimeCtrl,
                            labelText:
                                'Heure de la Prochaine Visite (Optionnel)',
                            prefixIcon: const Icon(Icons.access_time),
                            readOnly: true,
                            onTap: () => _selectTime(_nextVisitTimeCtrl),
                            textInputAction: TextInputAction.done,
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
                                  prefixText: 'DT ',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        double.tryParse(value) == null) {
                                      return 'Montant invalide';
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
                                  prefixText: 'DT ',
                                  prefixIcon: const Icon(Icons.payments),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  enabled: !_isPaid,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final paid = double.tryParse(value);
                                      final total = double.tryParse(
                                        _totalAmountCtrl.text,
                                      );
                                      if (paid == null)
                                        return 'Montant invalide';
                                      if (total != null && paid > total)
                                        return 'Ne peut dépasser le total';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payé entièrement',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.teal,
                                  ),
                                ),
                                Switch(
                                  value: _isPaid,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPaid = value;
                                      if (_isPaid &&
                                          _totalAmountCtrl.text.isNotEmpty) {
                                        _amountPaidCtrl.text =
                                            _totalAmountCtrl.text;
                                      } else if (!_isPaid) {
                                        _amountPaidCtrl.clear();
                                      }
                                    });
                                  },
                                  activeColor: Colors.teal,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey.shade300,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MainButton(
        onPressed: _saveChanges,
        label: 'Enregistrer les modifications',
        icon: Icons.save,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        heroTag: 'editVisitSaveButton',
      ),
    );
  }
}
