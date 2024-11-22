// contacts.dart
import 'package:flutter/material.dart';

// send_form.dart
// send_form.dart
import 'package:flutter/services.dart';

class Contact {
  final String name;
  final String phoneNumber;

  Contact({required this.name, required this.phoneNumber});
}

class ContactsService {
  static List<Contact> getContacts() {
    return [
      Contact(name: 'John Doe', phoneNumber: '+1234567890'),
      Contact(name: 'Jane Smith', phoneNumber: '+0987654321'),
      // Ajoutez plus de contacts ici
    ];
  }
}

class SendForm extends StatefulWidget {
  final Contact contact;

  const SendForm({Key? key, required this.contact}) : super(key: key);

  @override
  State<SendForm> createState() => _SendFormState();
}

class _SendFormState extends State<SendForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isProgrammedTransfer = false;
  double _transferFee = 0;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _amountController.addListener(_calculateFees);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateFees() {
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 500) {
      _transferFee = 5;
    } else {
      _transferFee = 5 + ((amount - 500) * 0.01);
    }
    _totalAmount = amount + _transferFee;
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Détails du transfert',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESTINATAIRE',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.contact.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'MONTANT À RECEVOIR',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || double.parse(value) <= 0) {
                    return 'Le montant à recevoir doit être supérieur à 0';
                  }
                  if (double.parse(value) > 5000) {
                    return 'Le montant maximum est de 5000 FCFA';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('FRAIS DE TRANSFERT'),
                    Text('$_transferFee FCFA'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MONTANT TOTAL À ENVOYER',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_totalAmount FCFA',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Text(
                '5 FCFA (0-500 FCFA) | 1% (au-delà de 500 FCFA) | Maximum 5000 FCFA',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DATE D'ENVOI *",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'jj/mm/aaaa'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HEURE D'ENVOI *",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedTime?.format(context) ?? '00:00',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isProgrammedTransfer,
                    onChanged: (value) {
                      setState(() {
                        _isProgrammedTransfer = value ?? false;
                      });
                    },
                  ),
                  const Text('Transfert programmé'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Ajouter la logique d'envoi ici
                    print('Envoi validé');
                    print('Montant: ${_amountController.text}');
                    print('Frais: $_transferFee');
                    print('Total: $_totalAmount');
                    print('Date: $_selectedDate');
                    print('Heure: $_selectedTime');
                    print('Programmé: $_isProgrammedTransfer');
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Envoyer'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactsList extends StatelessWidget {
  const ContactsList({Key? key, required Null Function(dynamic contact) onContactSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contacts = ContactsService.getContacts();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sélectionner un contact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      contact.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SendForm(contact: contact),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}