// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// --- IMPORT THE NEW WIDGET ---
import '../widgets/disconnect_button.dart'; // Import the new reusable component
import '../providers/patient_provider.dart';
import '../models/appointment.dart';
import '../models/patient.dart'; // Import Patient model
import '../screens/patient_detail_screen.dart'; // Import PatientDetailScreen
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  // --- ADD THE CALLBACK PARAMETER ---
  /// Callback function triggered when the user requests disconnection.
  /// This should typically be provided by the parent screen (e.g., HomeScreen)
  /// which handles the actual logout logic.
  final VoidCallback? onDisconnect;

  const DashboardScreen({super.key, this.onDisconnect}); // Accept the callback

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, String> _statusTranslations = const {
    'Scheduled': 'Programmé',
    'Completed': 'Terminé',
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PatientProvider>(context, listen: false);
      provider.loadAppointments();
    });
  }

  // --- REMOVE THE OLD _handleDisconnect METHOD ---
  /*
  void _handleDisconnect() async {
    print('User disconnected!');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Déconnexion réussie!')));
    Navigator.of(context).pushReplacementNamed('/login');
  }
  */
  // --- END REMOVE ---

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final List<Appointment> allAppointments = patientProvider.appointments;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat(
      'dd MMMM yyyy',
      'fr_FR',
    ).format(now);
    final String formattedTime = DateFormat('HH:mm').format(now);
    final String todayDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final String? currentCabinetName = patientProvider.currentCabinetName;
    final String? currentCabinetCode = patientProvider.currentCabinetCode;

    String welcomeMessage;
    if (currentCabinetName != null && currentCabinetName.isNotEmpty) {
      welcomeMessage = 'Bienvenue au cabinet "$currentCabinetName"';
    } else if (currentCabinetCode != null) {
      welcomeMessage = 'Bienvenue au cabinet "$currentCabinetCode"';
    } else {
      welcomeMessage = 'Tableau de bord';
    }

    final List<Appointment> todayAppointments = allAppointments.where((
      appointment,
    ) {
      return appointment.date == todayDate;
    }).toList()..sort((a, b) => a.time.compareTo(b.time));

    final List<Appointment> thisWeekAppointments =
        allAppointments.where((appointment) {
          final DateTime appointmentDate = DateTime.parse(appointment.date);
          return appointmentDate.isAfter(
                now.subtract(const Duration(days: 1)),
              ) &&
              appointmentDate.isBefore(now.add(const Duration(days: 7)));
        }).toList()..sort((a, b) {
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) {
            return dateComparison;
          }
          return a.time.compareTo(b.time);
        });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Welcome Message - Improved Responsiveness
              Padding(
                padding: EdgeInsets.only(
                  bottom: isTablet ? 24.0 : 16.0,
                  top: isTablet ? 10.0 : 0.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Decide whether to show the disconnect button based on width or always on tablet
                    final bool showDisconnectButton =
                        isTablet ||
                        constraints.maxWidth > 350; // Adjusted threshold
                    // Prepare the name/code to display
                    String? displayCabinetInfo;
                    if (currentCabinetName != null &&
                        currentCabinetName.isNotEmpty) {
                      displayCabinetInfo =
                          currentCabinetName; // Show only the name
                    } else if (currentCabinetCode != null &&
                        currentCabinetCode.isNotEmpty) {
                      displayCabinetInfo =
                          currentCabinetCode; // Show only the code
                      // If you prefer to keep 'au cabinet' for the code, you could do:
                      // displayCabinetInfo = 'au cabinet "$currentCabinetCode"';
                    }
                    // If neither name nor code is available, displayCabinetInfo remains null
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Welcome message area
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Use FittedBox to keep everything on one line and scale down if needed
                              FittedBox(
                                fit: BoxFit
                                    .scaleDown, // Scale down only, don't distort
                                alignment: Alignment
                                    .centerLeft, // Align text to the left
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .baseline, // Align text baselines
                                  textBaseline: TextBaseline
                                      .alphabetic, // Required for Baseline
                                  mainAxisSize: MainAxisSize
                                      .min, // Take only as much space as needed
                                  children: [
                                    // Static "Bienvenue" part
                                    Text(
                                      'Bienvenue au ', // Note the space at the end
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 28 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                    // Dynamic cabinet name/code part (only if available)
                                    if (displayCabinetInfo != null &&
                                        displayCabinetInfo.isNotEmpty)
                                      Text(
                                        displayCabinetInfo,
                                        style: GoogleFonts.montserrat(
                                          fontSize: isTablet ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade800,
                                          // Optional: Slightly different style for the name
                                          // fontStyle: FontStyle.italic,
                                          // decoration: TextDecoration.underline,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Optional: Keep the subtitle, or make it conditional too
                              if (displayCabinetInfo != null &&
                                  displayCabinetInfo.isNotEmpty)
                                Text(
                                  'Gestion des patients et rendez-vous',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Prevent subtitle overflow too
                                ),
                            ],
                          ),
                        ),
                        // Conditional spacing and elements
                        if (showDisconnectButton) ...[
                          const Spacer(), // Pushes subsequent widgets to the right
                          // --- REPLACE THE OLD ICONBUTTON ---
                          DisconnectButton(
                            onPressed:
                                widget.onDisconnect ??
                                () {
                                  // Fallback if onDisconnect wasn't provided correctly
                                  print(
                                    "DashboardScreen: Disconnect callback not provided or null.",
                                  );
                                  // Optionally show an error or navigate anyway
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur: Déconnexion non configurée correctement.',
                                      ),
                                    ),
                                  );
                                  // You might still want to navigate to login as a fallback
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                            isTablet: isTablet, // Pass screen size info
                            isInAppBar:
                                true, // Indicate it's in the header/app bar area
                          ),
                          // --- END REPLACE ---
                          SizedBox(width: isTablet ? 12 : 8),
                        ] else
                          SizedBox(
                            width: isTablet ? 12 : 8,
                          ), // Small space if button hidden
                        Image.asset(
                          'assets/images/tooth_logo.png',
                          width: isTablet ? 48 : 36,
                          height: isTablet ? 48 : 36,
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Current Date and Time Display
              Container(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aujourd\'hui',
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.teal.shade600,
                          size: isTablet ? 30 : 24,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          formattedDate,
                          style: GoogleFonts.montserrat(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.teal.shade600,
                          size: isTablet ? 30 : 24,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          formattedTime,
                          style: GoogleFonts.montserrat(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 35 : 25),
              // Highlighted "Rendez-vous d'aujourd'hui"
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 14 : 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.teal.shade200, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rendez-vous d'aujourd'hui",
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        todayAppointments.length.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              todayAppointments.isEmpty
                  ? _buildEmptyAppointmentState(
                      'Aucun rendez-vous prévu pour aujourd\'hui.',
                      isTablet,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = todayAppointments[index];
                        final patientName = patientProvider.getPatientNameById(
                          appointment.patientId,
                        );
                        return AppointmentCard(
                          appointment: appointment,
                          patientName: patientName,
                          statusTranslations: _statusTranslations,
                          isImportant: true,
                          isTablet: isTablet,
                          // Add the onTap callback for navigation
                          onTap: () async {
                            try {
                              final patient = patientProvider.patients
                                  .firstWhere(
                                    (p) => p.id == appointment.patientId,
                                  );
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatientDetailScreen(patient: patient),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur: Patient non trouvé.',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
              SizedBox(height: isTablet ? 35 : 25),
              // Highlighted "Rendez-vous de cette semaine"
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 14 : 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.teal.shade200, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rendez-vous de cette semaine",
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        thisWeekAppointments.length.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              thisWeekAppointments.isEmpty
                  ? _buildEmptyAppointmentState(
                      'Aucun rendez-vous prévu pour cette semaine.',
                      isTablet,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: thisWeekAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = thisWeekAppointments[index];
                        final patientName = patientProvider.getPatientNameById(
                          appointment.patientId,
                        );
                        return AppointmentCard(
                          appointment: appointment,
                          patientName: patientName,
                          statusTranslations: _statusTranslations,
                          isImportant: false,
                          isTablet: isTablet,
                          // Add the onTap callback for navigation
                          onTap: () async {
                            try {
                              final patient = patientProvider.patients
                                  .firstWhere(
                                    (p) => p.id == appointment.patientId,
                                  );
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatientDetailScreen(patient: patient),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erreur: Patient non trouvé.',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentState(String message, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: isTablet ? 80 : 60,
              color: Colors.teal.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// The AppointmentCard class remains mostly the same, with the addition of the onTap parameter
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final Map<String, String> statusTranslations;
  final bool isImportant;
  final bool isTablet;
  final VoidCallback? onTap; // Add the onTap callback
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
    required this.statusTranslations,
    this.isImportant = false,
    required this.isTablet,
    this.onTap, // Include it in the constructor
  });

  String _getTranslatedStatus(String status) {
    return statusTranslations[status] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade700;
      case 'Completed':
        return Colors.green.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      case 'No Show':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getLightStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade50;
      case 'Completed':
        return Colors.green.shade50;
      case 'Cancelled':
        return Colors.red.shade50;
      case 'No Show':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getCardBorderColor(String status, bool isImportant) {
    if (isImportant) {
      return Colors.red.shade400;
    }
    switch (status) {
      case 'Scheduled':
        return Colors.blue.shade200;
      case 'Completed':
        return Colors.green.shade200;
      case 'Cancelled':
        return Colors.red.shade200;
      case 'No Show':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(appointment.status);
    final Color lightStatusColor = _getLightStatusColor(appointment.status);
    final Color cardBackgroundColor = isImportant
        ? Colors.red.shade50
        : Colors.white;
    final Color cardBorderColor = _getCardBorderColor(
      appointment.status,
      isImportant,
    );
    final Color patientNameColor = isImportant
        ? Colors.red.shade800
        : Colors.grey.shade800;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cardBorderColor, width: 1.5),
      ),
      // Wrap the main content with InkWell for tap handling
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback
        borderRadius: BorderRadius.circular(20), // Match card border radius
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      patientName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 22 : 20,
                        color: patientNameColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Icon(
                    Icons.access_time,
                    size: isTablet ? 24 : 20,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    appointment.time,
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 19 : 17,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 10 : 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isTablet ? 18 : 16,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(appointment.date))}',
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (appointment.notes.isNotEmpty) ...[
                SizedBox(height: isTablet ? 10 : 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: isTablet ? 18 : 16,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Expanded(
                      child: Text(
                        'Notes: ${appointment.notes}',
                        style: GoogleFonts.montserrat(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: isTablet ? 15 : 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 7 : 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Statut: ${_getTranslatedStatus(appointment.status)}',
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor.darken(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ColorManipulation on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
