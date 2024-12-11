import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/contactController.dart';
import '../../../../data/models/contact.dart' as app_contact;
import '../../controllers/transaction_controller.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({Key? key}) : super(key: key);

  @override
  _SendMoneyPageState createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final ContactsFavorisController _contactsFavorisController = Get.find();
  final AuthController _authController = Get.find<AuthController>();
  final TransactionController _transactionController = Get.find<TransactionController>();
  
  List<flutter_contacts.Contact> _deviceContacts = [];
  List<flutter_contacts.Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Nouveau contrôleur pour le numéro de téléphone
  
  app_contact.Contact? _selectedContact;
  bool _isFavoriteView = true;
  bool _isLoading = false;
  bool _isDirectPhoneInput = false; // Nouvel état pour basculer entre sélection de contact et saisie directe

  @override
  void initState() {
    super.initState();
    _loadDeviceContacts();
    _contactsFavorisController.chargerContactsFavoris();
  }

  Future<void> _showConfirmationDialog() async {
    // Vérifier le solde
    double currentBalance = _authController.userBalance;
    double amount;
    String phoneNumber;

    try {
      amount = double.parse(_amountController.text);
      if (amount <= 0) {
        throw FormatException();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Montant invalide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Récupérer le numéro de téléphone
    if (_isDirectPhoneInput) {
      phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isEmpty) {
        Get.snackbar(
          'Erreur', 
          'Veuillez saisir un numéro de téléphone',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      if (_selectedContact == null) {
        Get.snackbar(
          'Erreur', 
          'Veuillez sélectionner un contact',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      phoneNumber = _selectedContact!.phoneNumber;
    }

    // Vérifier si le solde est suffisant
    if (amount > currentBalance) {
      Get.snackbar(
        'Solde insuffisant', 
        'Votre solde actuel est de ${currentBalance.toStringAsFixed(2)} FCFA',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Afficher la boîte de dialogue de confirmation
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de transfert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant: ${amount.toStringAsFixed(2)} FCFA'),
              Text('Destinataire: $phoneNumber'),
              const SizedBox(height: 10),
              const Text(
                'Voulez-vous confirmer ce transfert ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001B5E),
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    // Si confirmé, procéder à l'envoi
    if (confirm == true) {
      await _performMoneyTransfer(amount, phoneNumber);
    }
  }

  Future<void> _performMoneyTransfer(double amount, String phoneNumber) async {
    try {
      // Afficher le loading
      setState(() {
        _isLoading = true;
      });

      // Ajouter la transaction
      await _transactionController.addTransaction(
        {
          'montant': amount,
          'destinataire': phoneNumber,
          'emetteur': _authController.userPhone,
          'date': DateTime.now(),
          'type': 'TRANSFERT',
          'status': 'EFFECTUE'
        }
      );

      // Cacher le loading
      setState(() {
        _isLoading = false;
      });

      // Afficher un message de succès
      Get.snackbar(
        'Succès', 
        'Transfert de ${amount.toStringAsFixed(2)} FCFA effectué avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Réinitialiser les champs
      _amountController.clear();
      _phoneController.clear();
      setState(() {
        _selectedContact = null;
      });

    } catch (e) {
      // Gestion des erreurs
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Erreur', 
        'Le transfert a échoué: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _sendMoney() {
    _showConfirmationDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Envoyer de l\'argent',
          style: TextStyle(
            color: Color(0xFF001B5E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001B5E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Affichage du solde
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Votre solde : ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_authController.userBalance.toStringAsFixed(2)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001B5E),
                      ),
                    ),
                  ],
                ),
              ),

              // Montant à envoyer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: 'Montant à envoyer',
                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF001B5E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF001B5E)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              // Segment Control: Saisie directe / Contacts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _isDirectPhoneInput = true;
                          _selectedContact = null;
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDirectPhoneInput 
                            ? const Color(0xFF001B5E) 
                            : Colors.grey[300],
                          foregroundColor: _isDirectPhoneInput 
                            ? Colors.white 
                            : Colors.black,
                        ),
                        child: const Text('Saisie Directe'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _isDirectPhoneInput = false;
                          _phoneController.clear();
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isDirectPhoneInput 
                            ? const Color(0xFF001B5E) 
                            : Colors.grey[300],
                          foregroundColor: !_isDirectPhoneInput 
                            ? Colors.white 
                            : Colors.black,
                        ),
                        child: const Text('Contacts'),
                      ),
                    ),
                  ],
                ),
              ),

              // Saisie du numéro ou recherche de contact
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isDirectPhoneInput
                  ? TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintText: 'Numéro de téléphone',
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFF001B5E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xFF001B5E)),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un contact...',
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF001B5E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF001B5E)),
                            ),
                          ),
                          onChanged: _filterContacts,
                        ),
                        // Liste des contacts
                        SizedBox(
                          height: 200, // Ajustez la hauteur selon vos besoins
                          child: _buildContactsList(),
                        ),
                      ],
                    ),
              ),

              // Bouton Envoyer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _sendMoney,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001B5E),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Envoyer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Traitement du transfert...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final appContact = app_contact.Contact(
          displayName: contact.displayName,
          phoneNumber: contact.phones.isNotEmpty 
            ? contact.phones.first.number 
            : '',
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF001B5E),
            child: Text(
              contact.displayName.isNotEmpty 
                ? contact.displayName[0].toUpperCase() 
                : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : ''),
          trailing: Radio<app_contact.Contact>(
            value: appContact,
            groupValue: _selectedContact,
            onChanged: (contact) {
              setState(() {
                _selectedContact = contact;
              });
            },
            activeColor: const Color(0xFF001B5E),
          ),
          selected: _selectedContact == appContact,
          selectedColor: const Color(0xFF001B5E).withOpacity(0.1),
        );
      },
    );
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _deviceContacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()) ||
              (contact.phones.isNotEmpty && 
               contact.phones.first.number.contains(query)))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _phoneController.dispose(); // Ajout de la disposition du nouveau contrôleur
    super.dispose();
  }

  Future<void> _loadDeviceContacts() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contacts = await flutter_contacts.FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _deviceContacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }
}