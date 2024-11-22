// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/contact.dart';
import '../../controllers/auth_controller.dart';
import 'contacts_list.dart';

class PlannedTransferPage extends StatefulWidget {
  const PlannedTransferPage({Key? key}) : super(key: key);

  @override
  _PlannedTransferPageState createState() => _PlannedTransferPageState();
}

class _PlannedTransferPageState extends State<PlannedTransferPage> {
  final AuthController authController = Get.find<AuthController>();
  Contact? selectedContact;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;

  void _selectContact() {
    Get.bottomSheet(
      ContactListSheet(
        multiSelect: false,
        onContactsSelected: (contacts) {
          setState(() {
            selectedContact = contacts.first;
          });
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C38CC),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showConfirmationDialog() {
    final double amount = double.tryParse(amountController.text) ?? 0;
    final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
    final double total = amount + fees;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmation du transfert planifié',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C38CC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationRow('Destinataire', selectedContact!.displayName),
                  _buildConfirmationRow('Numéro', selectedContact!.phoneNumber),
                  _buildConfirmationRow('Montant', '$amount FCFA'),
                  _buildConfirmationRow('Frais', '$fees FCFA'),
                  _buildConfirmationRow('Date de transfert', dateController.text),
                  const Divider(height: 20, color: Colors.grey),
                  Text(
                    'Total à transférer: ${total.toStringAsFixed(2)} FCFA',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!_isLoading)
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Annuler', style: TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          setState(() {
                            _isLoading = true;
                          });
                          _performPlannedTransfer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C38CC),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(
                                color: Colors.white, 
                                strokeWidth: 2,
                              )
                            )
                          : const Text('Confirmer', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.purple,
                        color: Colors.purpleAccent,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: !_isLoading,
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.textTheme.bodyMedium),
          Text(value, style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _performPlannedTransfer() async {
    try {
      final double amount = double.tryParse(amountController.text) ?? 0;
      final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
      final double total = amount + fees;

      final transaction = {
        'montant': amount,
        'frais': fees,
        'total': total,
        'destinataire': selectedContact!.phoneNumber,
        'emetteur': authController.userPhone,
        'date': _selectedDate,
        'type': 'TRANSFERT_PLANIFIE',
        'status': 'PROGRAMME'
      };

      await authController.addTransaction(transaction);
      await Future.delayed(const Duration(milliseconds: 500));

      Get.back(); // Close confirmation dialog
      Get.back(); // Close planned transfer page
      Get.snackbar(
        'Succès',
        'Transfert planifié enregistré avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6C38CC),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la planification du transfert: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfert Planifié', 
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C38CC),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _selectContact,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: Text(
                selectedContact == null 
                  ? 'Sélectionner un contact' 
                  : selectedContact!.displayName,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C38CC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à transférer',
                suffixText: 'FCFA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6C38CC)),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date de transfert',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Color(0xFF6C38CC)),
                  onPressed: () => _selectDate(context),
                ),
              ),
              onTap: () => _selectDate(context),
            ),
            const Spacer(),
            if (selectedContact != null && 
                amountController.text.isNotEmpty && 
                _selectedDate != null)
              ElevatedButton(
                onPressed: _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF6C38CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Planifier le transfert', 
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}