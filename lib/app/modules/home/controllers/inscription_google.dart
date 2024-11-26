import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InscriptionFormulaire extends StatelessWidget {
  final String? nomPreRempli;
  final String? prenomPreRempli;

  InscriptionFormulaire({
    this.nomPreRempli, 
    this.prenomPreRempli
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pré-remplir les champs si des informations sont disponibles
    if (nomPreRempli != null) {
      _nomController.text = nomPreRempli!;
    }
    if (prenomPreRempli != null) {
      _prenomController.text = prenomPreRempli!;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  filled: true,
                  fillColor: _nomController.text.isNotEmpty 
                    ? Colors.grey[200] 
                    : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  filled: true,
                  fillColor: _prenomController.text.isNotEmpty 
                    ? Colors.grey[200] 
                    : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  // Validation de numéro de téléphone
                  String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
                  RegExp regExp = RegExp(pattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Veuillez entrer un numéro de téléphone valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logique d'inscription
                    _inscrire();
                  }
                },
                child: Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _inscrire() {
    // Récupérer les valeurs du formulaire
    String nom = _nomController.text;
    String prenom = _prenomController.text;
    String telephone = _telephoneController.text;
    String password = _passwordController.text;

    // Appeler votre service d'inscription
    // Exemple: _authService.inscription(nom, prenom, telephone, password);
    
    // Naviguer vers l'écran principal ou afficher un message de succès
   // Get.offAll(() => EcranPrincipal());
  }
}