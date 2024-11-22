// services/transaction_service.dart
// ignore_for_file: unused_local_variable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../app/data/models/transaction.dart';
import '../app/modules/home/controllers/auth_controller.dart';

class TransactionService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  Future<List<Transactions>> getLastTransactions({
    
    int limit = 3,
  }) async {
    String? telephone = _authController.currentUser.value?.telephone;
    try {
      if (telephone == null) {
        throw Exception("Numéro de téléphone non disponible");
      }

      // Version temporaire en attendant la création des index
      final allTransactions = await _firestore
          .collection('transactions')
          .where('emetteur', isEqualTo: telephone)
          .get();

      final receivedTransactions = await _firestore
          .collection('transactions')
          .where('destinataire', isEqualTo: telephone)
          .get();

        final operateurTransactions = await _firestore
          .collection('transactions')
          .where('operateur', isEqualTo: telephone)
          .get();

      List<Transactions> transactions = [
        ...allTransactions.docs.map((doc) => Transactions.fromMap({
              ...doc.data(),
              'id': doc.id,
            })),
        ...receivedTransactions.docs.map((doc) => Transactions.fromMap({
              ...doc.data(),
              'id': doc.id,
            })),
         ...operateurTransactions.docs.map((doc) => Transactions.fromMap({
              ...doc.data(),
              'id': doc.id,
            }))
      ];

      // Trier manuellement
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Limiter le nombre de résultats
      return transactions.take(limit).toList();
    } catch (e) {
      print('Erreur lors de la récupération des transactions: $e');
      return [];
    }
  }


  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      transaction['reference'] = DateTime.now().millisecondsSinceEpoch.toString();
      // Vérifier que les champs requis sont présents
      if (
          !transaction.containsKey('destinataire') ||
          !transaction.containsKey('montant')) {
        throw Exception('Champs emetteur, destinataire et montant requis');
      }

      double total = double.tryParse(transaction['total'].toString()) ?? 0.0;

      //Rechercher les comptes de l'émetteur et du destinataire
      final emetteurQuerySnapshot = await _firestore
          .collection('comptes')
          .where('telephone', isEqualTo: transaction['emetteur'])
          .get();

      final destinataireQuerySnapshot = await _firestore
          .collection('comptes')
          .where('telephone', isEqualTo: transaction['destinataire'])
          .get();

      // Vérifier que les comptes existent
      // if (emetteurQuerySnapshot.docs.isEmpty ||
      //     destinataireQuerySnapshot.docs.isEmpty) {
      //   throw Exception('Un ou plusieurs comptes n\'existent pas');
      // }

      // Récupérer les données des documents
      final emetteurData = emetteurQuerySnapshot.docs.first.data();
      final destinataireData = destinataireQuerySnapshot.docs.first.data();

      // Vérifier le solde de l'émetteur
      double soldeEmetteur = (emetteurData['montant'] != null)
          ? double.tryParse(emetteurData['montant'].toString()) ?? 0.0
          : 0.0;

// Vérifier et convertir le montant de la transaction
      double montant = (transaction['montant'] != null)
          ? double.tryParse(transaction['montant'].toString()) ?? 0.0
          : 0.0;

      if (soldeEmetteur < montant) {
        throw Exception('Solde insuffisant');
      }

      // Ajouter la transaction
      transaction['date'] = Timestamp.now();
      transaction['status'] = transaction['status'] ?? 'en_attente';
      await _firestore.collection('transactions').add(transaction);

      // Mettre à jour les soldes
      await _firestore
          .collection('comptes')
          .doc(emetteurQuerySnapshot.docs.first.id)
          .update({'montant': FieldValue.increment(-total)});

      await _firestore
          .collection('comptes')
          .doc(destinataireQuerySnapshot.docs.first.id)
          .update({'montant': FieldValue.increment(montant)});

      getLastTransactions(limit: 3);

      print("transaction reussie");
    } catch (e) {
      print("transaction echoue : $e");
      throw Exception('Erreur lors de la transaction: $e');
    }
  }

 Future<void> addTransactionDistributeur(Map<String, dynamic> transaction) async {
    try {
      // Vérifier que les champs requis sont présents
      if (
          !transaction.containsKey('destinataire') ||
          !transaction.containsKey('montant')) {
        throw Exception('Champs emetteur, destinataire et montant requis');
      }

     
      //Rechercher les comptes de l'émetteur et du destinataire
      final emetteurQuerySnapshot = await _firestore
          .collection('comptes')
          .where('telephone', isEqualTo: transaction['emetteur'])
          .get();

      final destinataireQuerySnapshot = await _firestore
          .collection('comptes')
          .where('telephone', isEqualTo: transaction['destinataire'])
          .get();

      // Vérifier que les comptes existent
      // if (emetteurQuerySnapshot.docs.isEmpty ||
      //     destinataireQuerySnapshot.docs.isEmpty) {
      //   throw Exception('Un ou plusieurs comptes n\'existent pas');
      // }

      // Récupérer les données des documents
      final emetteurData = emetteurQuerySnapshot.docs.first.data();
      final destinataireData = destinataireQuerySnapshot.docs.first.data();

      // Vérifier le solde de l'émetteur
      double soldeEmetteur = (emetteurData['montant'] != null)
          ? double.tryParse(emetteurData['montant'].toString()) ?? 0.0
          : 0.0;

// Vérifier et convertir le montant de la transaction
      double montant = (transaction['montant'] != null)
          ? double.tryParse(transaction['montant'].toString()) ?? 0.0
          : 0.0;

      if (soldeEmetteur < montant) {
        throw Exception('Solde insuffisant');
      }

      // Ajouter la transaction
      transaction['date'] = Timestamp.now();
      transaction['status'] = transaction['status'] ?? 'en_attente';
      await _firestore.collection('transactions').add(transaction);

      // Mettre à jour les soldes
      await _firestore
          .collection('comptes')
          .doc(emetteurQuerySnapshot.docs.first.id)
          .update({'montant': FieldValue.increment(-montant)});

      await _firestore
          .collection('comptes')
          .doc(destinataireQuerySnapshot.docs.first.id)
          .update({'montant': FieldValue.increment(montant)});

      getLastTransactions(limit: 3);

      print("transaction reussie");
    } catch (e) {
      print("transaction echoue : $e");
      throw Exception('Erreur lors de la transaction: $e');
    }
  }

  cancelTransaction(reference) {
    _firestore.collection('transactions').doc(reference).update({'status': 'annulee'});
    //
  }

}
