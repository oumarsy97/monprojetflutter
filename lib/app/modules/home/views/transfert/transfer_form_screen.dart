// // transfer_form_screen.dart
// import 'package:flutter/material.dart';

// // transfer_forms.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../home/quick_services.dart';


// // Formulaire pour l'envoi immédiat
// class ImmediateTransferForm extends StatefulWidget {
//   final Contact contact;

//   const ImmediateTransferForm({Key? key, required this.contact}) : super(key: key);

//   @override
//   State<ImmediateTransferForm> createState() => _ImmediateTransferFormState();
// }

// class _ImmediateTransferFormState extends State<ImmediateTransferForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   double _transferFee = 0;
//   double _totalAmount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _amountController.addListener(_calculateFees);
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   void _calculateFees() {
//     double amount = double.tryParse(_amountController.text) ?? 0;
//     if (amount <= 500) {
//       _transferFee = 5;
//     } else {
//       _transferFee = 5 + ((amount - 500) * 0.01);
//     }
//     _totalAmount = amount + _transferFee;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Détails du transfert',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'DESTINATAIRE',
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       widget.contact.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(widget.contact.phoneNumber),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'MONTANT À RECEVOIR',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: const InputDecoration(
//                   suffixText: 'FCFA',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty || double.parse(value) <= 0) {
//                     return 'Le montant à recevoir doit être supérieur à 0';
//                   }
//                   if (double.parse(value) > 5000) {
//                     return 'Le montant maximum est de 5000 FCFA';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('FRAIS DE TRANSFERT'),
//                     Text('$_transferFee FCFA'),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'MONTANT TOTAL À ENVOYER',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '$_totalAmount FCFA',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const Text(
//                 '5 FCFA (0-500 FCFA) | 1% (au-delà de 500 FCFA) | Maximum 5000 FCFA',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[800],
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // Logique d'envoi immédiat
//                     print('Envoi immédiat');
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Icon(Icons.send),
//                     SizedBox(width: 8),
//                     Text('Envoyer'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _showConfirmation = false;

//   @override
//   Widget build(BuildContext context) {
//     if (_showConfirmation) {
//       return _buildConfirmationScreen();
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFF001B5E),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Envoi d\'argent'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildRecipientCard(),
//                 const SizedBox(height: 24),
//                 _buildAmountField(),
//                 const SizedBox(height: 16),
//                 _buildDescriptionField(),
//                 const SizedBox(height: 32),
//                 _buildSubmitButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecipientCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue.withOpacity(0.2),
//             child: Text(
//               widget.recipientName[0],
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.recipientName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   widget.recipientPhone,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAmountField() {
//     return TextFormField(
//       controller: _amountController,
//       keyboardType: TextInputType.number,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: 'Montant',
//         suffixText: 'FCFA',
//         labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blue),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Veuillez entrer un montant';
//         }
//         if (double.tryParse(value) == null) {
//           return 'Veuillez entrer un montant valide';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildDescriptionField() {
//     return TextFormField(
//       controller: _descriptionController,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: 'Description (optionnel)',
//         labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blue),
//         ),
//       ),
//       maxLines: 3,
//     );
//   }

//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _validateAndShowConfirmation,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: const Text(
//           'Continuer',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   void _validateAndShowConfirmation() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _showConfirmation = true;
//       });
//     }
//   }

//   Widget _buildConfirmationScreen() {
//     return Scaffold(
//       backgroundColor: const Color(0xFF001B5E),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Confirmation'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildConfirmationCard(),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _processTransfer,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Confirmer l\'envoi',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildConfirmationCard() {
//     return Card(
//       color: Colors.white.withOpacity(0.1),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Résumé de la transaction',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildConfirmationRow('Destinataire', widget.recipientName),
//             _buildConfirmationRow('Numéro', widget.recipientPhone),
//             _buildConfirmationRow(
//                 'Montant', '${_amountController.text} FCFA'),
//             if (_descriptionController.text.isNotEmpty)
//               _buildConfirmationRow('Description', _descriptionController.text),
//             const SizedBox(height: 16),
//             const Text(
//               'Frais de transaction: 100 FCFA',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildConfirmationRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 14,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _processTransfer() {
//     // Ici, vous implémenteriez la logique d'envoi réelle
//     // Pour l'exemple, nous allons simplement afficher un message de succès
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF001B5E),
//         title: const Text(
//           'Transfert réussi',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Text(
//           'Vous avez envoyé ${_amountController.text} FCFA à ${widget.recipientName}',
//           style: const TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             child: const Text(
//               'OK',
//               style: TextStyle(color: Colors.blue),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }