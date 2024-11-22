// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:intl/intl.dart';

// import '../../controllers/auth_controller.dart';

// // Contrôleur générique pour les services
// class ServiceController extends GetxController {
  
//   final AuthController authController = Get.find();
//   final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

//   // Méthode générique pour traiter le scan
//   Future<void> processQRScan(BuildContext context, String serviceType, String scannedNumber) async {
//     switch (serviceType) {
//       case 'Dépôt':
//         await _handleDepot(context, scannedNumber);
//         break;
//       case 'Retrait':
//         await _handleRetrait(context, scannedNumber);
//         break;
//       case 'Déplafonnement':
//         await _handleDeplafonement(context, scannedNumber);
//         break;
//       case 'Paiement':
//         await _handlePaiement(context, scannedNumber);
//         break;
//     }
//   }

//   Future<void> _handleDepot(BuildContext context, String destinataireNumero) async {
//     Navigator.push(
//       context, 
//       MaterialPageRoute(
//         builder: (context) => DepotFormPage(destinataireNumero: destinataireNumero)
//       )
//     );
//   }

//   Future<void> _handleRetrait(BuildContext context, String destinataireNumero) async {
//     Navigator.push(
//       context, 
//       MaterialPageRoute(
//         builder: (context) => RetraitFormPage(destinataireNumero: destinataireNumero)
//       )
//     );
//   }

//   Future<void> _handleDeplafonement(BuildContext context, String destinataireNumero) async {
//     Navigator.push(
//       context, 
//       MaterialPageRoute(
//         builder: (context) => DeplacementFormPage(destinataireNumero: destinataireNumero)
//       )
//     );
//   }

//   Future<void> _handlePaiement(BuildContext context, String destinataireNumero) async {
//     Navigator.push(
//       context, 
//       MaterialPageRoute(
//         builder: (context) => PaiementFormPage(destinataireNumero: destinataireNumero)
//       )
//     );
//   }
// }

// // Page générique de formulaire de service
// abstract class ServiceFormPage extends StatefulWidget {
//   final String destinataireNumero;
//   const ServiceFormPage({Key? key, required this.destinataireNumero}) : super(key: key);
// }

// abstract class ServiceFormPageState<T extends ServiceFormPage> extends State<T> {
//   final TextEditingController montantController = TextEditingController();
//   final ServiceController serviceController = Get.find<ServiceController>();
//   final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

//   @protected
//   String get serviceType;

//   void submitForm() {
//     // Logique de validation et de soumission à implémenter par chaque sous-classe
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '$serviceType pour ${widget.destinataireNumero}', 
//           style: GoogleFonts.poppins(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: montantController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Montant',
//                 prefixText: 'FCFA ',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: submitForm,
//               child: Text('Confirmer $serviceType'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Pages spécifiques pour chaque service
// class DepotFormPage extends ServiceFormPage {
//   const DepotFormPage({Key? key, required String destinataireNumero}) 
//       : super(key: key, destinataireNumero: destinataireNumero);

//   @override
//   _DepotFormPageState createState() => _DepotFormPageState();
// }

// class _DepotFormPageState extends ServiceFormPageState<DepotFormPage> {
//   @override
//   String get serviceType => 'Dépôt';

//   @override
//   void submitForm() {
//     // Implémenter la logique de dépôt
//     print('Dépôt de ${montantController.text} pour ${widget.destinataireNumero}');
//   }
// }

// class RetraitFormPage extends ServiceFormPage {
//   const RetraitFormPage({Key? key, required String destinataireNumero}) 
//       : super(key: key, destinataireNumero: destinataireNumero);

//   @override
//   _RetraitFormPageState createState() => _RetraitFormPageState();
// }

// class _RetraitFormPageState extends ServiceFormPageState<RetraitFormPage> {
//   @override
//   String get serviceType => 'Retrait';

//   @override
//   void submitForm() {
//     // Implémenter la logique de retrait
//     print('Retrait de ${montantController.text} pour ${widget.destinataireNumero}');
//   }
// }

// class DeplacementFormPage extends ServiceFormPage {
//   const DeplacementFormPage({Key? key, required String destinataireNumero}) 
//       : super(key: key, destinataireNumero: destinataireNumero);

//   @override
//   _DeplacementFormPageState createState() => _DeplacementFormPageState();
// }

// class _DeplacementFormPageState extends ServiceFormPageState<DeplacementFormPage> {
//   @override
//   String get serviceType => 'Déplafonnement';

//   @override
//   void submitForm() {
//     // Implémenter la logique de déplafonnement
//     print('Déplafonnement pour ${widget.destinataireNumero}');
//   }
// }

// class PaiementFormPage extends ServiceFormPage {
//   const PaiementFormPage({Key? key, required String destinataireNumero}) 
//       : super(key: key, destinataireNumero: destinataireNumero);

//   @override
//   _PaiementFormPageState createState() => _PaiementFormPageState();
// }

// class _PaiementFormPageState extends ServiceFormPageState<PaiementFormPage> {
//   @override
//   String get serviceType => 'Paiement';

//   @override
//   void submitForm() {
//     // Implémenter la logique de paiement
//     print('Paiement de ${montantController.text} pour ${widget.destinataireNumero}');
//   }
// }