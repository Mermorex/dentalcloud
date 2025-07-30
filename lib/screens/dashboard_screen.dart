import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';
// Import a package for local storage, e.g., shared_preferences
// import 'package:shared_preferences/shared_preferences.dart'; // You'll need to add this to your pubspec.yaml

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
      Provider.of<PatientProvider>(context, listen: false).loadAppointments();
    });
  }

  void _handleDisconnect() async {
    // Made async to await SharedPreferences
    // 1. Clear user session/authentication tokens
    // Example using shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('user_token'); // Or whatever your token key is
    // await prefs.clear(); // To clear all stored preferences

    print('User disconnected!');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Déconnexion réussie!')));

    // 2. Navigate to a login screen
    // Make sure '/login' is a defined route in your MaterialApp
    Navigator.of(context).pushReplacementNamed('/login');
    // If you don't have named routes, you can use:
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(builder: (context) => LoginScreen()), // Replace LoginScreen with your actual login screen widget
    // );
  }

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
    final List<Appointment> todayAppointments = allAppointments.where((
      appointment,
    ) {
      return appointment.date == todayDate;
    }).toList();

    todayAppointments.sort((a, b) => a.time.compareTo(b.time));

    final List<Appointment> thisWeekAppointments = allAppointments.where((
      appointment,
    ) {
      final DateTime appointmentDate = DateTime.parse(appointment.date);
      // Include today in this week's appointments
      return appointmentDate.isAfter(now.subtract(const Duration(days: 1))) &&
          appointmentDate.isBefore(now.add(const Duration(days: 7)));
    }).toList();

    thisWeekAppointments.sort((a, b) {
      int dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return a.time.compareTo(b.time);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Consistent background
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Combined Dashboard Title, Disconnect Button, and Logo in a Row
              Padding(
                padding: EdgeInsets.only(
                  bottom: isTablet ? 24.0 : 16.0,
                  top: isTablet ? 10.0 : 0.0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Text(
                      'Dashboard',
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    Spacer(), // Pushes subsequent widgets to the right
                    if (!isTablet) // Show disconnect button only on mobile
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          size: 28, // Adjust size for mobile
                          color: Colors.teal.shade700,
                        ),
                        onPressed: _handleDisconnect,
                        tooltip: 'Déconnexion',
                      ),
                    SizedBox(
                      width: isTablet ? 12 : 8,
                    ), // Space between disconnect and logo
                    Image.asset(
                      'assets/images/tooth_logo.png',
                      width: isTablet ? 48 : 36, // Smaller, responsive logo
                      height: isTablet ? 48 : 36, // Smaller, responsive logo
                    ),
                  ],
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
                      color: Colors.black.withOpacity(
                        0.05,
                      ), // Consistent shadow
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
                        color: Colors.teal.shade700, // Matched color
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.teal.shade600, // Matched color
                          size: isTablet ? 30 : 24,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          formattedDate,
                          style: GoogleFonts.montserrat(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700, // Matched color
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.teal.shade600, // Matched color
                          size: isTablet ? 30 : 24,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          formattedTime,
                          style: GoogleFonts.montserrat(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700, // Matched color
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
                  color:
                      Colors.teal.shade50, // Consistent with patient list card
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.teal.shade200,
                    width: 1,
                  ), // Consistent border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rendez-vous d'aujourd'hui",
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800, // Consistent color
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600, // Consistent color
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
                  color:
                      Colors.teal.shade50, // Consistent with patient list card
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.teal.shade200,
                    width: 1,
                  ), // Consistent border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rendez-vous de cette semaine",
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800, // Consistent color
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600, // Consistent color
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
              color: Colors.teal.shade50, // Consistent with empty patient state
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined, // Appropriate icon
              size: isTablet ? 80 : 60,
              color: Colors.teal.shade300, // Consistent color
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
                color: Colors.grey.shade500, // Consistent color
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final Map<String, String> statusTranslations;
  final bool isImportant;
  final bool isTablet; // Add isTablet parameter

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.patientName,
    required this.statusTranslations,
    this.isImportant = false,
    required this.isTablet, // Require isTablet
  }) : super(key: key);

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

  // New method to get card border color, consistent with patient card
  Color _getCardBorderColor(String status, bool isImportant) {
    if (isImportant) {
      return Colors.red.shade400; // Highlight for today's appointments
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
        : Colors.white; // Always white unless important (today's)
    final Color cardBorderColor = _getCardBorderColor(
      appointment.status,
      isImportant,
    );
    final Color patientNameColor = isImportant
        ? Colors.red.shade800
        : Colors.grey.shade800; // Consistent with patient list card name color

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16), // Consistent margin
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20), // Consistent border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Consistent shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cardBorderColor,
          width: 1.5,
        ), // Consistent border
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0), // Consistent padding
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
                      fontSize: isTablet ? 22 : 20, // Adjusted font size
                      color: patientNameColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Icon(
                  Icons.access_time,
                  size: isTablet ? 24 : 20, // Adjusted icon size
                  color: Colors.grey.shade600, // Consistent color
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Text(
                  appointment.time,
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 19 : 17, // Adjusted font size
                    color: Colors.grey.shade900, // Consistent color
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
                  size: isTablet ? 18 : 16, // Adjusted icon size
                  color: Colors.grey.shade500, // Consistent color
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Text(
                  'Date: ${DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(appointment.date))}',
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 16 : 14, // Adjusted font size
                    color: Colors.grey.shade700, // Consistent color
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
                    size: isTablet ? 18 : 16, // Adjusted icon size
                    color: Colors.grey.shade500, // Consistent color
                  ),
                  SizedBox(width: isTablet ? 10 : 8),
                  Expanded(
                    child: Text(
                      'Notes: ${appointment.notes}',
                      style: GoogleFonts.montserrat(
                        fontSize: isTablet ? 16 : 14, // Adjusted font size
                        color: Colors.grey.shade700, // Consistent color
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
                  fontSize: isTablet ? 15 : 13, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: statusColor.darken(0.1),
                ),
              ),
            ),
          ],
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
