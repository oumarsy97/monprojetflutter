import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/models/Compte.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _verificationId;
  bool _codeSent = false;
  bool _isNewUser = false;

  Future<void> verifyPhone() async {
    try {
      // Vérifier si le compte existe déjà
      var comptes = await chercherCompte(telephone: _phoneController.text);
      setState(() {
        _isNewUser = comptes.isEmpty;
      });

      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-vérification sur Android
          await signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: Duration(seconds: 200),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (_isNewUser) {
        // Créer un nouveau compte
        // Compte nouveauCompte = Compte(
        //   id: userCredential.user!.uid,
        //   telephone: _phoneController.text,
        //   nom: _nomController.text,
        //   prenom: _prenomController.text,
        //   // Ajoutez d'autres champs selon votre modèle Compte
        // );
        
        // await _firestore
        //     .collection('comptes')
        //     .doc(nouveauCompte.id)
        //     .set(nouveauCompte.toMap());
      }
      
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> verifyCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );
      await signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code incorrect')),
      );
    }
  }

  Future<List<Compte>> chercherCompte({String? telephone}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('comptes')
          .where('telephone', isEqualTo: telephone)
          .get();

      return querySnapshot.docs
          .map((doc) => Compte.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur recherche de compte: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentification par téléphone')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone (ex: +33612345678)',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifyPhone,
                child: Text('Envoyer le code'),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Code de vérification'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              if (_isNewUser) ...[
                TextField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _prenomController,
                  decoration: InputDecoration(labelText: 'Prénom'),
                ),
                SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: verifyCode,
                child: Text('Vérifier le code'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}