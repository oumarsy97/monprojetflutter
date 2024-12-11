// ignore_for_file: unused_element

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
      sign = '-';
      displayType = transaction.type;
      color = Colors.red;
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

  void _showTransactionDetails(BuildContext context, dynamic transaction, TransactionDisplay display) {
    Get.to(
      () => DetailTransactionPage(transaction: transaction, display: display),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
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
              IconButton(
                onPressed: controller.loadMoreTransactions,
                icon: const Icon(Icons.refresh, color: Color(0xFF001B5E)),
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

                return GestureDetector(
                  onTap: () => _showTransactionDetails(context, transaction, display),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: display.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              display.icon,
                              color: display.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy à HH:mm')
                                      .format(transaction.date),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${display.sign}${transaction.montant} FCFA',
                                style: TextStyle(
                                  color: display.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(transaction.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  transaction.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(transaction.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (canCancel &&
                              transaction.status.toLowerCase() == 'effectue')
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: IconButton(
                                icon: const Icon(Icons.cancel_outlined,
                                    color: Colors.red),
                                onPressed: () =>
                                    controller.showCancellationDialog(transaction),
                                tooltip: 'Annuler la transaction',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
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

class DetailTransactionPage extends StatelessWidget {
  final dynamic transaction;
  final TransactionDisplay display;

  const DetailTransactionPage({
    Key? key,
    required this.transaction,
    required this.display,
  }) : super(key: key);

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: display.color.withOpacity(0.1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: display.color,
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Détails de la transaction',
          style: TextStyle(
            color: display.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: display.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    display.icon,
                    size: 48,
                    color: display.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${display.sign}${transaction.montant} FCFA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: display.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    display.displayType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy à HH:mm').format(transaction.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de la transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Référence', transaction.reference ?? ''),
                        _buildDetailRow('Destinataire', transaction.destinataire),
                        _buildDetailRow('Montant', '${transaction.montant} FCFA'),
                        _buildDetailRow('Status', transaction.status),
                      ],
                    ),
                  ),
                  if (transaction.status.toLowerCase() == 'effectuee' )
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.find<TransactionController>()
                              .showCancellationDialog(transaction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined),
                              SizedBox(width: 8),
                              Text(
                                'Annuler la transaction',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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