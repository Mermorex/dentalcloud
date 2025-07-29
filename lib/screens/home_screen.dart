// lib/screens/home_screen.dart
import 'package:dental/screens/patient_detail_screen.dart';
import 'package:dental/screens/patients_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'add_patient_screen.dart';
import 'appointments_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import '../models/visit.dart';
import '../db/database_helper.dart';
import 'auth_screen.dart';
import 'package:dental/widgets/main_button.dart'; // Import your MainButton
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
  // Set _selectedIndex to 0, as Dashboard will now be the first item (index 0)
  int _selectedIndex = 0;
  static const int _patientLimit =
      20; // This limit will now be handled within PatientsList if needed

  late final List<Widget> _widgetOptions = <Widget>[
    // Reordered: Dashboard, Appointments, Patients
    const DashboardScreen(),
    AppointmentsListScreen(key: appointmentsListScreenKey),
    const PatientsList(),
  ];

  final List<String> _appBarTitles = const [
    // Reordered to match the new screen order
    'Tableau de bord', // Corresponds to Dashboard (index 0)
    'Rendez-vous', // Corresponds to Appointments (index 1)
    '', // Empty for PatientsList, as it has its own title (index 2)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // If the selected index is not the PatientsList (now index 2), clear the search filter
      if (index != 2) {
        Provider.of<PatientProvider>(context, listen: false).filterPatients('');
      }
    });
  }

  void _onDisconnect() async {
    await DatabaseHelper.instance.backupDatabase();
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
      // Removed AppBar from HomeScreen, as each screen will manage its own.
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
                          // 移除elevation属性以消除阴影
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
                            // First icon: Dashboard
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
                                _appBarTitles[0], // Dashboard
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Second icon: Appointments
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
                                _appBarTitles[1], // Appointments
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Last icon: Patients
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
                              label: Text(
                                'Patients', // Patients
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
                color: Colors.white, // Set background color to white
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
                  // Reordered: Dashboard, Appointments, Patients
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(
                        8,
                      ), // Smaller padding for bottom nav
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? Colors.teal.shade700
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Match rail's border radius
                      ),
                      child: Icon(
                        Icons.bar_chart_outlined,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : Colors.teal.shade700,
                        size: 24, // Consistent icon size
                      ),
                    ),
                    label: _appBarTitles[0], // Dashboard
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
                    label: _appBarTitles[1], // Appointments
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
                    label: 'Patients', // Patients
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors
                    .transparent, // Make transparent as container provides color
                elevation: 0, // Remove default elevation
                type: BottomNavigationBarType
                    .fixed, // Ensure all labels are visible
                // Customizing label styles to match NavigationRail
                selectedLabelStyle: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, // Matching font weight
                  color: Colors.teal.shade700, // Color for selected label
                  fontSize: 12, // Consistent font size
                ),
                unselectedLabelStyle: GoogleFonts.montserrat(
                  color: Colors.grey.shade600, // Matching unselected color
                  fontSize: 11, // Consistent font size
                ),
                selectedItemColor:
                    Colors.transparent, // Icons are handled by containers
                unselectedItemColor:
                    Colors.transparent, // Icons are handled by containers
              ),
            )
          : null,
      floatingActionButton: null,
    );
  }
}
