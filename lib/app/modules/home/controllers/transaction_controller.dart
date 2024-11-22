
// ignore_for_file: unused_local_variable

// transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprojectgetx/app/modules/home/controllers/auth_controller.dart';

import '../../../../services/transaction_service.dart';
import '../../../data/models/transaction.dart';

class TransactionController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final TransactionService _transactionService = TransactionService();
  
  RxList<Transactions> transactions = <Transactions>[].obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // S'assurer que l'AuthController est initialisé
    ever(authController.currentUser, (_) {
      loadTransactions();
    });
    loadTransactions();
  }

  Future<void> loadTransactions({int limit = 3}) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final telephone = authController.currentUser.value?.telephone;
      
      if (telephone == null || telephone.isEmpty) {
        error.value = 'Numéro de téléphone non disponible';
        return;
      }

      final results = await _transactionService.getLastTransactions(
        limit: limit,
      );
      
      transactions.value = results;
    } catch (e) {
      error.value = 'Erreur lors du chargement des transactions: $e';
      print('Erreur dans le controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreTransactions() {
    loadTransactions(limit: transactions.length + 3);
  }

  Future<bool> effectuerDepot(String destinataireNumero, int montant) async {
  isLoading.value = true;
  error.value = '';

  try {
    // Appeler le service de transaction pour effectuer le dépôt
    final transactionResult = await _transactionService.addTransactionDistributeur(
      {
        'destinataire': destinataireNumero,
        'emetteur': authController.currentUser.value?.telephone,
        'status': 'COMPLETE',
        'type': 'DEPOT',
        'montant': montant,
      },
    );

    // Mettre à jour le solde de l'utilisateur après le dépôt
  //  await authController.refreshUserBalance();

    // Recharger les transactions pour refléter la nouvelle transaction
    await loadTransactions();

    return true;
  } catch (e) {
    error.value = 'Erreur lors du dépôt: $e';
    print('Erreur de dépôt dans le controller: $e');
    return false;
  } finally {
    isLoading.value = false;
  }
}

Future<bool> effectuerRetrait(String numeroRetrait, int montant) async {
  isLoading.value = true;
  error.value = '';

  try {
    // Valider le montant
    if (montant <= 0) {
      error.value = 'Le montant doit être supérieur à zéro';
      return false;
    }

    if (montant > authController.userBalance) {
      error.value = 'Solde insuffisant';
      return false;
    }

    // Appeler le service de transaction pour effectuer le retrait
    final transactionResult = await _transactionService.addTransaction(
      {
        'destinataire': numeroRetrait,
        'operateur': authController.currentUser.value?.telephone,
        'type': 'RETRAIT',
        'montant': montant,
      },
    );

    // Mettre à jour le solde de l'utilisateur après le retrait
   // await authController.refreshUserBalance();

    // Recharger les transactions pour refléter la nouvelle transaction
    await loadTransactions();

    return true;
  } catch (e) {
    error.value = 'Erreur lors du retrait: $e';
    print('Erreur de retrait dans le controller: $e');
    return false;
  } finally {
    isLoading.value = false;
  }
}

   void showCancellationDialog(transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment annuler cette transaction ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelTransaction(transaction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> cancelTransaction(transaction) async {
    try {
      // Afficher l'indicateur de chargement
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Appeler l'API pour annuler la transaction
      await _transactionService.cancelTransaction(transaction.reference);
      
      // Rafraîchir la liste des transactions
      await loadTransactions();
      
      // Fermer l'indicateur de chargement
      Get.back();
      
      // Afficher le message de succès
      Get.snackbar(
        'Succès',
        'La transaction a été annulée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Fermer l'indicateur de chargement
      Get.back();
      
      // Afficher le message d'erreur
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler la transaction: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


}