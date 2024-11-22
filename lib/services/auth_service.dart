import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../app/core/utils/crypto_utils.dart';
import '../app/data/models/Compte.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Variables pour l'authentification par téléphone
  String? _verificationId;

  // Création de compte standard
  Future<Compte?> creerCompte(Compte compte) async {
    try {
      // Crypter le mot de passe avant de l'envoyer à Firebase
      String hashedPassword = CryptoUtils.hashPassword(compte.password);

      // Authentification Firebase avec email et mot de passe
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: compte.email,
              password: compte.password // Firebase gère son propre cryptage
              );

      // Ajouter l'ID Firebase et le mot de passe crypté
      compte.id = userCredential.user!.uid;
      compte.password = hashedPassword; // Stocke le mot de passe crypté

      // Sauvegarde dans Firestore
      await _firestore.collection('comptes').doc(compte.id).set(compte.toMap());

      return compte;
    } catch (e) {
      print("Erreur création compte: $e");
      return null;
    }
  }

  // Connexion standard
  Future<Compte?> connexion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Récupérer les infos du compte
      DocumentSnapshot compteDoc = await _firestore
          .collection('comptes')
          .doc(userCredential.user!.uid)
          .get();

      return Compte.fromMap(compteDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Erreur connexion: $e");
      return null;
    }
  }

  // Nouvelle méthode : Connexion par téléphone - Envoi du code de vérification
  Future<void> verifierNumeroTelephone(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Connexion automatique réussie
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Erreur de vérification : ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Stocker l'ID de vérification pour une utilisation ultérieure
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Connexion avec le code SMS
  Future<Compte?> connexionParTelephone(String smsCode) async {
    try {
      if (_verificationId == null) {
        print("Aucun code de vérification n'a été envoyé");
        return null;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, 
        smsCode: smsCode
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Vérifier si le compte existe déjà
      DocumentSnapshot compteDoc = await _firestore
          .collection('comptes')
          .doc(userCredential.user!.uid)
          .get();

      // // Si le compte n'existe pas, le créer
      // if (!compteDoc.exists) {
      //   Compte nouveauCompte = Compte(
      //     id: userCredential.user!.uid,
      //     telephone: userCredential.user!.phoneNumber,

      //   );
      //   await _firestore.collection('comptes').doc(nouveauCompte.id).set(nouveauCompte.toMap());
      //   return nouveauCompte;
      // }

      return Compte.fromMap(compteDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Erreur connexion par téléphone: $e");
      return null;
    }
  }

  // Méthode pour chercher un compte par différents critères
  Future<List<Compte>> chercherCompte({
    String? email, 
    String? telephone, 
    String? nom, 
    String? prenom
  }) async {
    try {
      Query query = _firestore.collection('comptes');

      // Construire la requête dynamiquement
      if (email != null) {
        query = query.where('email', isEqualTo: email);
      }
      if (telephone != null) {
        query = query.where('telephone', isEqualTo: telephone);
      }
      if (nom != null) {
        query = query.where('nom', isEqualTo: nom);
      }
      if (prenom != null) {
        query = query.where('prenom', isEqualTo: prenom);
      }

      // Exécuter la requête
      QuerySnapshot querySnapshot = await query.get();

      // Convertir les résultats en liste de Compte
      return querySnapshot.docs
          .map((doc) => Compte.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur recherche de compte: $e");
      return [];
    }
  }

  // Reste des méthodes existantes (connexionAvecGoogle, getUserById, etc.)
  Future<Compte?> connexionAvecGoogle() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Récupérer les infos du compte
    DocumentSnapshot compteDoc = await _firestore
        .collection('comptes')
        .doc(userCredential.user!.uid)
        .get();

    return Compte.fromMap(compteDoc.data() as Map<String, dynamic>);
  }

  // Méthode pour obtenir un utilisateur par son ID
  Future<DocumentSnapshot> getUserById(String uid) {
    return _firestore.collection('comptes').doc(uid).get();
  }

  // Déconnexion (standard et Google)
  Future<void> deconnexion() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Erreur de déconnexion: $e");
    }
  }

  // Vérifier si un utilisateur est connecté
  User? get currentUser => _auth.currentUser;

  // Listener pour les changements d'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}