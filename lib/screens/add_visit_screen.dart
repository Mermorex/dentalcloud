// lib/screens/add_visit_screen.dart
import 'package:dental/db/document_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart'; // Import file_picker - REMOVED
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../widgets/main_button.dart';
import '../models/appointment.dart';
import '../widgets/visit_date_time_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase for auth check if needed in UI

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
  // --- REMOVED: State for handling attached files ---
  // List<PlatformFile> _selectedFiles = [];
  // bool _isUploadingFiles = false; // Optional: to show upload state
  // final DocumentService _documentService = DocumentService(); // Initialize service
  // --- END OF REMOVED ---

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
    // --- REMOVED: Disposal of file picker related state ---
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

  // --- REMOVED: Function to pick files ---
  // Future<void> _pickFiles() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       allowMultiple: true, // Allow selecting multiple files
  //       type: FileType
  //           .any, // Or restrict to specific types like FileType.image, FileType.custom
  //       // allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'], // Example for custom types
  //     );
  //     if (result != null) {
  //       setState(() {
  //         _selectedFiles = result.files; // Update state with selected files
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur lors de la sélection des fichiers: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
  // --- END OF REMOVED ---

  // --- REMOVED: Function to remove a selected file ---
  // void _removeSelectedFile(int index) {
  //   setState(() {
  //     _selectedFiles.removeAt(index);
  //   });
  // }
  // --- END OF REMOVED ---

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

      // --- MODIFIED: Show initial saving snackbar ---
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

      try {
        // --- REMOVED: Getting cabinetId for document upload ---
        // final String? cabinetId = patientProvider.currentCabinetId;
        // if (cabinetId == null) {
        //   throw Exception("Impossible de déterminer le cabinet pour le téléchargement du document.");
        // }

        // Add the visit
        await patientProvider.addVisit(newVisit);

        // --- REMOVED: Upload selected files after visit is created ---
        // if (_selectedFiles.isNotEmpty) {
        //   setState(() {
        //     _isUploadingFiles = true; // Optional: Update UI state
        //   });
        //   // Show uploading files snackbar
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous snackbar
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text(
        //           'Téléchargement des documents...',
        //           style: GoogleFonts.montserrat(color: Colors.white),
        //         ),
        //         backgroundColor: Colors.blue,
        //         duration: const Duration(seconds: 2), // Adjust duration as needed
        //       ),
        //     );
        //   }
        //   List<Future<void>> uploadFutures = [];
        //   for (var file in _selectedFiles) {
        //     // Assuming DocumentService handles errors internally or throws
        //     uploadFutures.add(
        //       _documentService.uploadDocument(
        //         patientId: widget.patientId,
        //         cabinetId: cabinetId, // Pass the cabinetId
        //         file: file,
        //         description: 'Document attaché à la visite du ${newVisit.date}', // Optional description
        //         category: 'VisitAttachment', // Optional category
        //       ),
        //     );
        //   }
        //   // Wait for all uploads to complete
        //   await Future.wait(uploadFutures);
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text(
        //           'Documents téléchargés avec succès !',
        //           style: GoogleFonts.montserrat(color: Colors.white),
        //         ),
        //         backgroundColor: Colors.blue,
        //         duration: const Duration(seconds: 2),
        //       ),
        //     );
        //   }
        // }
        // --- END OF REMOVED ---

        // Handle next appointment creation
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
          // Show final success snackbar
          ScaffoldMessenger.of(
            context,
          ).hideCurrentSnackBar(); // Hide previous snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Visite ajoutée avec succès !', // Updated message
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(); // Navigate back
        }
      } catch (e) {
        // Handle errors during visit creation or file upload
        if (mounted) {
          // --- REMOVED: Resetting upload UI state on error ---
          // setState(() {
          //   _isUploadingFiles = false; // Reset UI state on error
          // });
          // --- END OF REMOVED ---
          ScaffoldMessenger.of(
            context,
          ).hideCurrentSnackBar(); // Hide previous snackbar
          print("AddVisitScreen: Error saving visit or uploading files: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de l\'ajout: $e',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        // Ensure UI state is reset even if an error occurs
        if (mounted) {
          // --- REMOVED: Resetting upload UI state in finally block ---
          // setState(() {
          //   _isUploadingFiles = false;
          // });
          // --- END OF REMOVED ---
        }
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

  // --- REMOVED: Widget to display selected files ---
  // Widget _buildSelectedFilesList() {
  //   if (_selectedFiles.isEmpty) return const SizedBox.shrink();
  //   return Container(
  //     margin: const EdgeInsets.only(top: 10.0),
  //     padding: const EdgeInsets.all(10.0),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(10.0),
  //       color: Colors.grey.shade50,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Fichiers sélectionnés (${_selectedFiles.length}):',
  //           style: GoogleFonts.montserrat(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 16,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         ..._selectedFiles.asMap().entries.map((entry) {
  //           int idx = entry.key;
  //           PlatformFile file = entry.value;
  //           return Dismissible(
  //             key: Key(file.path ?? file.name + idx.toString()), // Unique key
  //             direction: DismissDirection.endToStart,
  //             background: Container(
  //               alignment: Alignment.centerRight,
  //               padding: const EdgeInsets.only(right: 20),
  //               color: Colors.red,
  //               child: const Icon(Icons.delete, color: Colors.white),
  //             ),
  //             onDismissed: (_) => _removeSelectedFile(idx),
  //             child: ListTile(
  //               leading: Icon(
  //                 _getIconForFile(file.extension),
  //                 color: Colors.teal.shade700,
  //               ),
  //               title: Text(
  //                 file.name,
  //                 style: GoogleFonts.montserrat(fontSize: 14),
  //                 overflow: TextOverflow.ellipsis, // Handle long names
  //               ),
  //               subtitle: Text(
  //                 '${(file.size / 1024).toStringAsFixed(1)} KB',
  //                 style: GoogleFonts.montserrat(
  //                   fontSize: 12,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //               trailing: IconButton(
  //                 icon: const Icon(Icons.close, color: Colors.red),
  //                 onPressed: () => _removeSelectedFile(idx),
  //                 tooltip: 'Supprimer',
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 8.0,
  //                 vertical: 2.0,
  //               ),
  //               dense: true, // Make list tile more compact
  //             ),
  //           );
  //         }).toList(),
  //       ],
  //     ),
  //   );
  // }
  // --- END OF REMOVED ---

  // --- REMOVED: Helper to get icon based on file extension ---
  // IconData _getIconForFile(String? extension) {
  //   switch (extension?.toLowerCase()) {
  //     case 'pdf':
  //       return Icons.picture_as_pdf;
  //     case 'jpg':
  //     case 'jpeg':
  //     case 'png':
  //     case 'gif':
  //       return Icons.image;
  //     case 'doc':
  //     case 'docx':
  //       return Icons.description;
  //     default:
  //       return Icons.insert_drive_file; // Default file icon
  //   }
  // }
  // --- END OF REMOVED ---

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
                            // --- REMOVED: Section for attaching files ---
                            // const SizedBox(height: 20),
                            // _buildSectionHeader('Documents'),
                            // Container(
                            //   margin: const EdgeInsets.only(bottom: 20.0),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(20),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.black.withOpacity(0.04),
                            //         blurRadius: 12,
                            //         offset: const Offset(0, 4),
                            //       ),
                            //     ],
                            //   ),
                            //   padding: const EdgeInsets.all(20.0),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.stretch,
                            //     children: [
                            //       ElevatedButton.icon(
                            //         onPressed: _isUploadingFiles
                            //             ? null
                            //             : _pickFiles, // Disable while uploading
                            //         icon: const Icon(Icons.attach_file),
                            //         label: Text(
                            //           _isUploadingFiles
                            //               ? 'Téléchargement...'
                            //               : 'Joindre des fichiers',
                            //           style: GoogleFonts.montserrat(
                            //             fontSize: 16,
                            //             fontWeight: FontWeight.w600,
                            //           ),
                            //         ),
                            //         style: ElevatedButton.styleFrom(
                            //           backgroundColor: Colors.teal.shade50,
                            //           foregroundColor: Colors.teal.shade700,
                            //           padding: const EdgeInsets.symmetric(
                            //             vertical: 15,
                            //           ),
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(15),
                            //           ),
                            //           elevation: 0,
                            //           side: BorderSide(
                            //             color: Colors.teal.shade200,
                            //           ),
                            //         ),
                            //       ),
                            //       if (_isUploadingFiles)
                            //         const Padding(
                            //           padding: EdgeInsets.all(8.0),
                            //           child: LinearProgressIndicator(
                            //             color: Colors.teal,
                            //             backgroundColor: Colors.grey,
                            //           ),
                            //         ),
                            //       _buildSelectedFilesList(), // Display selected files
                            //     ],
                            //   ),
                            // ),
                            // --- END OF REMOVED ---
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
