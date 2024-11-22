// ignore_for_file: prefer_initializing_formals, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/transaction_controller.dart';

class DepotFormPage extends StatefulWidget {
  final String destinataireNumero;
  const DepotFormPage({Key? key, required String destinataireNumero})
      : destinataireNumero = destinataireNumero,
        super(key: key);

  @override
  _DepotFormPageState createState() => _DepotFormPageState();
}

class _DepotFormPageState extends State<DepotFormPage> {
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroEmetteurController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final currencyFormat =
      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
  final int plafondDepot = 1000000; // Plafond du dépôt

  @override
  void initState() {
    super.initState();
    // Pre-fill the destinataire number if provided
    _numeroEmetteurController.text = widget.destinataireNumero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dépôt',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF001F5C),
        centerTitle: true,
      ),
      body: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Solde disponible
                      _buildSoldeCard(),
                      const SizedBox(height: 20),

                      // Champ du numéro de l'émetteur
                      _buildNumeroEmetteurField(),
                      const SizedBox(height: 20),

                      // Champ de montant
                      _buildMontantField(),
                      const SizedBox(height: 20),

                      // Bouton de confirmation
                      _buildConfirmationButton(),
                    ],
                  ),
                ),
              ),

              // Indicateur de chargement
              if (transactionController.isLoading.value) _buildLoadingOverlay(),
            ],
          )),
    );
  }

  Widget _buildSoldeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Solde disponible',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              currencyFormat.format(authController.userBalance),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF001F5C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumeroEmetteurField() {
    return TextFormField(
      controller: _numeroEmetteurController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Numéro de l\'émetteur',
        hintText: 'Entrez le numéro de téléphone de l\'émetteur',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un numéro de téléphone';
        }
        if (value.length < 9) {
          return 'Numéro de téléphone invalide';
        }
        return null;
      },
    );
  }

  Widget _buildMontantField() {
    return TextFormField(
      controller: _montantController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Montant du dépôt',
        prefixText: 'FCFA ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un montant';
        }
        final montant = int.tryParse(value);
        if (montant == null || montant <= 0) {
          return 'Veuillez entrer un montant valide';
        }
        // Vérification du plafond
        if (montant > plafondDepot) {
          return 'Le montant dépasse le plafond de dépôt';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmationButton() {
    return ElevatedButton(
      onPressed: _confirmerDepot,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001F5C),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Confirmer le Dépôt',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  void _confirmerDepot() {
    if (_formKey.currentState!.validate()) {
      int montant = int.parse(_montantController.text);
      String numeroEmetteur = _numeroEmetteurController.text;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirmation de Dépôt',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Voulez-vous confirmer un dépôt de ${currencyFormat.format(montant)} depuis le numéro $numeroEmetteur ?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executerDepot(numeroEmetteur, montant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F5C),
              ),
              child: Text(
                'Confirmer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _executerDepot(String numeroEmetteur, int montant) async {
    final success =
        await transactionController.effectuerDepot(numeroEmetteur, montant);

    if (success) {
      _showSuccessDialog(montant, numeroEmetteur);
    } else {
      _showErrorDialog(transactionController.error.value);
    }
  }

  void _showSuccessDialog(int montant, String numeroEmetteur) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dépôt Réussi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Montant déposé : ${currencyFormat.format(montant)}',
              style: GoogleFonts.poppins(),
            ),
            Text(
              'Numéro de l\'émetteur : $numeroEmetteur',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Retour à l'écran précédent
            },
            child: Text(
              'Terminer',
              style: GoogleFonts.poppins(color: const Color(0xFF001F5C)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Erreur',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
