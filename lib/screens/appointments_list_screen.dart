// lib/screens/appointments_list_screen.dart
import 'package:dental/models/appointment.dart';
import 'package:dental/models/patient.dart'; // Import Patient model
import 'package:dental/screens/patient_detail_screen.dart'; // Import PatientDetailScreen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'edit_appointment_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_appointment_screen.dart'; // Import AddAppointmentScreen
import 'package:dental/widgets/main_button.dart'; // Assuming you have a MainButton widget

// This is the SINGLE, GLOBAL declaration of the GlobalKey that both HomeScreen and AppointmentsListScreen will use.
final GlobalKey<_AppointmentsListScreenState> appointmentsListScreenKey =
    GlobalKey();

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});
  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final Map<String, String> _statusTranslations = {
    'Scheduled': 'Programmé',
    'Completed':
        'Reporté', // Note: This seems like a translation mismatch. 'Completed' usually means 'Terminé'. Keeping as per your code.
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime?
  _selectedDay; // This holds the date selected by the user in the calendar
  late final ValueNotifier<List<Appointment>> _selectedEvents;
  Map<DateTime, List<Appointment>> _events = {};

  // Getter to expose the currently selected day to external widgets
  // This getter is kept for potential future use or if GlobalKey access is fixed.
  DateTime? get selectedDayForAddAppointment => _selectedDay;

  @override
  void initState() {
    super.initState();
    // Initialize _selectedDay to the current date when the screen loads.
    _selectedDay = DateTime.now();
    print('AppointmentsListScreen: Initial _selectedDay set to: $_selectedDay');
    _selectedEvents = ValueNotifier([]);
    _loadAppointments().then((_) {
      if (mounted) {
        _events = _groupAppointmentsByDay(
          Provider.of<PatientProvider>(context, listen: false).appointments,
        );
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      }
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Map<DateTime, List<Appointment>> _groupAppointmentsByDay(
    List<Appointment> allAppointments,
  ) {
    Map<DateTime, List<Appointment>> data = {};
    for (var appointment in allAppointments) {
      // Parse the date string to DateTime
      final parsedDate = DateTime.parse(appointment.date);
      // Create a DateTime object representing the start of the day (UTC)
      final day = DateTime.utc(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      if (data[day] == null) {
        data[day] = [];
      }
      data[day]!.add(appointment);
    }
    return data;
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    // Ensure we compare UTC dates
    final utcDay = DateTime.utc(day.year, day.month, day.day);
    return _events[utcDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print(
      'AppointmentsListScreen: _onDaySelected called. selectedDay: $selectedDay, focusedDay: $focusedDay',
    );
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay =
            selectedDay; // Update _selectedDay with the date selected by the user
        _focusedDay = focusedDay;
        print('AppointmentsListScreen: _selectedDay updated to: $_selectedDay');
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Future<void> _loadAppointments() async {
    await Provider.of<PatientProvider>(
      context,
      listen: false,
    ).loadAppointments();
    if (!mounted) return;
    _events = _groupAppointmentsByDay(
      Provider.of<PatientProvider>(context, listen: false).appointments,
    );
    if (_selectedDay != null) {
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  Future<void> _confirmAndDeleteAppointment(
    BuildContext context,
    String appointmentId,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Supprimer le rendez-vous',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer ce rendez-vous ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Supprimer',
                style: GoogleFonts.montserrat(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (confirm == true) {
      await Provider.of<PatientProvider>(
        context,
        listen: false,
      ).deleteAppointment(appointmentId);
      if (!mounted) return;
      await _loadAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rendez-vous supprimé avec succès !',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper method to get the initial date for AddAppointmentScreen
  // Updated to be more robust and provide better logging.
  // It now attempts direct access as a fallback if GlobalKey fails.
  DateTime? _getInitialDateForAddAppointment() {
    DateTime? initialDate;
    print('AppointmentsListScreen: _getInitialDateForAddAppointment called.');

    // Primary method: Try accessing via GlobalKey
    if (appointmentsListScreenKey.currentState != null) {
      initialDate =
          appointmentsListScreenKey.currentState!.selectedDayForAddAppointment;
      print(
        'AppointmentsListScreen: Retrieved date via GlobalKey: $initialDate',
      );
    } else {
      print('AppointmentsListScreen: GlobalKey state is null.');
      // Fallback method: Try accessing _selectedDay directly from 'this' instance
      // This should work if called from within the State class methods like onPressed.
      try {
        // 'this' refers to the current _AppointmentsListScreenState instance
        initialDate = this._selectedDay;
        print(
          'AppointmentsListScreen: Fallback - Retrieved date directly from this._selectedDay: $initialDate',
        );
      } catch (e) {
        print(
          'AppointmentsListScreen: Error during direct access fallback: $e',
        );
      }
    }

    if (initialDate == null) {
      print(
        'AppointmentsListScreen: Final initialDate is null, will default to today in AddAppointmentScreen.',
      );
    } else {
      print(
        'AppointmentsListScreen: Final initialDate to be passed: $initialDate',
      );
    }

    return initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Text(
            'Rendez-vous',
            style: GoogleFonts.montserrat(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.add_alarm,
                color: Colors.teal.shade600,
                size: isTablet ? 32 : 28,
              ),
              // --- UPDATED onPressed for AppBar Button ---
              onPressed: () async {
                // Get the selected date directly from the current state before navigating
                // This is the robust way to ensure we have the latest selected date.
                final DateTime? initialAppointmentDate = _selectedDay;
                print(
                  'AppointmentsListScreen (AppBar Button): Directly accessed _selectedDay: $initialAppointmentDate',
                );

                // Optional: Call the helper for logging/fallback logic, but don't rely on its return value for navigation.
                // The helper's logging might give us more insight if the direct access also fails unexpectedly.
                _getInitialDateForAddAppointment(); // Call for side effects/logging

                print(
                  'AppointmentsListScreen (AppBar Button): Navigating with initialDate: $initialAppointmentDate',
                );
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddAppointmentScreen(
                          initialDate:
                              initialAppointmentDate, // Pass the directly accessed date
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return child;
                        },
                    transitionDuration: Duration.zero,
                  ),
                );
                // Call _loadAppointments to refresh the list after returning from AddAppointmentScreen
                if (mounted) {
                  await _loadAppointments();
                }
              },
              // --- END OF UPDATED onPressed ---
            ),
          ),
        ],
      ),
      body: Consumer<PatientProvider>(
        builder: (context, patientProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: TableCalendar<Appointment>(
                      locale: 'fr',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      eventLoader: _getEventsForDay,
                      onDaySelected: _onDaySelected,
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.6),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        selectedTextStyle: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        defaultDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: GoogleFonts.montserrat(
                          color: Colors.black87,
                        ),
                        weekendDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: GoogleFonts.montserrat(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.teal.shade800,
                          size: 32,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.teal.shade800,
                          size: 32,
                        ),
                        headerPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        headerMargin: const EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(color: Colors.teal.shade50),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        weekendStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              bottom: 30,
                              left: 30,
                              right: 0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: _buildEventsMarker(events.length),
                              ),
                            );
                          }
                          return null;
                        },
                        selectedBuilder: (context, date, events) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.6),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${date.day}',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              const SizedBox(height: 8.0),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const <Color>[
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                      ],
                      stops: const [0.0, 0.05, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ValueListenableBuilder<List<Appointment>>(
                    valueListenable: _selectedEvents,
                    builder: (context, appointments, _) {
                      if (appointments.isEmpty) {
                        return Center(
                          child: Text(
                            _selectedDay != null
                                ? 'Aucun rendez-vous pour le ${(_selectedDay!).day}/${(_selectedDay!).month}/${(_selectedDay!).year}.'
                                : 'Sélectionnez une date pour voir les rendez-vous.',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          final patientName = patientProvider
                              .getPatientNameById(appointment.patientId);
                          return AppointmentCard(
                            appointment: appointment,
                            patientName: patientName,
                            statusTranslations: _statusTranslations,
                            onEdit: () async {
                              await Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => EditAppointmentScreen(
                                        appointment: appointment,
                                      ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return child;
                                      },
                                  transitionDuration: Duration.zero,
                                ),
                              );
                              if (!mounted) return;
                              await _loadAppointments();
                            },
                            onDelete: () => _confirmAndDeleteAppointment(
                              context,
                              appointment.id!.toString(),
                            ),
                            // Add the onTap callback for navigating to Patient Detail
                            onTap: () async {
                              try {
                                // Find the Patient object using the patientId from the appointment
                                final patient = patientProvider.patients
                                    .firstWhere(
                                      (p) => p.id == appointment.patientId,
                                    );
                                // Navigate to PatientDetailScreen
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientDetailScreen(patient: patient),
                                  ),
                                );
                              } catch (e) {
                                // Handle case where patient is not found
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
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // --- UPDATED onPressed for FAB ---
      floatingActionButton: !isSmallScreen
          ? Container(
              margin: const EdgeInsets.only(bottom: 16, right: 16),
              child: MainButton(
                label: 'Ajouter un rendez-vous',
                icon: Icons.add_alarm,
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                heroTag: 'addAppointmentFab',
                onPressed: () async {
                  // Get the selected date directly from the current state before navigating
                  // This is the robust way to ensure we have the latest selected date.
                  final DateTime? initialAppointmentDate = _selectedDay;
                  print(
                    'AppointmentsListScreen (FAB): Directly accessed _selectedDay: $initialAppointmentDate',
                  );

                  // Optional: Call the helper for logging/fallback logic, but don't rely on its return value for navigation.
                  // The helper's logging might give us more insight if the direct access also fails unexpectedly.
                  _getInitialDateForAddAppointment(); // Call for side effects/logging

                  print(
                    'AppointmentsListScreen (FAB): Navigating with initialDate: $initialAppointmentDate',
                  );
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddAppointmentScreen(
                            initialDate:
                                initialAppointmentDate, // Pass the directly accessed date
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return child;
                          },
                      transitionDuration: Duration.zero,
                    ),
                  );
                  // Call _loadAppointments to refresh the list after returning from AddAppointmentScreen
                  if (mounted) {
                    await _loadAppointments();
                  }
                },
              ),
            )
          : null,
      // --- END OF UPDATED onPressed ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEventsMarker(int count) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.redAccent,
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Updated AppointmentCard class to include the onTap parameter
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final Map<String, String> statusTranslations;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap; // Add the onTap callback
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
    required this.statusTranslations,
    required this.onEdit,
    required this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(appointment.status);
    final Color lightStatusColor = _getLightStatusColor(appointment.status);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: isTablet ? 16.0 : 16,
      ),
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
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      // Wrap the main content with InkWell for tap handling
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback for navigation
        borderRadius: BorderRadius.circular(
          20,
        ), // Match the card's border radius
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
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
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 20 : 18,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: isTablet ? 22 : 20,
                          color: Colors.teal.shade600,
                        ),
                        onPressed: onEdit, // Keep onEdit for the edit icon
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: isTablet ? 22 : 20,
                          color: Colors.red.shade600,
                        ),
                        onPressed:
                            onDelete, // Keep onDelete for the delete icon
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isTablet ? 18 : 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.date,
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: isTablet ? 18 : 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.time,
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: isTablet ? 18 : 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes,
                        style: GoogleFonts.montserrat(
                          fontSize: isTablet ? 15 : 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 10 : 8,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: lightStatusColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getTranslatedStatus(appointment.status),
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
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
