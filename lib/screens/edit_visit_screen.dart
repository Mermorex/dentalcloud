// lib/screens/edit_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../widgets/main_button.dart';
import '../models/appointment.dart'; // Import the Appointment model if needed for updates

class EditVisitScreen extends StatefulWidget {
  final Visit visit; // Receive the Visit object to edit
  final String patientId; // Receive the patientId (passed from VisitCard)

  const EditVisitScreen({
    super.key,
    required this.visit,
    required this.patientId, // Mark as required
  });

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers initialized with data from the passed Visit object
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _findingsCtrl;
  late final TextEditingController _treatmentCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _nextVisitDateCtrl;
  late final TextEditingController _nextVisitTimeCtrl;
  late bool _isPaid;
  late final TextEditingController _amountPaidCtrl;
  late final TextEditingController _totalAmountCtrl;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with data from widget.visit
    _dateCtrl = TextEditingController(text: widget.visit.date);
    _timeCtrl = TextEditingController(text: widget.visit.time);
    _purposeCtrl = TextEditingController(text: widget.visit.purpose);
    _findingsCtrl = TextEditingController(text: widget.visit.findings);
    _treatmentCtrl = TextEditingController(text: widget.visit.treatment);
    _notesCtrl = TextEditingController(text: widget.visit.notes);
    _nextVisitDateCtrl = TextEditingController(
      text: widget.visit.nextVisitDate ?? '',
    );
    // Assuming nextVisitTime isn't in the Visit model, default to empty or extract if exists
    _nextVisitTimeCtrl = TextEditingController(); // Initialize as empty for now

    // Handle payment fields
    _isPaid = widget.visit.isPaid ?? false;
    _amountPaidCtrl = TextEditingController(
      text: widget.visit.amountPaid?.toString() ?? '',
    );
    _totalAmountCtrl = TextEditingController(
      text: widget.visit.totalAmount?.toString() ?? '',
    );
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

  void _updateVisit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare updated visit data
      final updatedVisit = Visit(
        id: widget.visit.id, // Keep the original ID
        patientId: widget.patientId, // Use the passed patientId
        date: _dateCtrl.text,
        time: _timeCtrl.text,
        purpose: _purposeCtrl.text,
        findings: _findingsCtrl.text,
        treatment: _treatmentCtrl.text,
        notes: _notesCtrl.text,
        nextVisitDate: _nextVisitDateCtrl.text.isEmpty
            ? null
            : _nextVisitDateCtrl.text,
        // nextVisitTime: _nextVisitTimeCtrl.text.isEmpty ? null : _nextVisitTimeCtrl.text, // Add if needed
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
            'Mise à jour de la visite...',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 1),
        ),
      );

      try {
        await patientProvider.updateVisit(updatedVisit);
        // Optionally, handle appointment updates if next visit date/time changes significantly
        // This is simplified; you might need more logic to update/delete existing appointments
        // if (updatedVisit.nextVisitDate != null && updatedVisit.nextVisitDate!.isNotEmpty) {
        //   // Logic to update or add appointment
        // }

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
          // Pop and potentially pass a result back if needed by the caller
          Navigator.of(context).pop(true); // Indicate successful update
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de la mise à jour: $e',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // --- Reuse _buildTextField, _buildSectionHeader, _buildSection from add_visit_screen.dart ---
  // For brevity, I'll define minimal versions here. You can copy the full methods from add_visit_screen.dart
  // if you want identical styling.

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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.montserrat(fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(fontSize: 16),
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500),
          prefixText: prefixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconTheme(
                    data: IconThemeData(color: Colors.teal.shade700),
                    child: prefixIcon,
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
        enabled: enabled,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
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
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
  // --- End of reused methods ---

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
                          // Display current date/time (non-editable for simplicity)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.teal.shade700,
                                          size: 24.0,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          _dateCtrl.text,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.teal.shade700,
                                          size: 24.0,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          _timeCtrl.text,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildTextField(
                            controller: _purposeCtrl,
                            labelText: 'Motif',
                            prefixIcon: const Icon(Icons.description),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          _buildTextField(
                            controller: _findingsCtrl,
                            labelText: 'Constatations',
                            prefixIcon: const Icon(Icons.search),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          _buildTextField(
                            controller: _treatmentCtrl,
                            labelText: 'Traitement',
                            prefixIcon: const Icon(Icons.healing),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          _buildTextField(
                            controller: _notesCtrl,
                            labelText: 'Notes',
                            prefixIcon: const Icon(Icons.note),
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                          ),
                          _buildTextField(
                            controller: _nextVisitDateCtrl,
                            labelText:
                                'Date de la Prochaine Visite (Optionnel)',
                            prefixIcon: const Icon(Icons.event_available),
                            readOnly: true, // Make read-only or add date picker
                          ),
                          _buildTextField(
                            controller: _nextVisitTimeCtrl,
                            labelText:
                                'Heure de la Prochaine Visite (Optionnel)',
                            prefixIcon: const Icon(Icons.access_time),
                            readOnly: true, // Make read-only or add time picker
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
                              const SizedBox(width: 12),
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
                                      if (_isPaid) {
                                        if (_totalAmountCtrl.text.isNotEmpty) {
                                          _amountPaidCtrl.text =
                                              _totalAmountCtrl.text;
                                        }
                                      } else {
                                        _amountPaidCtrl.clear();
                                      }
                                    });
                                  },
                                  activeColor: Colors.teal,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Align the save button to the right
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: isTablet ? 300 : 250,
                          child: MainButton(
                            onPressed: _updateVisit,
                            label: 'Mettre à jour la visite',
                            icon: Icons.save,
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
    );
  }
}
