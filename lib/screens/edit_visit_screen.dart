// lib/screens/edit_visit_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../widgets/main_button.dart';
import '../widgets/visit_date_time_info.dart'; // ← Import shared widget

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
  late final TextEditingController _purposeCtrl;
  late final TextEditingController _findingsCtrl;
  late final TextEditingController _treatmentCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _nextVisitDateCtrl;
  late final TextEditingController
  _nextVisitTimeCtrl; // Pour l'heure de la prochaine visite (non persistante)
  late bool _isPaid;
  late final TextEditingController _amountPaidCtrl;
  late final TextEditingController _totalAmountCtrl;
  late final String _visitDate;
  late final String _visitTime;

  @override
  void initState() {
    super.initState();
    _visitDate = widget.visit.date;
    _visitTime = widget.visit.time;
    _purposeCtrl = TextEditingController(text: widget.visit.purpose);
    _findingsCtrl = TextEditingController(text: widget.visit.findings);
    _treatmentCtrl = TextEditingController(text: widget.visit.treatment);
    _notesCtrl = TextEditingController(text: widget.visit.notes);
    _nextVisitDateCtrl = TextEditingController(
      text: widget.visit.nextVisitDate ?? '',
    );
    // --- CORRECTION : Initialisation sans valeur persistante ---
    // Comme nextVisitTime n'est pas stocké dans le modèle Visit,
    // le champ reste vide au démarrage, cohérent avec AddVisitScreen.
    _nextVisitTimeCtrl = TextEditingController(); // Reste vide initialement
    // --- FIN DE LA CORRECTION ---
    _isPaid =
        widget.visit.isPaid; // Pas besoin de ?? false si le modèle le garantit
    _amountPaidCtrl = TextEditingController(
      text: widget.visit.amountPaid?.toString() ?? '',
    );
    _totalAmountCtrl = TextEditingController(
      text: widget.visit.totalAmount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    _findingsCtrl.dispose();
    _treatmentCtrl.dispose();
    _notesCtrl.dispose();
    _nextVisitDateCtrl.dispose();
    _nextVisitTimeCtrl.dispose(); // Dispose le contrôleur
    _amountPaidCtrl.dispose();
    _totalAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
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

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
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

  void _updateVisit() async {
    if (_formKey.currentState!.validate()) {
      // --- CORRECTION : Ne pas inclure nextVisitTime dans l'objet Visit mis à jour ---
      // Le modèle Visit actuel ne contient pas ce champ.
      final updatedVisit = Visit(
        id: widget.visit.id,
        patientId: widget.patientId,
        date: _visitDate,
        time: _visitTime,
        purpose: _purposeCtrl.text,
        findings: _findingsCtrl.text,
        treatment: _treatmentCtrl.text,
        notes: _notesCtrl.text,
        nextVisitDate: _nextVisitDateCtrl.text.isEmpty
            ? null
            : _nextVisitDateCtrl.text,
        // nextVisitTime est ignoré ici car il n'est pas dans le modèle Visit
        isPaid: _isPaid,
        amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0.0,
        totalAmount: double.tryParse(_totalAmountCtrl.text) ?? 0.0,
      );
      // --- FIN DE LA CORRECTION ---
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mise à jour...',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 1),
        ),
      );
      try {
        await patientProvider.updateVisit(updatedVisit);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Visite mise à jour !',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur: $e',
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

  // ... (Les méthodes _buildTextField, _buildSectionHeader, _buildSection restent identiques)

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

  @override
  Widget build(BuildContext context) {
    // ... (La méthode build reste identique, sauf pour l'appel à _updateVisit)
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
                          VisitDateTimeInfo(
                            date: _visitDate,
                            time: _visitTime,
                            isTablet: isTablet,
                          ),
                          const SizedBox(height: 16),
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
                            labelText: 'Date de la Prochaine Visite',
                            prefixIcon: const Icon(Icons.event_available),
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, _nextVisitDateCtrl),
                          ),
                          _buildTextField(
                            controller: _nextVisitTimeCtrl,
                            labelText: 'Heure de la Prochaine Visite',
                            prefixIcon: const Icon(Icons.access_time),
                            readOnly: true,
                            onTap: () =>
                                _selectTime(context, _nextVisitTimeCtrl),
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
                                  labelText: 'Montant Total',
                                  prefixText: 'DT ',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _amountPaidCtrl,
                                  labelText: 'Montant Payé',
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: isTablet ? 300 : 250,
                          child: MainButton(
                            onPressed:
                                _updateVisit, // Assurez-vous que c'est la bonne méthode
                            label: 'Mettre à jour',
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
