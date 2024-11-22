// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:contacts_service/contacts_service.dart';

// import 'contacts_list.dart';
// import 'transfert_form.dart';

// // Widget principal pour le transfert d'argent
// class MoneyTransferScreen extends StatelessWidget {
//   const MoneyTransferScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Transfert d\'argent'),
//       ),
//       body: const TransferForm(),
//     );
//   }
// }

// // Formulaire de transfert
// class TransferForm extends StatefulWidget {
//   const TransferForm({Key? key}) : super(key: key);

//   @override
//   State<TransferForm> createState() => _TransferFormState();
// }

// class _TransferFormState extends State<TransferForm> {
//   final TextEditingController _amountController = TextEditingController();
//   Contact? selectedContact;
  
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   void _showContactPicker() async {
//     final permission = await Permission.contacts.request();
    
//     if (permission.isGranted) {
//       // Afficher la liste des contacts
//       final contact = await showModalBottomSheet<Contact>(
//         context: context,
//         isScrollControlled: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) => const ContactsList(),
//       );
      
//       if (contact != null) {
//         setState(() {
//           selectedContact = contact;
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permission d\'accès aux contacts refusée')),
//       );
//     }
//   }

//   void _processTransfer() {
//     if (selectedContact == null || _amountController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez sélectionner un contact et saisir un montant')),
//       );
//       return;
//     }

//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Veuillez saisir un montant valide')),
//       );
//       return;
//     }

//     // Afficher la confirmation
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmation de transfert'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Destinataire: ${selectedContact?.displayName}'),
//             Text('Montant: ${_amountController.text} FCFA'),
//             const Text('Frais: 5 FCFA'),
//             const Divider(),
//             Text('Total: ${(amount + 5).toString()} FCFA'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Ici, ajoutez la logique pour effectuer le transfert
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Transfert effectué avec succès!')),
//               );
//             },
//             child: const Text('Confirmer'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Sélection du contact
//           Card(
//             child: ListTile(
//               title: Text(selectedContact?.displayName ?? 'Sélectionner un contact'),
//               leading: const Icon(Icons.person),
//               trailing: const Icon(Icons.arrow_forward_ios),
//               onTap: _showContactPicker,
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           // Champ de montant
//           TextField(
//             controller: _amountController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: 'Montant à envoyer',
//               border: OutlineInputBorder(),
//               suffixText: 'FCFA',
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Bouton d'envoi
//           ElevatedButton(
//             onPressed: _processTransfer,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text(
//               'Envoyer',
//               style: TextStyle(fontSize: 16, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }