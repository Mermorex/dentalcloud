import 'package:dental/models/procedure.dart';

class InvoiceItem {
  final int? id;
  final int toothNumber;
  final Procedure procedure;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    this.id,
    required this.toothNumber,
    required this.procedure,
    this.quantity = 1,
  }) : unitPrice = procedure.price;

  double get subtotal => quantity * unitPrice;
}
