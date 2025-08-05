// lib/providers/subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase SDK

class SubscriptionProvider with ChangeNotifier {
  String? _status;
  DateTime? _trialEndDate;
  bool _isLoading = false;
  String? _errorMessage;

  String? get status => _status;
  DateTime? get trialEndDate => _trialEndDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // This getter contains the core logic
  bool get isSubscriptionValid {
    if (_status == 'paid') {
      return true; // Paid subscriptions are always valid (add end date check if needed)
    }
    if (_status == 'trial' && _trialEndDate != null) {
      final now = DateTime.now().toUtc(); // Compare in UTC
      // Ensure trialEndDate is also UTC when fetched from Supabase
      return now.isBefore(_trialEndDate!);
    }
    // If status is 'expired', null, or trial date passed
    return false;
  }

  // You need to call this method after login, passing the cabinetId
  Future<void> fetchSubscriptionStatus(String cabinetId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI that loading started

    try {
      // --- FETCH FROM SUPABASE ---
      final response = await Supabase.instance.client
          .from('subscriptions')
          .select('status, trial_end_date') // Select only needed columns
          .eq('cabinet_id', cabinetId) // Filter by cabinet ID
          .single(); // Expect a single record

      if (response != null) {
        _status = response['status'];
        // Parse the date string from Supabase (usually includes timezone)
        // toUtc() ensures consistency if comparing with DateTime.now().toUtc()
        _trialEndDate = response['trial_end_date'] != null
            ? DateTime.parse(response['trial_end_date']).toUtc()
            : null;
      } else {
        // No subscription record found for this cabinet
        _errorMessage = 'Aucun abonnement trouvé pour ce cabinet.';
        _status = null;
        _trialEndDate = null;
      }
    } catch (error) {
      print("Error fetching subscription: $error");
      _errorMessage = 'Erreur lors de la vérification de l\'abonnement.';
      _status = null;
      _trialEndDate = null;
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading finished (success or error)
    }
  }

  // Optional: Method to clear state (e.g., on logout)
  void clear() {
    _status = null;
    _trialEndDate = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
