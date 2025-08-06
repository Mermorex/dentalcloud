import 'package:dental/models/invoice_item.dart';
import 'package:dental/models/patient.dart';
import 'package:dental/models/procedure.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Patient> patients = [];
  List<Procedure> procedures = [];

  Patient? selectedPatient;
  Procedure? selectedProcedure;
  int selectedTooth = 19; // Default tooth
  int quantity = 1;

  final List<InvoiceItem> items = [];

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadProcedures();
  }

  void _loadPatients() {
    // Replace with API call: GET /api/patients
    setState(() {
      patients = [
        Patient(id: 'a1b2c3d4', name: 'John Doe', phone: '555-1234'),
        Patient(id: 'e5f6g7h8', name: 'Jane Smith', phone: '555-5678'),
      ];
    });
  }

  void _loadProcedures() {
    // Replace with API call: GET /api/procedures
    setState(() {
      procedures = [
        Procedure(id: 1, name: 'Root Canal', price: 200.0),
        Procedure(id: 2, name: 'Filling', price: 80.0),
        Procedure(id: 3, name: 'Extraction', price: 60.0),
      ];
    });
  }

  void _addItem() {
    if (selectedPatient == null || selectedProcedure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select patient, tooth, and procedure')),
      );
      return;
    }

    final newItem = InvoiceItem(
      toothNumber: selectedTooth,
      procedure: selectedProcedure!,
      quantity: quantity,
    );

    setState(() {
      items.add(newItem);
    });

    // Reset form
    selectedProcedure = null;
    quantity = 1;
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _saveInvoice() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add at least one item to save')));
      return;
    }

    final invoiceData = {
      'patient_id': selectedPatient!.id,
      'items': items
          .map(
            (item) => {
              'tooth_number': item.toothNumber,
              'procedure_id': item.procedure.id,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
            },
          )
          .toList(),
      'total_amount': total,
    };

    // TODO: Send to backend: POST /api/invoices
    print('Saving invoice: $invoiceData');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Invoice saved successfully!')));

    Navigator.pop(context); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Select Patient
            DropdownButtonFormField<Patient>(
              value: selectedPatient,
              hint: Text('Select Patient'),
              items: patients.map((patient) {
                return DropdownMenuItem(
                  value: patient,
                  child: Text(patient.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPatient = value;
                });
              },
              decoration: InputDecoration(labelText: 'Patient'),
            ),

            SizedBox(height: 16),

            // Tooth Selection (Grid 11-48)
            Text('Select Tooth'),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(32, (index) {
                final toothNum = index + 11; // ISO 11–42
                if ([15, 16, 25, 26, 35, 36, 45, 46].contains(toothNum))
                  return SizedBox(); // skip wisdom if needed
                return FilterChip(
                  label: Text('$toothNum'),
                  selected: selectedTooth == toothNum,
                  onSelected: (_) => setState(() => selectedTooth = toothNum),
                );
              }),
            ),

            SizedBox(height: 16),

            // Procedure
            DropdownButtonFormField<Procedure>(
              value: selectedProcedure,
              hint: Text('Select Procedure'),
              items: procedures.map((proc) {
                return DropdownMenuItem(
                  value: proc,
                  child: Text(
                    '${proc.name} - \$${proc.price.toStringAsFixed(2)}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProcedure = value;
                });
              },
              decoration: InputDecoration(labelText: 'Procedure'),
            ),

            SizedBox(height: 8),

            // Quantity
            Row(
              children: [
                Text('Quantity:'),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => setState(
                    () => quantity = quantity > 1 ? quantity - 1 : 1,
                  ),
                ),
                Text('$quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => setState(() => quantity += 1),
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: _addItem,
              icon: Icon(Icons.add),
              label: Text('Add to Invoice'),
            ),

            SizedBox(height: 20),

            // Items List
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${item.toothNumber}')),
                    title: Text(item.procedure.name),
                    subtitle: Text(
                      'Qty: ${item.quantity} × \$${item.unitPrice}',
                    ),
                    trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            ),

            Divider(),

            // Total
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: _saveInvoice,
              child: Text('Save Invoice', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
