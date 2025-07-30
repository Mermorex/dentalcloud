// lib/widgets/patient_search_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart'; // Make sure your Patient model is imported
import '../providers/patient_provider.dart';

class PatientSearchSheet extends StatefulWidget {
  // isDialog is no longer strictly necessary since it's always used in a Dialog now,
  // but keeping it doesn't harm and could be useful for future conditional UI.
  final bool isDialog;
  const PatientSearchSheet({super.key, this.isDialog = false});

  @override
  State<PatientSearchSheet> createState() => _PatientSearchSheetState();
}

class _PatientSearchSheetState extends State<PatientSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Patient> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    // Initialize with all patients
    _filteredPatients = Provider.of<PatientProvider>(
      context,
      listen: false,
    ).patients;
  }

  void _filterPatients(String query) {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = patientProvider.patients;
      } else {
        _filteredPatients = patientProvider.patients
            .where(
              (patient) =>
                  patient.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Reused from AddAppointmentScreen for consistent design
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

  // Reused and adapted from AddAppointmentScreen for consistent design
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged, // Added onChanged parameter
    bool readOnly = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? hintText,
    TextInputAction textInputAction = TextInputAction.next,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(vertical: 10.0),
  }) {
    return Padding(
      padding: padding!,
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
        onChanged: onChanged, // Passed the onChanged parameter to TextFormField
        readOnly: readOnly,
        textInputAction: textInputAction,
      ),
    );
  }

  // Modified _buildSection to include card-like styling, consistent with AddAppointmentScreen
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

    return Container(
      width: isTablet ? 600 : MediaQuery.of(context).size.width * 0.9,
      height: isTablet ? 600 : MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Consistent background color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 80,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                'Sélectionner un patient',
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
                  Icons.close,
                  color: Colors.teal.shade600,
                  size: isTablet ? 32 : 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fermer',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    title: 'Rechercher un patient',
                    children: [
                      _buildTextField(
                        controller: _searchCtrl,
                        labelText: 'Nom du patient',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: _filterPatients,
                        padding: const EdgeInsets.only(bottom: 0.0),
                      ),
                    ],
                  ),
                  _filteredPatients.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              'Aucun patient trouvé.',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0.0,
                                vertical: 8.0,
                              ),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                title: Text(
                                  patient.name,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, patient);
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
