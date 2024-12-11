import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/models/contact.dart' as app_contact;
import '../../controllers/auth_controller.dart';
import '../../controllers/contactController.dart';

class MultipleTransferPage extends StatefulWidget {
  const MultipleTransferPage({Key? key}) : super(key: key);

  @override
  _MultipleTransferPageState createState() => _MultipleTransferPageState();
}

class _MultipleTransferPageState extends State<MultipleTransferPage> {
  final AuthController authController = Get.find<AuthController>();
  final ContactsFavorisController _contactsFavorisController = Get.put(ContactsFavorisController());
  
  List<flutter_contacts.Contact> _allContacts = [];
  List<flutter_contacts.Contact> _filteredContacts = [];
  List<flutter_contacts.Contact> _selectedContacts = [];
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  bool _isLoading = false;
  bool _showFavorites = true;

  // Couleurs de design
  final Color _darkBlue = const Color(0xFF0D1B4A);
  final Color _midnightBlue = const Color(0xFF1A3A6C);
  final Color _deepOceanBlue = const Color(0xFF123456);
  final Color _navyBlue = const Color(0xFF070E2D);

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contacts = await flutter_contacts.FlutterContacts.getContacts(withProperties: true);
      await _contactsFavorisController.chargerContactsFavoris();
      
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _allContacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleContactSelection(flutter_contacts.Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _showConfirmationDialog() {
    final double amount = double.tryParse(amountController.text) ?? 0;
    final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
    final double total = amount + fees;
    final double totalTransfer = total * _selectedContacts.length;

    Get.dialog(
      Dialog(
        backgroundColor: _darkBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirmation du transfert multiple',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      fontSize: 18
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationRow('Nombre de destinataires', '${_selectedContacts.length}'),
                  _buildConfirmationRow('Montant par destinataire', '$amount FCFA'),
                  _buildConfirmationRow('Frais par transfert', '$fees FCFA'),
                  const Divider(height: 20, color: Colors.white24),
                  Text(
                    'Total à transférer: ${totalTransfer.toStringAsFixed(2)} FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.lightBlueAccent,
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Annuler', style: TextStyle(color: Colors.redAccent)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          setState(() {
                            _isLoading = true;
                          });
                          _performMultipleTransfer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _midnightBlue,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(
                                color: Colors.white, 
                                strokeWidth: 2,
                              )
                            )
                          : const Text('Confirmer', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: !_isLoading,
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _performMultipleTransfer() async {
    try {
      final double amount = double.tryParse(amountController.text) ?? 0;
      final double fees = amount <= 500 ? 5 : (amount * 0.01).clamp(0, 5000);
      final double total = amount + fees;

      for (var contact in _selectedContacts) {
        final transaction = {
          'montant': amount,
          'frais': fees,
          'total': total,
          'destinataire': contact.phones.isNotEmpty ? contact.phones.first.number : '',
          'emetteur': authController.userPhone,
          'date': DateTime.now(),
          'type': 'TRANSFERT_MULTIPLE',
          'status': 'EFFECTUE'
        };

        await authController.addTransaction(transaction);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Get.back(); // Fermer la boîte de dialogue de confirmation
      Get.snackbar(
        'Succès',
        'Transferts multiples effectués avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _midnightBlue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors des transferts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navyBlue,
      appBar: AppBar(
        title: Text(
          'Transfert Multiple', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _darkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.list : Icons.star, color: Colors.white),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
                if (_showFavorites) {
                  _filteredContacts = _contactsFavorisController.contactsFavoris
                    .map((favContact) => flutter_contacts.Contact()
                      ..displayName = favContact.displayName
                      ..phones = [flutter_contacts.Phone(favContact.phoneNumber)])
                    .toList();
                } else {
                  _filteredContacts = _allContacts;
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un contact...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: _midnightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterContacts,
            ),
          ),

          // Montant du transfert
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Montant par destinataire',
                labelStyle: TextStyle(color: Colors.white70),
                suffixText: 'FCFA',
                suffixStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: _midnightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Liste des contacts
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final isSelected = _selectedContacts.contains(contact);

                return ListTile(
                  tileColor: isSelected ? _midnightBlue.withOpacity(0.5) : null,
                  leading: CircleAvatar(
                    backgroundColor: _midnightBlue,
                    child: Text(
                      contact.displayName.isNotEmpty 
                        ? contact.displayName[0].toUpperCase() 
                        : '?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    contact.phones.isNotEmpty 
                      ? contact.phones.first.number 
                      : 'Pas de numéro',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: Colors.lightBlueAccent,
                    onChanged: (_) => _toggleContactSelection(contact),
                  ),
                  onTap: () => _toggleContactSelection(contact),
                );
              },
            ),
          ),

          // Bouton de transfert
          if (_selectedContacts.isNotEmpty && amountController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    _showConfirmationDialog();
                  } else {
                    Get.snackbar(
                      'Erreur',
                      'Veuillez saisir un montant valide',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade900,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _deepOceanBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Transférer (${_selectedContacts.length} contacts)', 
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}