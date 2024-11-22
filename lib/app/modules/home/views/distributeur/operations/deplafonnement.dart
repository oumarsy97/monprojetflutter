import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DeplafonnementFormPage extends StatefulWidget {
  final String numeroCompte;
  const DeplafonnementFormPage({Key? key, required this.numeroCompte}) : super(key: key);

  @override
  _DeplafonnementFormPageState createState() => _DeplafonnementFormPageState();
}

class _DeplafonnementFormPageState extends State<DeplafonnementFormPage> {
  final TextEditingController _plafondController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _numeroController.text = widget.numeroCompte;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Déplafonnement de compte',
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
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildNumeroField(),
              const SizedBox(height: 20),
              _buildPlafondField(),
              const SizedBox(height: 20),
              _buildConfirmationButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
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
              'Plafond actuel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(1000000), // Remplacer par le plafond actuel
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

  Widget _buildNumeroField() {
    return TextFormField(
      controller: _numeroController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Numéro de compte',
        prefixIcon: const Icon(Icons.account_circle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildPlafondField() {
    return TextFormField(
      controller: _plafondController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Nouveau plafond',
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
        if (montant <= 1000000) {
          return 'Le nouveau plafond doit être supérieur à 1.000.000 FCFA';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmationButton() {
    return ElevatedButton(
      onPressed: _confirmerDeplafonnement,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001F5C),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Confirmer le déplafonnement',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _confirmerDeplafonnement() {
    if (_formKey.currentState!.validate()) {
      int nouveauPlafond = int.parse(_plafondController.text);
      String numero = _numeroController.text;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirmation de déplafonnement',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Voulez-vous fixer le nouveau plafond à ${currencyFormat.format(nouveauPlafond)} pour le compte $numero ?',
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
                _executerDeplafonnement(numero, nouveauPlafond);
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

  void _executerDeplafonnement(String numero, int nouveauPlafond) {
    // Ajoutez ici votre logique de déplafonnement
    // Afficher succès ou erreur selon le résultat
    _showSuccessDialog(numero, nouveauPlafond);
  }

  void _showSuccessDialog(String numero, int nouveauPlafond) {
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
              'Déplafonnement Réussi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nouveau plafond : ${currencyFormat.format(nouveauPlafond)}',
              style: GoogleFonts.poppins(),
            ),
            Text(
              'Numéro de compte : $numero',
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