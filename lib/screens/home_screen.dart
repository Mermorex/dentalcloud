// lib/screens/home_screen.dart
import 'package:dental/screens/appointments_list_screen.dart';
import 'package:dental/screens/patients_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/patient_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
// --- IMPORT THE NEW WIDGET ---
import '../widgets/disconnect_button.dart'; // Import the reusable Disconnect button

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions; // Will be initialized in initState
  final List<String> _appBarTitles = const [
    'Tableau de bord',
    'Rendez-vous',
    'Patients',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        Provider.of<PatientProvider>(context, listen: false).filterPatients('');
      }
    });
  }

  // --- MODIFIED _onDisconnect ---
  // Ensure provider state is cleared before sign out
  void _onDisconnect() async {
    try {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      // Clear the PatientProvider's cabinet code and data FIRST
      // Pass null to the existing method which should clear data
      await patientProvider.setCurrentCabinetCode(null);
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Déconnexion réussie!')));
        // Navigate to the login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        print('HomeScreen: Sign out error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }

  // Inside lib/screens/home_screen.dart, in the _HomeScreenState class
  // Replace the existing initState method with this one:
  @override
  void initState() {
    super.initState();
    // --- MODIFIED INIT STATE ---
    // Initialize widget options correctly, passing the callback
    _widgetOptions = <Widget>[
      // --- PASS THE CALLBACK TO DASHBOARD SCREEN ---
      DashboardScreen(onDisconnect: _onDisconnect), // <-- CHANGED THIS LINE
      const AppointmentsListScreen(),
      const PatientsList(),
    ];
    // --- END MODIFIED INIT STATE ---

    // Handle data loading and cabinet code check on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("HomeScreen: addPostFrameCallback triggered.");
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      // Scenario 1: Cabinet code is already set in the provider (e.g., normal navigation after login setup)
      if (patientProvider.currentCabinetCode != null) {
        print(
          "HomeScreen: Cabinet code already present in provider. Loading data...",
        );
        // Data might already be loaded, but trigger a reload to be sure
        await patientProvider.loadPatients();
        await patientProvider.loadAppointments();
        print(
          "HomeScreen: Data loaded using existing cabinet code from provider.",
        );
        return; // Important: Exit if code is already set
      }
      // Scenario 2: Cabinet code is NOT set (e.g., after a browser refresh or deep link)
      print(
        "HomeScreen: No cabinet code found in provider. Checking user session...",
      );
      try {
        // Use currentSession - this is the correct way in Supabase Flutter SDK
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          // User is logged in according to Supabase.
          print(
            "HomeScreen: Valid user session found. Fetching cabinet code from database...",
          );
          try {
            // --- FETCH CABINET CODE FROM DATABASE (cabinet_members table) ---
            // This is the standard way based on your auth_screen.dart logic
            final memberResponse = await Supabase.instance.client
                .from('cabinet_members')
                .select('cabinet_code')
                .eq('user_id', session.user.id)
                .eq('is_active', true)
                .limit(1); // Assuming one primary cabinet for simplicity
            if (memberResponse.isNotEmpty) {
              String? cabinetCode =
                  memberResponse[0]['cabinet_code'] as String?;
              if (cabinetCode != null && cabinetCode.isNotEmpty) {
                print(
                  "HomeScreen: Fetched cabinet code '$cabinetCode'. Setting in provider...",
                );
                // Setting the cabinet code in the provider should trigger data loading if needed,
                // or we can load explicitly afterwards.
                await patientProvider.setCurrentCabinetCode(cabinetCode);
                print(
                  "HomeScreen: Cabinet code set in provider. Loading data...",
                );
                await patientProvider.loadPatients();
                await patientProvider.loadAppointments();
                print(
                  "HomeScreen: Data loaded successfully after fetching cabinet code.",
                );
              } else {
                // Unexpected: Record found but code is null/empty
                print(
                  'HomeScreen Error: Cabinet code found in record but is null/empty for user ${session.user.id}.',
                );
                await _forceLogoutDueToConfigError();
              }
            } else {
              // Critical Error: User is logged in but has no associated active cabinet membership.
              print(
                'HomeScreen Error: No active cabinet membership found for user ${session.user.id}.',
              );
              await _forceLogoutDueToConfigError();
            }
          } catch (fetchError) {
            // Error occurred while trying to fetch the cabinet code from DB.
            print(
              'HomeScreen Error: Failed to fetch cabinet code from DB: $fetchError',
            );
            await _forceLogoutDueToConfigError();
          }
        } else {
          // Error State: User should not be on HomeScreen without a valid session.
          // This indicates a problem with the initial navigation logic in AuthStateWrapper
          // or a very quick session expiry.
          print(
            "HomeScreen Error: No valid user session found. User should not be on this screen.",
          );
          await _forceLogoutDueToConfigError();
        }
      } catch (sessionCheckError) {
        // Error occurred while checking the session
        print(
          'HomeScreen Error: Failed to check/get user session: $sessionCheckError',
        );
        await _forceLogoutDueToConfigError();
      }
    });
    // --- END OF MODIFIED INIT STATE ---
  }

  // --- NEW HELPER METHOD ---
  // Handles forced logout and navigation due to critical configuration errors
  Future<void> _forceLogoutDueToConfigError() async {
    print("HomeScreen: Initiating forced logout due to configuration error.");
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    // Ensure provider is clean first
    await patientProvider.setCurrentCabinetCode(null);
    // Attempt Supabase sign out (might fail if session was invalid)
    try {
      await Supabase.instance.client.auth.signOut();
      print("HomeScreen: Supabase sign out attempted.");
    } catch (signOutError) {
      print(
        "HomeScreen: Error during Supabase sign out (continuing): $signOutError",
      );
    }
    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  // --- END OF NEW HELPER METHOD ---

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: isSmallScreen
          ? _widgetOptions.elementAtOrNull(_selectedIndex) ?? const SizedBox()
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
                              label: Text(
                                _appBarTitles[2],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- USE THE REUSABLE COMPONENT IN NAVIGATION RAIL ---
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                        child: DisconnectButton(
                          onPressed: _onDisconnect, // Use the correct method
                          isTablet:
                              true, // NavigationRail is for larger screens
                          isInAppBar: false, // It's in the rail, not app bar
                        ),
                      ),
                      // --- END USE COMPONENT ---
                    ],
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child:
                      _widgetOptions.elementAtOrNull(_selectedIndex) ??
                      const SizedBox(),
                ),
                // ... (rest of your existing UI code for desktop layout, if any) ...
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
                // ... (rest of your existing UI code for mobile layout) ...
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
                    label: _appBarTitles[2],
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
    );
  }
}

// Keep the SafeListAccess extension for robustness
extension SafeListAccess<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
}
