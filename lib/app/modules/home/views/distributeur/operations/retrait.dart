// ignore_for_file: prefer_initializing_formals, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/transaction_controller.dart';

class RetraitFormPage extends StatefulWidget {
  final String destinataireNumero;
  const RetraitFormPage({Key? key, required String destinataireNumero})
      : destinataireNumero = destinataireNumero,
        super(key: key);

  @override
  _RetraitFormPageState createState() => _RetraitFormPageState();
}

class _RetraitFormPageState extends State<RetraitFormPage> {
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroRetraitController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final currencyFormat =
      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Retrait',
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

                      // Affichage du numéro de téléphone
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Numéro de retrait',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone, 
                                    color: const Color(0xFF001F5C),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.destinataireNumero,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildNumeroRetraitField() {
    return TextFormField(
      controller: _numeroRetraitController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Numéro de retrait',
        hintText: 'Entrez le numéro de téléphone',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un numéro de téléphone';
        }
        // Ajoutez ici vos propres règles de validation de numéro de téléphone
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
        labelText: 'Montant du retrait',
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
        if (montant > authController.userBalance) {
          return 'Solde insuffisant';
        }
        //recuperer le montant du client
        
        // Ajoutez des règles supplémentaires si nécessaire (montant minimum, etc.)
        return null;
      },
    );
  }

  Widget _buildConfirmationButton() {
    return ElevatedButton(
      onPressed: _confirmerRetrait,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001F5C),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Confirmer le Retrait',
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

  void _confirmerRetrait() {
    if (_formKey.currentState!.validate()) {
      int montant = int.parse(_montantController.text);
      String numeroRetrait = _numeroRetraitController.text;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirmation de Retrait',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Voulez-vous confirmer un retrait de ${currencyFormat.format(montant)} vers le numéro $numeroRetrait ?',
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
                _executerRetrait(montant);
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

  void _executerRetrait(int montant) async {
    // Utiliser directement widget.destinataireNumero au lieu d'un contrôleur
    final success = await transactionController.effectuerRetrait(
        widget.destinataireNumero, montant);

    if (success) {
      _showSuccessDialog(montant, widget.destinataireNumero);
    } else {
      _showErrorDialog(transactionController.error.value);
    }
  }


  void _showSuccessDialog(int montant, String numeroRetrait) {
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
              'Retrait Réussi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Montant retiré : ${currencyFormat.format(montant)}',
              style: GoogleFonts.poppins(),
            ),
            Text(
              'Numéro de retrait : $numeroRetrait',
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
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF001F5C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _numeroRetraitController.dispose();
    super.dispose();
  }
}
