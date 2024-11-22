import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/transaction_service.dart';
import '../../../data/models/Compte.dart';

class AuthController extends GetxController  {
  
  final AuthService _authService = Get.find<AuthService>();
  //final TransactionService _transactionService = Get.find<TransactionService>();

  // État de l'utilisateur
  Rx<Compte?> currentUser = Rx<Compte?>(null);

  // États pour le chargement et les erreurs
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  // Données supplémentaires de l'utilisateur
  final userData = <String, dynamic>{}.obs;

  // Liste des transactions
  final RxList<Map<String, dynamic>> _transactions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      isLoading.value = true;
      error.value = '';

      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        currentUser.value = (await _authService.getUserById(firebaseUser.uid)) as Compte?;
        await refreshUserData(); // Centralisation du chargement des données
      }
    } catch (e) {
      error.value = 'Erreur lors du chargement de l’utilisateur: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (currentUser.value != null) {
        userData.assignAll({
          'email': currentUser.value?.email ?? '',
          'telephone': currentUser.value?.telephone ?? '',
          'montant': currentUser.value?.montant ?? 0.0,
          'limiteMensuelle': currentUser.value?.limiteMensuelle ?? 0.0,
          'statut': currentUser.value?.statut ?? '',
          'nom': currentUser.value?.nom ?? '',
          'prenom': currentUser.value?.prenom ?? '',
        });
      }
    } catch (e) {
      error.value = 'Erreur lors du chargement des données utilisateur: $e';
    }
  }

  Future<bool> loginWithGoogle() async {
    Compte? compte = await _authService.connexionAvecGoogle();
    if (compte != null) {
      currentUser.value = compte;
      await refreshUserData();
      
      return true;
      }
    
    return false;
  }

Future<bool> connexionParTelephone(String telephone) async {
  try {
    isLoading.value = true;
    error.value = '';

    // Formatage du numéro de téléphone (ajustez selon vos besoins)
    String phoneNumber = '+225$telephone'; // Préfixe pour la Côte d'Ivoire

    // Méthode de vérification de téléphone
    Compte? result = await _authService.connexionParTelephone(phoneNumber);
    
    if (result != null) {
      currentUser.value = result;
      await refreshUserData();
      return true;
    }
    return false;
  } catch (e) {
    error.value = 'Erreur lors de la connexion par téléphone: $e';
    return false;
  } finally {
    isLoading.value = false;
  }
}

// Méthode pour vérifier l'OTP
Future<bool> verifierOTP(String telephone, String otp) async {
  try {
    isLoading.value = true;
    error.value = '';

    // Formatage du numéro de téléphone
    String phoneNumber = '+221$telephone';

    await _authService.verifierNumeroTelephone( otp);
    
   
      await refreshUserData();
      return true;
    
   
  } catch (e) {
    error.value = 'Erreur de vérification OTP: $e';
    return false;
  } finally {
    isLoading.value = false;
  }
}
 
  Future<void> refreshUserData() async {
    try {
      isLoading.value = true;
      await _loadUserData();
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour des données: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    try {
      isLoading.value = true;

      transaction['reference'] = DateTime.now().millisecondsSinceEpoch.toString();
    //  await _transactionService.addTransaction(transaction);

      await refreshUserData();
    } catch (e) {
      error.value = 'Erreur lors de l’ajout de la transaction: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> inscription(Compte compte) async {
    try {
      isLoading.value = true;
      error.value = '';

      Compte? result = await _authService.creerCompte(compte);
      if (result != null) {
        currentUser.value = result;
        await refreshUserData();
        return true;
      }
      return false;
    } catch (e) {
      error.value = 'Erreur lors de l’inscription: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> connexion(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      Compte? result = await _authService.connexion(email, password);
      if (result != null) {
        currentUser.value = result;
        await refreshUserData();
        return true;
      }
      return false;
    } catch (e) {
      error.value = 'Erreur lors de la connexion: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deconnexion() async {
    try {
       _authService.deconnexion();
      currentUser.value = null;
      userData.clear();
      _transactions.clear();
    } catch (e) {
      error.value = 'Erreur lors de la déconnexion: $e';
    }
  }

  // Getters
  bool get isUserConnected => currentUser.value != null;
  String get userEmail => userData['email'] as String? ?? '';
  String get userPhone => userData['telephone'] as String? ?? '';
  double get userBalance => (userData['montant'] as num?)?.toDouble() ?? 0.0;

  List<Map<String, dynamic>> get userTransactions => _transactions.toList();
}