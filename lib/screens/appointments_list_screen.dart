// lib/screens/appointments_list_screen.dart
import 'package:dental/models/appointment.dart';
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
    GlobalKey(); //

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key}); //

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final Map<String, String> _statusTranslations = {
    'Scheduled': 'Programmé',
    'Completed': 'Reporté',
    'Cancelled': 'Annulé',
    'No Show': 'Absent',
  };

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Appointment>> _selectedEvents;

  Map<DateTime, List<Appointment>> _events = {};

  // Getter to expose the currently selected day to external widgets
  DateTime? get selectedDayForAddAppointment => _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
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
      final day = DateTime.utc(
        DateTime.parse(appointment.date).year,
        DateTime.parse(appointment.date).month,
        DateTime.parse(appointment.date).day,
      );
      if (data[day] == null) {
        data[day] = [];
      }
      data[day]!.add(appointment);
    }
    return data;
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
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
              onPressed: () async {
                DateTime? initialAppointmentDate;
                // This will now correctly access the state because it refers to the single global key
                if (appointmentsListScreenKey.currentState != null) {
                  initialAppointmentDate = appointmentsListScreenKey
                      .currentState!
                      .selectedDayForAddAppointment;
                }

                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddAppointmentScreen(
                          initialDate: initialAppointmentDate,
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
                  DateTime? initialAppointmentDate;
                  // This will now correctly access the state because it refers to the single global key
                  if (appointmentsListScreenKey.currentState != null) {
                    initialAppointmentDate = appointmentsListScreenKey
                        .currentState!
                        .selectedDayForAddAppointment;
                  }

                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddAppointmentScreen(
                            initialDate: initialAppointmentDate,
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

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String patientName;
  final Map<String, String> statusTranslations;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
    required this.statusTranslations,
    required this.onEdit,
    required this.onDelete,
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
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(20),
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
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: isTablet ? 22 : 20,
                          color: Colors.red.shade600,
                        ),
                        onPressed: onDelete,
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
