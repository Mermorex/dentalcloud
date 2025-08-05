// lib/screens/dashboard_screen.dart
// (Subscription flow removed)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// --- IMPORT THE NEW WIDGET ---
import '../widgets/disconnect_button.dart';
import '../providers/patient_provider.dart';
// --- REMOVED SubscriptionProvider import ---
// import '../providers/subscription_provider.dart'; // <-- Removed Import
// --- REMOVED TrialExpiredScreen import ---
// import '../screens/trial_expired_screen.dart'; // <-- Removed Import
// --- OTHER EXISTING IMPORTS ---
import '../models/appointment.dart';
import '../models/patient.dart';
import '../screens/patient_detail_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onDisconnect;
  const DashboardScreen({super.key, this.onDisconnect});

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // <-- Made async
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      // Load appointments as before
      patientProvider.loadAppointments();
      // --- REMOVED SUBSCRIPTION CHECK ---
      // The code that fetched subscription status here is removed.
      // The dashboard will now load without checking subscription status.
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    // --- REMOVED SubscriptionProvider ACCESS ---
    // final subscriptionProvider = Provider.of<SubscriptionProvider>(
    //   context,
    // ); // <-- Removed Access
    // --- REMOVED LOADING, ERROR, and SUBSCRIPTION STATUS CHECKS ---
    // The dashboard will now always show its main content.

    print(
      "DashboardScreen build: Showing main dashboard content (subscription check removed).",
    );

    // --- SHOW MAIN DASHBOARD CONTENT ---
    // The rest of your existing DashboardScreen build method goes here.
    // Wrap the existing content in a Widget (like a Column or Container) for clarity.
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
    final String? currentCabinetId = patientProvider.currentCabinetId;
    String welcomeMessage;
    if (currentCabinetName != null && currentCabinetName.isNotEmpty) {
      welcomeMessage = 'Bienvenue au cabinet "$currentCabinetName"';
    } else if (currentCabinetId != null && currentCabinetId.isNotEmpty) {
      welcomeMessage = 'Bienvenue au cabinet (ID: "$currentCabinetId")';
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

    // Return the main dashboard content
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- YOUR EXISTING DASHBOARD CONTENT WIDGETS GO HERE ---
              // Enhanced Header with Welcome Message
              Padding(
                padding: EdgeInsets.only(
                  bottom: isTablet ? 24.0 : 16.0,
                  top: isTablet ? 10.0 : 0.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool showDisconnectButton =
                        constraints.maxWidth <= 600;
                    String? displayCabinetInfo;
                    if (currentCabinetName != null &&
                        currentCabinetName.isNotEmpty) {
                      displayCabinetInfo = currentCabinetName;
                    } else if (currentCabinetId != null &&
                        currentCabinetId.isNotEmpty) {
                      displayCabinetInfo = currentCabinetId;
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Bienvenue au ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isTablet ? 28 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                    if (displayCabinetInfo != null &&
                                        displayCabinetInfo.isNotEmpty)
                                      Text(
                                        displayCabinetInfo,
                                        style: GoogleFonts.montserrat(
                                          fontSize: isTablet ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade800,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (displayCabinetInfo != null &&
                                  displayCabinetInfo.isNotEmpty)
                                Text(
                                  'Gestion des patients et rendez-vous',
                                  style: GoogleFonts.montserrat(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (showDisconnectButton) ...[
                          const Spacer(),
                          DisconnectButton(
                            onPressed:
                                widget.onDisconnect ??
                                () {
                                  print(
                                    "DashboardScreen: Disconnect callback not provided or null.",
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur: Déconnexion non configurée correctement.',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                  // Consider navigating via HomeScreen's method if possible,
                                  // or directly if necessary (less ideal).
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                            isTablet: isTablet,
                            isInAppBar: true,
                          ),
                          SizedBox(width: isTablet ? 12 : 8),
                        ] else
                          SizedBox(width: isTablet ? 12 : 8),
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
