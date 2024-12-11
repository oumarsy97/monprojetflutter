import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/models/contact.dart' as app_contact;
import '../../controllers/contactController.dart';

class ContactsFavorisPage extends StatefulWidget {
  const ContactsFavorisPage({Key? key}) : super(key: key);

  @override
  _ContactsFavorisPageState createState() => _ContactsFavorisPageState();
}

class _ContactsFavorisPageState extends State<ContactsFavorisPage> {
  final ContactsFavorisController _contactsFavorisController = Get.put(ContactsFavorisController());
  List<flutter_contacts.Contact> _deviceContacts = [];
  List<flutter_contacts.Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();

  // New controllers for manual contact input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeviceContacts();
    _contactsFavorisController.chargerContactsFavoris();
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

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _deviceContacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // New method to show manual contact input dialog
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du Contact',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearContactInputFields();
              },
            ),
            ElevatedButton(
              child: const Text('Ajouter'),
              onPressed: () {
                _addManualContact();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to add manually input contact
  void _addManualContact() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty) {
      final newContact = app_contact.Contact(
        displayName: name,
        phoneNumber: phone,
      );

      // Add the contact to favorites
      _contactsFavorisController.basculerContactFavori(newContact);

      // Clear input fields
      _clearContactInputFields();
    } else {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un nom et un numéro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Clear input fields
  void _clearContactInputFields() {
    _nameController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Contacts Favoris',
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
        actions: [
          // Add a button to manually add contact
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF001B5E)),
            onPressed: _showAddContactDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section Contacts Favoris
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Vos Contacts Favoris',
              style: TextStyle(
                color: Color(0xFF001B5E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            if (_contactsFavorisController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF001B5E),
                ),
              );
            }

            if (_contactsFavorisController.contactsFavoris.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucun contact favori pour le moment',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _contactsFavorisController.contactsFavoris.length,
                itemBuilder: (context, index) {
                  final contact = _contactsFavorisController.contactsFavoris[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF001B5E),
                          child: Text(
                            contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.displayName,
                          style: const TextStyle(
                            color: Color(0xFF001B5E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
          ),

          // Liste des contacts à ajouter en favoris
          Expanded(
            child: ListView.builder(
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
                  subtitle: Text(
                    contact.phones.isNotEmpty 
                      ? contact.phones.first.number 
                      : 'Pas de numéro',
                  ),
                  trailing: Obx(() {
                    final isFavorite = _contactsFavorisController.estContactFavori(appContact);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow[700] : Colors.grey,
                      ),
                      onPressed: () {
                        _contactsFavorisController.basculerContactFavori(appContact);
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}