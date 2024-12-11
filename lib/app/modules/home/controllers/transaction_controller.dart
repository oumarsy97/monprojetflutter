// ignore_for_file: unused_local_variable

// transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprojectgetx/app/modules/home/controllers/auth_controller.dart';

import '../../../../services/transaction_service.dart';
import '../../../data/models/planification.dart';
import '../../../data/models/transaction.dart';

class TransactionController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final TransactionService _transactionService = TransactionService();

  RxList<Transactions> transactions = <Transactions>[].obs;
  final RxList<Planification> planifications = <Planification>[].obs;

  // Stream pour les planifications en temps réel
  late Stream<List<Planification>> planificationsStream;

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
    initPlanificationsStream();
  }

  void initPlanificationsStream() {
    try {
      planificationsStream = _transactionService.getPlanifiedTransfers();
      planificationsStream.listen(
        (data) {
          planifications.value = data;
        },
        onError: (err) {
          error.value = 'Erreur de chargement: $err';
          print('Erreur de streaming: $err');
        },
      );
    } catch (e) {
      error.value = 'Erreur d\'initialisation: $e';
      print('Erreur d\'initialisation du stream: $e');
    }
  }

 
  // Mettre à jour une planification
  Future<void> updatePlanification(String id, Planification planification) async {
    try {
      isLoading.value = true;
      await _transactionService.updatePlanifiedTransfer(id, planification);
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour: $e';
      print('Erreur de mise à jour: $e');
    } finally {
      isLoading.value = false;
    }
  }

    // Supprimer une planification
  Future<void> deletePlanification(String id) async {
    try {
      isLoading.value = true;
      await _transactionService.deletePlanifiedTransfer(id);
    } catch (e) {
      error.value = 'Erreur lors de la suppression: $e';
      print('Erreur de suppression: $e');
    } finally {
      isLoading.value = false;
    }
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
      final transactionResult =
          await _transactionService.addTransactionDistributeur(
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

  void showCancellationDialog(dynamic transaction) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Annulation de la transaction',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir annuler cette transaction ?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Référence: ${transaction.reference}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              'Montant: ${transaction.montant} FCFA',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cancelTransaction(transaction);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
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

  //add planifie
  Future<bool> addPlanifie(Map<String, dynamic> data) async {
    isLoading.value = true;
    error.value = '';

    try {
      // Appeler le service de transaction pour effectuer le retrait
      final transactionResult =
          await _transactionService.addTransactionprogrammes(
        {
          'destinataire_telephone': data['destinataire'],
          'emetteur_telephone': authController.currentUser.value?.telephone,
          'type': data['type'],
          'date_prochaine_execution': data['date'],
          'montant': data['montant'],
          'heure': data['heure'],
          'minute': data['minute'],
        },
      );
      Get.back();
      Get.back();


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

  Future<void> addTransaction( Map<String, dynamic> transaction) async {
    try {
      isLoading.value = true;

      transaction['reference'] = DateTime.now().millisecondsSinceEpoch.toString();
      await _transactionService.addTransaction(transaction);
      await loadTransactions();

      isLoading.value = false;    } catch (e) {
      error.value = 'Erreur lors de l’ajout de la transaction: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
