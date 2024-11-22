// transaction_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import 'package:intl/intl.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({Key? key}) : super(key: key);

  TransactionDisplay getTransactionDisplay(transaction) {
    final currentUserPhone =
        controller.authController.currentUser.value?.telephone;
    final isDeposit = transaction.type == 'DEPOT';
    final isRetrait = transaction.type == 'RETRAIT';
    final isTransfert = transaction.type == 'TRANSFERT';
    final isUserSender = transaction.emetteur == currentUserPhone;
    final isUserReceiver = transaction.destinataire == currentUserPhone;

    String sign;
    String displayType;
    Color color;
    IconData icon;

    if (isDeposit && isUserSender) {
      sign = '-';
      displayType = 'Dépôt envoyé';
      color = Colors.red;
      icon = Icons.arrow_upward;
    } else if (isDeposit && isUserReceiver) {
      sign = '+';
      displayType = 'Dépôt reçu';
      color = Colors.green;
      icon = Icons.arrow_downward;
    } else if (isRetrait && isUserSender) {
      sign = '-';
      displayType = 'Retrait effectué';
      color = Colors.orange;
      icon = Icons.logout;
    } else if (isTransfert && isUserSender) {
      sign = '-';
      displayType = 'Transfert envoyé';
      color = Colors.red;
      icon = Icons.send;
    } else if (isTransfert && isUserReceiver) {
      sign = '+';
      displayType = 'Transfert reçu';
      color = Colors.green;
      icon = Icons.call_received;
    } else {
      sign = '+';
      displayType = transaction.type;
      color = Colors.blue;
      icon = Icons.swap_horiz;
    }

    return TransactionDisplay(
      sign: sign,
      displayType: displayType,
      color: color,
      icon: icon,
    );
  }

  bool canCancelTransaction(DateTime transactionDate) {
    final now = DateTime.now();
    final difference = now.difference(transactionDate);
    return difference.inMinutes < 30;
  }

  String _formatPhoneNumber(String phone) {
    if (phone.length == 9) {
      return '${phone.substring(0, 2)} ${phone.substring(2, 5)} ${phone.substring(5, 7)} ${phone.substring(7)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transactions récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001B5E),
                ),
              ),
              TextButton.icon(
                onPressed: controller.loadMoreTransactions,
                icon: const Icon(Icons.refresh, color: Color(0xFF001B5E)),
                label: const Text(
                  '',
                  style: TextStyle(
                    color: Color(0xFF001B5E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value && controller.transactions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF001B5E)),
                ),
              );
            }

            if (controller.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune transaction récente',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
                final display = getTransactionDisplay(transaction);
                final canCancel = canCancelTransaction(transaction.date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: display.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        display.icon,
                        color: display.color,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                display.displayType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy à HH:mm')
                                    .format(transaction.date),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${display.sign}${transaction.montant.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            color: display.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow(
                                'Référence', transaction.reference ?? ''),
                            _buildDetailRow('Destinataire',
                                _formatPhoneNumber(transaction.destinataire)),
                            _buildDetailRow(
                                'Montant', '${transaction.montant} FCFA'),
                            _buildDetailRow('Status', transaction.status),
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(transaction.status),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                transaction.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (canCancel && transaction.status.toLowerCase() == 'effectue')
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ElevatedButton.icon(
                                  onPressed: () => controller.showCancellationDialog(transaction),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Annuler la transaction'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'effectue':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class TransactionDisplay {
  final String sign;
  final String displayType;
  final Color color;
  final IconData icon;

  TransactionDisplay({
    required this.sign,
    required this.displayType,
    required this.color,
    required this.icon,
  });
}