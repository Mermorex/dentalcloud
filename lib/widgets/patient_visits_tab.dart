// lib/screens/patient_visits_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/visit.dart';
import '../providers/patient_provider.dart';
import '../screens/add_visit_screen.dart';
import '../widgets/main_button.dart';
import '../widgets/visit_card.dart';

class PatientVisitsTab extends StatefulWidget {
  final String patientId; // <-- Required
  final Future<void> Function() onRefresh;
  final Future<void> Function() onVisitAdded; // Callback to refresh parent list

  const PatientVisitsTab({
    super.key,
    required this.patientId,
    required this.onRefresh,
    required this.onVisitAdded,
  });

  @override
  State<PatientVisitsTab> createState() => _PatientVisitsTabState();
}

class _PatientVisitsTabState extends State<PatientVisitsTab> {
  late Future<List<Visit>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    setState(() {
      _visitsFuture = Provider.of<PatientProvider>(
        context,
        listen: false,
      ).getVisitsForPatient(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchVisits(); // Refresh local future
        await widget.onRefresh(); // Call parent's refresh if needed
      },
      child: FutureBuilder<List<Visit>>(
        future: _visitsFuture,
        builder: (context, snapshot) {
          Widget content;
          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            content = Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final visits = snapshot.data!;
            if (visits.isEmpty) {
              content = const Center(
                child: Text('Aucune visite enregistrée pour ce patient.'),
              );
            } else {
              content = ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return VisitCard(
                    visit: visit,
                    patientId: widget.patientId,
                    onVisitUpdated: _fetchVisits, // Refresh local list
                  );
                },
              );
            }
          } else {
            content = const Center(
              child: Text('Aucune donnée de visite disponible.'),
            );
          }

          return Column(
            children: [
              Expanded(child: content),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Spacer(),
                    MainButton(
                      label: 'Ajouter une visite',
                      icon: Icons.add,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddVisitScreen(patientId: widget.patientId),
                          ),
                        );
                        if (!mounted) return;
                        _fetchVisits(); // Refresh local list
                        widget.onVisitAdded(); // Notify parent
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
