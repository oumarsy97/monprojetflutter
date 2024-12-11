import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/contact.dart';
import '../controllers/auth_controller.dart';
import 'planifie/transerfert_planifie.dart';
import 'transfert/contacts_list.dart';
import 'transfert/transfert_multiple.dart';
import 'transfert/transfert_planifie.dart';
import 'transfert/transfert_simple.dart';

class QuickServices extends StatelessWidget {
  QuickServices({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Transfert',
      'icon': Icons.send,
      'color': Colors.blue,
      'action': 'transfer',
    },
    {
      'title': 'Transfert multiple',
      'icon': Icons.group,
      'color': Colors.green,
      'action': 'multiple_transfer',
    },
    {
      'title': 'Transfert programmé',
      'icon': Icons.schedule_send,
      'color': Colors.yellow,
      'action': 'scheduled_transfer',
    },
    {
      'title': 'Recharge',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'action': 'recharge',
    },
    {
      'title': 'Paiement',
      'icon': Icons.payment,
      'color': Colors.orange,
      'action': 'payment',
    },
    {
      'title': 'QR Code',
      'icon': Icons.qr_code,
      'color': Colors.purple,
      'action': 'qr_code',
    },
  ];

  void _handleAction(String action) {
    switch (action) {
      case 'transfer':
       Get.to(() => const SendMoneyPage());
        break;
      case 'multiple_transfer':
        Get.to(() => const MultipleTransferPage());
        break;
      case 'scheduled_transfer':
        // Fonctionnalité à implémenter
        Get.to(() =>  TransfertPlanifiePage());

        break;
      case 'recharge':
        // Fonctionnalité à implémenter
        break;
      case 'payment':
        // Fonctionnalité à implémenter
        break;
      case 'qr_code':
        // Fonctionnalité à implémenter
        break;
    }
  }

  void _showContactsList() {
    Get.bottomSheet(
      ContactListSheet(
        onContactsSelected: (contacts) {
          if (contacts.isNotEmpty) {
            _showTransferDialog(contacts.first); // Gérer un seul contact
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showTransferDialog(Contact contact) {
    final TextEditingController amountController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Transfert à ${contact.displayName}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Numéro: ${contact.phoneNumber}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null && amount > 0) {
                        Get.back();
                        _showConfirmationDialog(contact, amount);
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Montant invalide',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text('Continuer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(Contact contact, double amount) {
    final double fees = amount <= 500 ? 5 : amount * 0.01;
    final double total = amount + fees;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirmation du transfert',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Destinataire: ${contact.displayName}'),
              Text('Numéro: ${contact.phoneNumber}'),
              const SizedBox(height: 8),
              Text('Montant: $amount FCFA'),
              Text('Frais: $fees FCFA'),
              const Divider(),
              Text(
                'Total: $total FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final transaction = {
                          'montant': amount,
                          'frais': fees,
                          'total': total,
                          'destinataire': contact.phoneNumber,
                          'date': DateTime.now(),
                          'type': 'TRANSFERT',
                          'statut': 'EFFECTUE',
                        };

                        await authController.addTransaction(transaction);
                        Get.back();
                        Get.snackbar(
                          'Succès',
                          'Transfert effectué avec succès',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF6C38CC),
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Erreur',
                          'Erreur lors du transfert: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: const Text('Envoyer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickServiceCard(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services rapides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _services.map((service) {
                return _buildQuickServiceCard(
                  service['title'] as String,
                  service['icon'] as IconData,
                  service['color'] as Color,
                  onTap: () => _handleAction(service['action'] as String),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
