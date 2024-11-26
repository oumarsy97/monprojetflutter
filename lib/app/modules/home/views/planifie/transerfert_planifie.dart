import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:monprojectgetx/app/modules/home/controllers/transaction_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class TransfertPlanifiePage extends StatefulWidget {
  const TransfertPlanifiePage({Key? key}) : super(key: key);

  @override
  _TransfertPlanifiePageState createState() => _TransfertPlanifiePageState();
}

class _TransfertPlanifiePageState extends State<TransfertPlanifiePage> with SingleTickerProviderStateMixin {
  Contact? selectedContact;
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isContactSelectorExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TransactionController transactionController = Get.find<TransactionController>();
  

  final TextEditingController _montantController = TextEditingController(text: '0');
  final TextEditingController _searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedRecurrence = 'journaliere';
  String destinataireTelephone = '';

  final Map<String, String> recurrenceLabels = {
    'journaliere': 'Chaque jour',
    'hebdomadaire': 'Chaque semaine',
    'mensuel': 'Chaque mois'
  };

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadContacts();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkPermissionsAndLoadContacts() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }
    if (status.isGranted) {
      await _loadContacts();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildContactSelector() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isContactSelectorExpanded ? 300 : 60,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                setState(() => _isContactSelectorExpanded = !_isContactSelectorExpanded);
                _isContactSelectorExpanded ? _animationController.forward() : _animationController.reverse();
              },
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF001B5E),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(
                selectedContact?.displayName ?? 'Sélectionner un contact',
                style: const TextStyle(
                  color: Color(0xFF001B5E),
                  fontSize: 14,
                ),
              ),
              trailing: RotationTransition(
                turns: _animation,
                child: const Icon(Icons.expand_more, color: Color(0xFF001B5E)),
              ),
            ),
            if (_isContactSelectorExpanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFF001B5E)),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: TextStyle(color: const Color(0xFF001B5E).withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF001B5E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF001B5E)),
                    ),
                  ),
                  onChanged: _filterContacts,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF001B5E),
                        child: Text(
                          contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(contact.displayName),
                      subtitle: Text(
                        contact.phones.isNotEmpty ? contact.phones.first.number : 'Pas de numéro',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        setState(() {
                          selectedContact = contact;
                          if (contact.phones.isNotEmpty) {
                            destinataireTelephone = contact.phones.first.number;
                          }
                          _isContactSelectorExpanded = false;
                        });
                        _animationController.reverse();
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF001B5E),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildCompactRow(
          'Montant',
          TextFormField(
            controller: _montantController,
            style: const TextStyle(color: Color(0xFF001B5E), fontSize: 14),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              suffixText: 'FCFA',
              suffixStyle: TextStyle(color: Color(0xFF001B5E)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCompactRow(
              'Date',
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                    style: const TextStyle(color: Color(0xFF001B5E), fontSize: 14),
                  ),
                ),
              ),
            ),
            _buildCompactRow(
              'Heure',
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedTime.format(context),
                    style: const TextStyle(color: Color(0xFF001B5E), fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSelector() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildCompactRow(
          'Fréquence',
          DropdownButtonFormField<String>(
            value: selectedRecurrence,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: recurrenceLabels.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedRecurrence = value!),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime && mounted) {
      setState(() => selectedTime = picked);
    }
  }

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadContacts() async {
    try {
      contacts = await FlutterContacts.getContacts(withProperties: true);
      if (mounted) setState(() => filteredContacts = contacts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
Future<void> _submitTransfer() async {
  if (_formKey.currentState?.validate() ?? false) {
    if (selectedContact == null || destinataireTelephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un contact')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Formater l'heure et la minute
      String heure = selectedTime.hour.toString().padLeft(2, '0');
      String minute = selectedTime.minute.toString().padLeft(2, '0');

      // Créer les données pour le transfert planifié
      Map<String, dynamic> transferData = {
        'destinataire': destinataireTelephone.replaceAll(RegExp(r'[^\d+]'), ''), // Nettoyer le numéro
        'type': selectedRecurrence,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'montant': int.parse(_montantController.text),
        'heure': heure,
        'minute': minute,
      };

      // Appeler la méthode du contrôleur
      bool success = await transactionController.addPlanifie(transferData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfert planifié avec succès')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transactionController.error.value.isNotEmpty 
              ? transactionController.error.value 
              : 'Erreur lors de la planification du transfert'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Transfert planifié',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF001B5E)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildContactSelector(),
                  const SizedBox(height: 8),
                  _buildAmountInput(),
                  const SizedBox(height: 8),
                  _buildDateTimeSelector(),
                  const SizedBox(height: 8),
                  _buildRecurrenceSelector(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001B5E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Planifier le transfert',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _montantController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}