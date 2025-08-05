// models/subscription.dart
class Subscription {
  final String id;
  final String cabinetId; // Link to the cabinet/user
  final String status; // 'trial', 'paid', 'expired'
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  Subscription({
    required this.id,
    required this.cabinetId,
    required this.status,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });
}
