import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/contact.dart';
import '../../controllers/auth_controller.dart';
import 'contacts_list.dart';

class MultipleTransferPage extends StatefulWidget {
  const MultipleTransferPage({Key? key}) : super(key: key);

  @override
  _MultipleTransferPageState createState() => _MultipleTransferPageState();
}

class _MultipleTransferPageState extends State<MultipleTransferPage> {
  final AuthController authController = Get.find<AuthController>();
  List<Contact> selectedContacts = [];
  final TextEditingController amountController = TextEditingController();
  bool _isLoading = false;

  void _selectContacts() {
    Get.bottomSheet(
      ContactListSheet(
        multiSelect: true,
        onContactsSelected: (contacts) {
          setState(() {
            selectedContacts = contacts;
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

  void _removeContact(Contact contact) {
    setState(() {
      selectedContacts.remove(contact);
    });
  }

  void _showConfirmationDialog() {
    final double amount = double.tryParse(amountController.text) ?? 0;
    final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
    final double total = amount + fees;
    final double totalTransfer = total * selectedContacts.length;

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
                    'Confirmation du transfert multiple',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C38CC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationRow('Nombre de destinataires', '${selectedContacts.length}'),
                  _buildConfirmationRow('Montant par destinataire', '$amount FCFA'),
                  _buildConfirmationRow('Frais par transfert', '$fees FCFA'),
                  const Divider(height: 20, color: Colors.grey),
                  Text(
                    'Total à transférer: ${totalTransfer.toStringAsFixed(2)} FCFA',
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
                          _performMultipleTransfer();
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

  Future<void> _performMultipleTransfer() async {
    try {
      final double amount = double.tryParse(amountController.text) ?? 0;
      final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
      final double total = amount + fees;

      for (var contact in selectedContacts) {
        final transaction = {
          'montant': amount,
          'frais': fees,
          'total': total,
          'destinataire': contact.phoneNumber,
          'emetteur': authController.userPhone,
          'date': DateTime.now(),
          'type': 'TRANSFERT_MULTIPLE',
          'status': 'EFFECTUE'
        };

        await authController.addTransaction(transaction);
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Get.back(); // Close confirmation dialog
      Get.back(); // Close multiple transfer page
      Get.snackbar(
        'Succès',
        'Transferts multiples effectués avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6C38CC),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors des transferts: ${e.toString()}',
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
          'Transfert Multiple', 
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
              onPressed: _selectContacts,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ajouter des contacts', style: TextStyle(color: Colors.white)),
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
                labelText: 'Montant par destinataire',
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
            const Text(
              'Contacts sélectionnés:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: selectedContacts.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun contact sélectionné',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedContacts.length,
                      itemBuilder: (context, index) {
                        final contact = selectedContacts[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              contact.displayName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(contact.phoneNumber),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeContact(contact),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (selectedContacts.isNotEmpty && amountController.text.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    _showConfirmationDialog();
                  } else {
                    Get.snackbar(
                      'Erreur',
                      'Veuillez saisir un montant valide',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF6C38CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Procéder aux transferts', 
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}