// ignore_for_filed_print

// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monprojectgetx/app/data/models/contact.dart';

import '../app/core/utils/crypto_utils.dart';
import '../app/data/models/Compte.dart';
import '../app/modules/home/views/inscription_view.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Variables pour l'authentification par téléphone
  String? _verificationId;


  // Création de contact favori
  Future<Contact?> creerContact(Contact contact) async  {
  try {
    // Vérifier que l'utilisateur est connecté
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("Aucun utilisateur connecté");
      return null;
    }

    // Référence du document du compte
    DocumentReference compteRef = _firestore.collection('comptes').doc(currentUser.uid);

    // Récupérer le document du compte
    DocumentSnapshot compteSnapshot = await compteRef.get();
    
    // Convertir le document en objet Compte
    Compte compte = Compte.fromMap(compteSnapshot.data() as Map<String, dynamic>);

    // Ajouter l'ID unique au contact
    contact.id = _firestore.collection('contacts').doc().id;

    // Sauvegarde du contact dans la sous-collection 'contacts' du compte
    await compteRef.collection('contacts').doc(contact.id).set(contact.toMap());

    // Mettre à jour la liste des contacts favoris dans l'objet Compte
    // (Assurez-vous que votre modèle Compte a une liste de contacts)
    compte.contactsFavoris ??= [];
    compte.contactsFavoris!.add(contact);

    // Mettre à jour le document du compte
    await compteRef.update({
      'contactsFavoris': compte.contactsFavoris?.map((c) => c.toMap()).toList()
    });

    return contact;
  } catch (e) {
    print("Erreur création contact: $e");
    return null;
  }
}
  // Création de compte standard
  Future<Compte?> creerCompte(Compte compte) async {
    try {
      // Crypter le mot de passe avant de l'envoyer à Firebase
      String hashedPassword = CryptoUtils.hashPassword(compte.password);

      // Authentification Firebase avec email et mot de passe
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: compte.email!,
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
          verificationId: _verificationId!, smsCode: smsCode);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

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
  Future<List<Compte>> chercherCompte(
      {String? email, String? telephone, String? nom, String? prenom}) async {
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
    try {
      // 1. Tentative de connexion avec Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si l'utilisateur annule la connexion
      if (googleUser == null) return null;

      // 2. Obtention des credentials d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Connexion à Firebase avec les credentials Google
      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;
      final nom = googleUser.displayName?.split(' ').first;
      final prenom = googleUser.displayName?.split(' ').last;
      final email = googleUser.email;
      final photoUrl = googleUser.photoUrl;

      print("Connexion Google avec l'utilisateur $uid");
      print("Nom: $nom");
      print("Email: $email");
      print("Photo URL: $photoUrl");

      // 4. Vérification de l'existence du compte dans Firestore
      final compteDoc = await _firestore.collection('comptes').doc(uid).get();

      // 5. Si le compte n'existe pas, redirection vers le formulaire d'inscription
      if (!compteDoc.exists) {
        Get.to(
          () => InscriptionView(
            nom: nom,
            prenom: prenom,
            email: email,
          ),
        );
        return null;
      }

      // 6. Conversion du document Firestore en objet Compte
      return Compte.fromMap({
        'id': uid,
        ...compteDoc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      print('Erreur de connexion Google : $e');
      return null;
    }
  }

 Future<Compte?> loginWithFacebook() async {
  try {
    // 1. Tentative de connexion avec Facebook
    final LoginResult result = await FacebookAuth.instance.login();
    
    // Vérifier le statut de la connexion
    if (result.status == LoginStatus.success) {
      // 2. Obtention des credentials d'authentification Facebook
      final AccessToken accessToken = result.accessToken!;
      
      // Debug: Print out available properties
      print('Access Token Details:');
      print('Token String: ${accessToken.toString()}');
      
      // 3. Connexion à Firebase avec les credentials Facebook
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(accessToken.toString());

      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
      final user = userCredential.user!;

      // Récupérer les informations de l'utilisateur Facebook
      final userData = await FacebookAuth.instance.getUserData();
      
      final uid = user.uid;
      final nom = userData['first_name'];
      final prenom = userData['last_name'];
      final email = userData['email'];
      
      print("Connexion Facebook avec l'utilisateur $uid");
      print("Nom: $nom");
      print("Email: $email");

      // 4. Vérification de l'existence du compte dans Firestore
      final compteDoc = await _firestore.collection('comptes').doc(uid).get();

      // 5. Si le compte n'existe pas, redirection vers le formulaire d'inscription
      if (!compteDoc.exists) {
        Get.to(
          () => InscriptionView(
            nom: nom,
            prenom: prenom,
            email: email,
          ),
        );
        return null;
      }

      // 6. Conversion du document Firestore en objet Compte
      return Compte.fromMap({
        'id': uid,
        ...compteDoc.data() as Map<String, dynamic>,
      });
    } else {
      print('Échec de connexion Facebook: ${result.status}');
      return null;
    }
  } catch (e) {
    print('Erreur de connexion Facebook : $e');
    return null;
  }
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

  findByFacebookId(String facebookId) {
    return _firestore
        .collection('comptes')
        .where('id', isEqualTo: facebookId)
        .get();
  }

  Future<List<Map<String, dynamic>>> getContactsFavoris() async  {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("Aucun utilisateur connecté");
        return [];
      }

      // Référence du document du compte
      DocumentReference compteRef = _firestore.collection('comptes').doc(currentUser.uid);

      // Récupérer la sous-collection de contacts
      QuerySnapshot contactsSnapshot = await compteRef.collection('contacts').get();

      // Récupérer les documents de la sous-collection
      List<Map<String, dynamic>> contacts = [];
      for (DocumentSnapshot contactSnapshot in contactsSnapshot.docs) {
        Map<String, dynamic> contact = contactSnapshot.data() as Map<String, dynamic>;
        contacts.add(contact);
      }

      return contacts;
     
    } catch (e) {
      print("Erreur récupération des contacts favoris: $e");
      return [];
    }
  }

  Future<bool> supprimerContactFavori(String contactId) async  {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("Aucun utilisateur connecté");
      return false;
    }

    // Référence du document du compte
    DocumentReference compteRef = _firestore.collection('comptes').doc(currentUser.uid);

    // Supprimer le contact favori
    await compteRef.collection('contacts').doc(contactId).delete();

    return true;
  }

  
}
