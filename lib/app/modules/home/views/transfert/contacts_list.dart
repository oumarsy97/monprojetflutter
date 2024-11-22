import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/contact.dart';

class ContactListSheet extends StatefulWidget {
  final bool multiSelect;
  final Function(List<Contact>) onContactsSelected;

  const ContactListSheet({
    Key? key, 
    this.multiSelect = false, 
    required this.onContactsSelected
  }) : super(key: key);

  @override
  _ContactListSheetState createState() => _ContactListSheetState();
}

class _ContactListSheetState extends State<ContactListSheet> {
  // Liste statique de contacts
  static final List<Contact> contacts = [
    Contact(
      id: '1',
      displayName: 'Fatima Thiaw',
      phoneNumber: '779163204',
    ),
    Contact(
      id: '2',
      displayName: 'Aichata Diop',
      phoneNumber: '763485092',
    ),
    Contact(
      id: '3',
      displayName: 'Pierre Durant',
      phoneNumber: '763485092',
    ),
    Contact(
      id: '4',
      displayName: 'Souleye Dieng',
      phoneNumber: '763485092',
    ),
  ];

  List<Contact> selectedContacts = [];

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.multiSelect ? 'Sélectionner des contacts' : 'Sélectionner un contact',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (contacts.isEmpty)
            const Center(
              child: Text('Aucun contact trouvé'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(contact.displayName[0].toUpperCase()),
                    ),
                    title: Text(contact.displayName),
                    subtitle: Text(contact.phoneNumber),
                    trailing: widget.multiSelect
                        ? Checkbox(
                            value: selectedContacts.contains(contact),
                            onChanged: (bool? value) {
                              _toggleContactSelection(contact);
                            },
                          )
                        : null,
                    onTap: () {
                      if (widget.multiSelect) {
                        _toggleContactSelection(contact);
                      } else {
                        widget.onContactsSelected([contact]);
                        Get.back();
                      }
                    },
                  );
                },
              ),
            ),
          if (widget.multiSelect)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: selectedContacts.isEmpty 
                  ? null 
                  : () {
                      widget.onContactsSelected(selectedContacts);
                      Get.back();
                    },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF6C38CC),
                ),
                child: Text('Confirmer (${selectedContacts.length})'),
              ),
            ),
        ],
      ),
    );
  }
}