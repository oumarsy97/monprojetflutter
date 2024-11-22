// ignore_for_file: prefer_initializing_formals, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PaiementFormPage extends StatefulWidget {
  final String beneficiaireNumero;
  const PaiementFormPage({Key? key, required String beneficiaireNumero})
      : beneficiaireNumero = beneficiaireNumero,
        super(key: key);

  @override
  _PaiementFormPageState createState() => _PaiementFormPageState();
}

class _PaiementFormPageState extends State<PaiementFormPage> {
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroBeneficiaireController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
  final int plafondPaiement = 2000000;

  @override
  void initState() {
    super.initState();
    _numeroBeneficiaireController.text = widget.beneficiaireNumero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paiement',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF001F5C),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSoldeCard(),
              const SizedBox(height: 20),
              _buildBeneficiaireField(),
              const SizedBox(height: 20),
              _buildMontantField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildConfirmationButton(),
            ],
          ),
        ),
      ),
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
              currencyFormat.format(50000), // Replace with actual balance
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

  Widget _buildBeneficiaireField() {
    return TextFormField(
      controller: _numeroBeneficiaireController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Numéro du bénéficiaire',
        hintText: 'Entrez le numéro du bénéficiaire',
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
        labelText: 'Montant du paiement',
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
        if (montant > plafondPaiement) {
          return 'Le montant dépasse le plafond de paiement';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Motif du paiement',
        hintText: 'Description optionnelle',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return ElevatedButton(
      onPressed: _confirmerPaiement,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001F5C),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Confirmer le Paiement',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _confirmerPaiement() {
    if (_formKey.currentState!.validate()) {
      int montant = int.parse(_montantController.text);
      String numeroBeneficiaire = _numeroBeneficiaireController.text;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirmation de Paiement',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Voulez-vous confirmer un paiement de ${currencyFormat.format(montant)} au numéro $numeroBeneficiaire ?',
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
                _executerPaiement(numeroBeneficiaire, montant);
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

  void _executerPaiement(String numeroBeneficiaire, int montant) {
    // Add your payment processing logic here
    // Show success or error dialog based on the result
    _showSuccessDialog(montant, numeroBeneficiaire);
  }

  void _showSuccessDialog(int montant, String numeroBeneficiaire) {
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
              'Paiement Réussi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Montant payé : ${currencyFormat.format(montant)}',
              style: GoogleFonts.poppins(),
            ),
            Text(
              'Bénéficiaire : $numeroBeneficiaire',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
}