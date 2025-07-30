// lib/screens/home_screen.dart
import 'package:dental/screens/patient_detail_screen.dart';
import 'package:dental/screens/patients_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/patient_provider.dart';
import '../models/patient.dart';
import 'add_patient_screen.dart';
import 'appointments_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import '../models/visit.dart';
import '../db/database_helper.dart'; // Added this line for DatabaseHelper.instance.backupDatabase
import 'auth_screen.dart';
import 'package:dental/widgets/main_button.dart';
import 'add_appointment_screen.dart';

// Define a GlobalKey for AppointmentsListScreen
final GlobalKey<State<AppointmentsListScreen>> appointmentsListScreenKey =
    GlobalKey<State<AppointmentsListScreen>>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const int _patientLimit = 20;

  late final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    AppointmentsListScreen(key: appointmentsListScreenKey),
    const PatientsList(),
  ];

  final List<String> _appBarTitles = const [
    'Tableau de bord',
    'Rendez-vous',
    '',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        Provider.of<PatientProvider>(context, listen: false).filterPatients('');
      }
    });
  }

  void _onDisconnect() async {
    // Note: Local database backup is not typically applicable for Supabase.
    // If you have a custom backup process or need to clear local Supabase cache on logout,
    // implement that here. Otherwise, you can remove this line.
    // await DatabaseHelper.instance.backupDatabase(); // Removed or commented out as per Supabase context
    // For Supabase logout, you should call:
    await Supabase.instance.client.auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        transitionDuration: Duration.zero,
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
      Provider.of<PatientProvider>(context, listen: false).loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isSmallScreen
          ? _widgetOptions[_selectedIndex]
          : Row(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/tooth_logo.png',
                            height: 60,
                          ),
                        ),
                      ),
                      Expanded(
                        child: NavigationRail(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _onItemTapped,
                          labelType: NavigationRailLabelType.all,
                          backgroundColor: Colors.white,
                          selectedIconTheme: const IconThemeData(
                            color: Colors.white,
                            size: 28,
                          ),
                          unselectedIconTheme: IconThemeData(
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                          selectedLabelTextStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          unselectedLabelTextStyle: GoogleFonts.montserrat(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          groupAlignment: 0.0,
                          destinations: [
                            NavigationRailDestination(
                              icon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.bar_chart_outlined,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              selectedIcon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.bar_chart_rounded),
                              ),
                              label: Text(
                                _appBarTitles[0],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            NavigationRailDestination(
                              icon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.event_available_outlined,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              selectedIcon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.event_available_rounded,
                                ),
                              ),
                              label: Text(
                                _appBarTitles[1],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            NavigationRailDestination(
                              icon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              selectedIcon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.person_rounded),
                              ),
                              label: const Text(
                                'Patients',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                        child: InkWell(
                          onTap: _onDisconnect,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Déconnexion',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _widgetOptions[_selectedIndex]),
              ],
            ),
      bottomNavigationBar: isSmallScreen
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? Colors.teal.shade700
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.bar_chart_outlined,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : Colors.teal.shade700,
                        size: 24,
                      ),
                    ),
                    label: _appBarTitles[0],
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? Colors.teal.shade700
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_available_outlined,
                        color: _selectedIndex == 1
                            ? Colors.white
                            : Colors.teal.shade700,
                        size: 24,
                      ),
                    ),
                    label: _appBarTitles[1],
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 2
                            ? Colors.teal.shade700
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: _selectedIndex == 2
                            ? Colors.white
                            : Colors.teal.shade700,
                        size: 24,
                      ),
                    ),
                    label: 'Patients',
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                  fontSize: 12,
                ),
                unselectedLabelStyle: GoogleFonts.montserrat(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
                selectedItemColor: Colors.transparent,
                unselectedItemColor: Colors.transparent,
              ),
            )
          : null,
      floatingActionButton: null,
    );
  }
}
