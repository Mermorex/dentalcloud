// lib/screens/add_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../widgets/main_button.dart';
import '../models/appointment.dart';
import '../widgets/visit_date_time_info.dart'; // ✅ Import the new widget

class AddVisitScreen extends StatefulWidget {
  final String patientId;
  const AddVisitScreen({super.key, required this.patientId});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _nextVisitDateCtrl = TextEditingController();
  final _nextVisitTimeCtrl = TextEditingController();
  bool _isPaid = false;
  final _amountPaidCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _timeCtrl.text = TimeOfDay.now().format(context);
      }
    });
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  void _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_isPaid && _totalAmountCtrl.text.isNotEmpty) {
        _amountPaidCtrl.text = _totalAmountCtrl.text;
      }

      final newVisit = Visit(
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
            'Sauvegarde de la visite...',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 1),
        ),
      );

      await patientProvider.addVisit(newVisit);

      if (_nextVisitDateCtrl.text.isNotEmpty) {
        final newAppointment = Appointment(
          patientId: widget.patientId,
          date: _nextVisitDateCtrl.text,
          time: _nextVisitTimeCtrl.text.isNotEmpty
              ? _nextVisitTimeCtrl.text
              : '09:00 AM',
          notes: 'Prochaine visite (auto-générée)',
          status: 'Scheduled',
        );
        await patientProvider.addAppointment(newAppointment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Visite ajoutée avec succès !',
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Annuler la visite?',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Êtes-vous sûr de vouloir annuler? Les modifications non enregistrées seront perdues.',
                style: GoogleFonts.montserrat(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Non',
                    style: GoogleFonts.montserrat(color: Colors.teal),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    'Oui',
                    style: GoogleFonts.montserrat(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          title: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Text(
              'Ajouter une Nouvelle Visite',
              style: GoogleFonts.montserrat(
                fontSize: (isTablet ? 32 : 24) * textScaleFactor,
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Annuler la visite?',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Êtes-vous sûr de vouloir annuler? Les modifications non enregistrées seront perdues.',
                        style: GoogleFonts.montserrat(),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Non',
                            style: GoogleFonts.montserrat(color: Colors.teal),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text(
                            'Oui',
                            style: GoogleFonts.montserrat(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Retour',
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.teal.shade600,
                  size: isTablet ? 32 : 28,
                ),
                onPressed: _saveVisit,
                tooltip: 'Sauvegarder',
              ),
            ),
          ],
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
                            // ✅ Replaced with shared VisitDateTimeInfo
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: VisitDateTimeInfo(
                                date: _dateCtrl.text,
                                time: _timeCtrl.text,
                                isTablet: isTablet,
                                showTime: true,
                              ),
                            ),
                            // Motif, findings, treatment, notes, etc.
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        } else {
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
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: isTablet ? 300 : 250,
                            child: MainButton(
                              onPressed: _saveVisit,
                              label: 'Ajouter une visite',
                              icon: Icons.add,
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
