// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/disconnect_button.dart';
import '../providers/patient_provider.dart';
import '../models/appointment.dart';
import '../models/patient.dart';
import '../models/visit.dart'; // Import Visit model
import '../screens/patient_detail_screen.dart'; // Import PatientDetailScreen
import 'package:intl/intl.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onDisconnect;
  const DashboardScreen({super.key, this.onDisconnect});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Helper method to detect mobile layout
  bool isMobile() {
    return MediaQuery.of(context).size.width < 600;
  }

  final Map<String, String> _statusTranslations = const {
    'Scheduled': 'Programmé',
    'Completed':
        'Reporté', // Note: Original seems to have 'Completed' -> 'Reporté'. Keeping as is.
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };
  // --- FIX: Make Futures nullable instead of 'late' to prevent LateInitializationError ---
  Future<List<Visit>>? _todaysVisitsFuture;
  Future<Map<String, String>>? _patientNamesFuture;
  // --- END OF FIX ---

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      patientProvider.loadAppointments();
      _loadVisitData(patientProvider); // Load visit data
    });
  }

  // --- NEW: Method to load visit data for the dashboard ---
  Future<void> _loadVisitData(PatientProvider patientProvider) async {
    // --- Load all patients first to get names ---
    await patientProvider.loadPatients();
    final patientList = patientProvider.patients;
    final patientNamesMap = <String, String>{};
    for (var patient in patientList) {
      if (patient.id != null) {
        patientNamesMap[patient.id!] = patient.name;
      }
    }
    setState(() {
      _patientNamesFuture = Future.value(patientNamesMap);
      // --- Fetch all visits and filter for today ---
      _todaysVisitsFuture = patientProvider.getAllVisits().then((allVisits) {
        final String todayString = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());
        // Filter visits for today and sort by time descending (most recent first)
        return allVisits.where((visit) => visit.date == todayString).toList()
          ..sort((a, b) {
            return b.time.compareTo(a.time); // Sort by time descending
          });
      });
    });
  }
  // --- END OF NEW ---

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
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
    final List<Appointment> allAppointments = patientProvider.appointments;
    final List<Appointment> todayAppointments =
        allAppointments.where((a) => a.date == todayDate).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
    final List<Appointment> thisWeekAppointments =
        allAppointments.where((a) {
          final DateTime appointmentDate = DateTime.parse(a.date);
          final DateTime today = DateTime(now.year, now.month, now.day);
          final DateTime tomorrow = today.add(const Duration(days: 1));
          final DateTime endOfNextWeek = today.add(
            const Duration(days: 8),
          ); // Up to 7 days from today (exclusive)

          // Check if appointment is from tomorrow up to 7 days ahead
          return appointmentDate.isAfter(
                tomorrow.subtract(const Duration(days: 1)),
              ) &&
              appointmentDate.isBefore(endOfNextWeek);
        }).toList()..sort((a, b) {
          int dateComparison = a.date.compareTo(b.date);
          if (dateComparison != 0) return dateComparison;
          return a.time.compareTo(b.time);
        });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: isTablet ? 24.0 : 16.0,
          ),
          // --- NEW: Wrap in RefreshIndicator for pull-to-refresh ---
          child: RefreshIndicator(
            onRefresh: () => _loadVisitData(patientProvider),
            // --- END OF NEW ---
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER ---
                  Row(
                    children: [
                      // ✅ Show logo only on mobile
                      if (!isTablet)
                        Image.asset(
                          'assets/images/dentypro_logo.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      if (!isTablet)
                        const Spacer(), // Balance spacing only if logo is visible
                      // Disconnect Button (only on mobile)
                      if (widget.onDisconnect != null && !isTablet)
                        DisconnectButton(
                          onPressed: widget.onDisconnect!,
                          isTablet: isTablet,
                          isInAppBar: false,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // --- WELCOME BANNER ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade500],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour 👋',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentCabinetName != null
                              ? 'Cabinet $currentCabinetName'
                              : 'Bienvenue',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // --- DATE & TIME ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // --- STATS CARDS (CENTERED ON TABLET) INCLUDING TODAY'S PAID VISIT TOTAL ---
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildStatCard(
                          "Aujourd'hui",
                          todayAppointments.length,
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          "Cette semaine",
                          thisWeekAppointments.length,
                          Icons.event,
                          Colors.green,
                        ),
                        _buildStatCard(
                          "Patients",
                          patientProvider.patients.length,
                          Icons.person,
                          Colors.orange,
                        ),
                        // --- STAT CARD: TODAY'S PAID VISIT TOTAL AMOUNT ---
                        // This correctly calculates and displays the sum of amountPaid for today's visits
                        FutureBuilder<double>(
                          future: _todaysVisitsFuture?.then((visits) {
                            double totalPaid = 0.0;
                            for (var visit in visits) {
                              totalPaid += visit.amountPaid ?? 0.0;
                            }
                            return totalPaid;
                          }),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Show a loading card similar to _buildStatCard
                              return _buildLoadingStatCard(
                                "Total payé aujourd'hui",
                                Icons.attach_money,
                                Colors.teal,
                                isTablet,
                              );
                            } else if (snapshot.hasError) {
                              print(
                                "Error calculating today's paid visit total: ${snapshot.error}",
                              );
                              // Show an error card or fallback value
                              return _buildStatCard(
                                "Total payé aujourd'hui",
                                0, // Fallback value
                                Icons.attach_money,
                                Colors.teal, // Or error color like red
                              );
                            } else {
                              final totalPaidToday = snapshot.data ?? 0.0;
                              return _buildStatCard(
                                "Total payé aujourd'hui",
                                totalPaidToday, // Pass the double value
                                Icons.attach_money,
                                Colors.teal,
                                isCurrency: true, // Flag to format as currency
                              );
                            }
                          },
                        ),
                        // --- END OF NEW STAT CARD ---
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // --- TODAY'S VISITS LIST ---
                  _buildSectionTitle(
                    "Visites récentes (Aujourd'hui)",
                    Icons.access_time_outlined,
                  ), // Slightly different icon
                  const SizedBox(height: 16),
                  // --- FIX: Use null-aware FutureBuilder for visits list ---
                  FutureBuilder<List<Visit>>(
                    future: _todaysVisitsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print(
                          "Error loading today's visits: ${snapshot.error}",
                        );
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final visits = snapshot.data!;
                        if (visits.isEmpty) {
                          return _buildEmptyState(
                            "Aucune visite aujourd'hui.",
                            Icons.event_busy_outlined,
                          ); // Slightly different icon
                        } else {
                          // --- FIX: Use null-aware FutureBuilder for patient names ---
                          return FutureBuilder<Map<String, String>>(
                            future: _patientNamesFuture,
                            builder: (context, namesSnapshot) {
                              final patientNames = namesSnapshot.data ?? {};
                              // Limit the number of visits shown, e.g., to 5
                              final int maxVisitsToShow = 5;
                              final int visitCount = visits.length;
                              final bool showSeeAll =
                                  visitCount > maxVisitsToShow;
                              final List<Visit> visitsToShow = visits
                                  .take(maxVisitsToShow)
                                  .toList();
                              return Column(
                                children: [
                                  SizedBox(
                                    height: math.min(
                                      visitsToShow.length * 100.0,
                                      350,
                                    ), // Slightly increased height estimation for card with InkWell feedback
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: visitsToShow.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final visit = visitsToShow[index];
                                        final patientName =
                                            patientNames[visit.patientId] ??
                                            'Patient inconnu';
                                        // --- Wrap VisitCard with InkWell for tap interaction ---
                                        return InkWell(
                                          onTap: () async {
                                            try {
                                              // Find the patient object from the provider's list
                                              final patient = patientProvider
                                                  .patients
                                                  .firstWhere(
                                                    (p) =>
                                                        p.id == visit.patientId,
                                                    orElse: () => throw Exception(
                                                      'Patient not found for visit',
                                                    ),
                                                  );
                                              // Navigate to PatientDetailScreen
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PatientDetailScreen(
                                                        patient: patient,
                                                      ),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!mounted) return;
                                              print(
                                                "Error navigating to patient detail from visit: $e",
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Erreur: Patient non trouvé ou impossible d\'ouvrir les détails.',
                                                    style:
                                                        GoogleFonts.montserrat(),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ), // Match card border radius
                                          child: _buildVisitCard(
                                            visit,
                                            patientName,
                                            isTablet,
                                          ), // Use the existing card widget
                                        );
                                        // --- END OF NEW ---
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        // Handle case where future completes with no data (e.g., empty list from getAllVisits)
                        return _buildEmptyState(
                          "Aucune donnée de visite disponible.",
                          Icons.info_outline,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  // --- TODAY'S APPOINTMENTS ---
                  _buildSectionTitle(
                    "Rendez-vous d'aujourd'hui",
                    Icons.event_available, // Changed icon for distinction
                  ),
                  const SizedBox(height: 16),
                  todayAppointments.isEmpty
                      ? _buildEmptyState(
                          "Aucun rendez-vous aujourd'hui.",
                          Icons.event_busy,
                        )
                      : SizedBox(
                          height: math.min(
                            todayAppointments.length * 90.0,
                            300,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: todayAppointments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final appointment = todayAppointments[index];
                              final patientName = patientProvider
                                  .getPatientNameById(appointment.patientId);
                              return _buildAppointmentCard(
                                appointment,
                                patientName,
                                true,
                              );
                            },
                          ),
                        ),
                  // --- THIS WEEK ---
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    "Rendez-vous de la semaine",
                    Icons.event_note,
                  ),
                  const SizedBox(height: 16),
                  thisWeekAppointments.isEmpty
                      ? _buildEmptyState(
                          "Aucun autre rendez-vous cette semaine.",
                          Icons.event_available,
                        )
                      : SizedBox(
                          height: math.min(
                            thisWeekAppointments.length * 90.0,
                            300,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: thisWeekAppointments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final appointment = thisWeekAppointments[index];
                              final patientName = patientProvider
                                  .getPatientNameById(appointment.patientId);
                              return _buildAppointmentCard(
                                appointment,
                                patientName,
                                false,
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- MODIFIED _buildStatCard to accept double and format currency ---
  Widget _buildStatCard(
    String title,
    dynamic count,
    IconData icon,
    Color color, {
    bool isCurrency = false,
  }) {
    // Format the count based on whether it's currency or a simple integer
    String formattedCount;
    if (isCurrency) {
      // Ensure count is a double for currency formatting
      double amount = count is double
          ? count
          : (count is int ? count.toDouble() : 0.0);
      formattedCount = '${NumberFormat("#,##0.00", "fr_FR").format(amount)} DT';
    } else {
      // Assume it's an integer count
      int number = count is int ? count : (count is double ? count.toInt() : 0);
      formattedCount = '$number';
    }
    return SizedBox(
      width: isMobile() ? double.infinity : 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedCount, // Use the formatted string
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- END OF MODIFIED _buildStatCard ---

  // --- NEW WIDGET: Loading Stat Card ---
  Widget _buildLoadingStatCard(
    String title,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return SizedBox(
      width: isMobile() ? double.infinity : 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(
                    height: 20,
                    width: 80, // Adjust width as needed
                    child: LinearProgressIndicator(
                      color: Colors.teal,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- END OF NEW WIDGET ---

  // --- MODIFIED _buildVisitCard: Display totalAmount instead of amountPaid ---
  // The InkWell in the itemBuilder now handles the card-like container and tap feedback.
  Widget _buildVisitCard(Visit visit, String patientName, bool isTablet) {
    // --- REMOVED: outer Card widget ---
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ), // Increased padding slightly
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(12), // Border radius
        boxShadow: [
          // Subtle shadow for depth, similar to Card
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        // Use Row for horizontal layout similar to ListTile
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  visit.purpose ?? 'Pas de motif',
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ), // Slightly different icon
                    const SizedBox(width: 4),
                    Text(
                      visit.time,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // --- CHANGED: Display totalAmount instead of amountPaid ---
          Text(
            '${NumberFormat("#,##0.00", "fr_FR").format(visit.totalAmount ?? 0.0)} DT',
            style: GoogleFonts.montserrat(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors
                  .teal
                  .shade700, // You might want to change color based on total vs paid
            ),
          ),
          // --- END OF CHANGE ---
        ],
      ),
    );
    // --- END OF CHANGE ---
  }
  // --- END OF MODIFIED VISIT CARD ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    Appointment appointment,
    String patientName,
    bool isToday,
  ) {
    final String status =
        _statusTranslations[appointment.status] ?? appointment.status;
    final Color statusColor = _getStatusColor(appointment.status);
    final bool isImportant = isToday && appointment.status == 'Scheduled';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImportant ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImportant
              ? Colors.red.shade300
              : statusColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          try {
            final patient = Provider.of<PatientProvider>(
              context,
              listen: false,
            ).patients.firstWhere((p) => p.id == appointment.patientId);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailScreen(patient: patient),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isImportant
                          ? Colors.red.shade900
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🕒 ${appointment.time} • 📅 ${DateFormat('dd/MM', 'fr_FR').format(DateTime.parse(appointment.date))}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (appointment.notes.isNotEmpty)
                    Text(
                      '📝 ${appointment.notes}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Text(
                status,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}
