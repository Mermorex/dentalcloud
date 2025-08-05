// lib/widgets/patient_search_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';

class PatientSearchSheet extends StatefulWidget {
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

  // --- Updated _buildSectionHeader for modern look ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 22, // Slightly smaller
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }

  // --- Updated _buildTextField for modern look and consistency ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
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
        style: GoogleFonts.montserrat(fontSize: 16), // Slightly smaller font
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(fontSize: 16),
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              12.0,
            ), // Slightly smaller radius
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ), // Thinner border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Colors.teal,
              width: 2.0,
            ), // Thinner focused border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0, // Slightly less padding
            horizontal: 16.0,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: 24.0, // Slightly smaller icon
                    height: 24.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: IconTheme(
                        data: IconThemeData(
                          size: 24.0,
                          color: Colors.teal.shade700,
                        ),
                        child: prefixIcon,
                      ),
                    ),
                  ),
                )
              : null,
          // Error styling (if needed)
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
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
        onChanged: onChanged,
        readOnly: readOnly,
        textInputAction: textInputAction,
      ),
    );
  }

  // --- Updated _buildSection for modern card look with shadow ---
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
            borderRadius: BorderRadius.circular(16), // Slightly smaller radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Softer shadow
                blurRadius: 8, // Less blur
                offset: const Offset(0, 2), // Smaller offset
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0), // Slightly less padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
  // --- END Updates ---

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: isTablet
          ? 600
          : MediaQuery.of(context).size.width * 0.95, // Wider on mobile
      height: isTablet
          ? 600
          : MediaQuery.of(context).size.height * 0.75, // Taller on mobile
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(25),
        ), // More rounded top corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Updated AppBar for modern look ---
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0, // No shadow
            toolbarHeight: 70, // Slightly shorter
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ), // Match container radius
            ),
            title: Text(
              'Sélectionner un patient',
              style: GoogleFonts.montserrat(
                fontSize:
                    (isTablet ? 28 : 22) *
                    textScaleFactor, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            centerTitle: true, // Center the title
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.teal.shade600,
                  size: isTablet ? 30 : 26, // Adjusted icon size
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fermer',
              ),
            ),
          ),
          // --- END Updated AppBar ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ), // Adjusted padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSection(
                    title: 'Rechercher un patient',
                    children: [
                      _buildTextField(
                        controller: _searchCtrl,
                        labelText: 'Nom du patient',
                        hintText: 'Commencez à taper un nom...', // Added hint
                        prefixIcon: const Icon(Icons.search),
                        onChanged: _filterPatients,
                        padding: const EdgeInsets.only(bottom: 0.0),
                      ),
                    ],
                  ),
                  if (_filteredPatients.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40.0,
                        ), // More vertical space
                        child: Column(
                          // Use Column for icon + text
                          children: [
                            Icon(
                              Icons
                                  .person_search_outlined, // More relevant icon
                              size: 60, // Large icon
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun patient trouvé.',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w500, // Slightly bolder
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = _filteredPatients[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0.0,
                            vertical: 6.0, // Reduced vertical margin
                          ),
                          elevation: 1, // Lower elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12.0,
                            ), // Consistent radius
                          ),
                          child: ListTile(
                            // --- Modernized ListTile ---
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ), // Adjusted padding
                            leading: CircleAvatar(
                              radius: 22, // Slightly smaller avatar
                              backgroundColor:
                                  Colors.teal.shade50, // Lighter background
                              child: Icon(
                                Icons.person,
                                color: Colors.teal.shade700,
                                size: 24, // Adjusted icon size
                              ),
                            ),
                            title: Text(
                              patient.name,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, // Slightly bolder
                                fontSize: 17, // Slightly larger
                                color: Colors.teal.shade900, // Darker text
                              ),
                              overflow:
                                  TextOverflow.ellipsis, // Handle long names
                            ),
                            // Optional: Add patient phone or other info
                            // subtitle: Text(
                            //   patient.phone ?? 'Pas de téléphone',
                            //   style: GoogleFonts.montserrat(
                            //     fontSize: 14,
                            //     color: Colors.grey.shade600,
                            //   ),
                            // ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.teal.shade600,
                              size: 18, // Smaller trailing icon
                            ),
                            onTap: () {
                              Navigator.pop(context, patient);
                            },
                            // --- END Modernized ListTile ---
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
