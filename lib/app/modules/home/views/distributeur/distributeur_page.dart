// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// import '../balance_view.dart';
// import 'scanoverley.dart';
// import 'service_grid.dart';
// import 'service_handle.dart';


// class DistributeurPage extends StatefulWidget {
//   const DistributeurPage({Key? key}) : super(key: key);

//   @override
//   _DistributeurPageState createState() => _DistributeurPageState();
// }

// class _DistributeurPageState extends State<DistributeurPage> {
//   final MobileScannerController _scannerController = MobileScannerController();
//   bool _isScanning = false;

//   void _startScanning(BuildContext context, String service) {
//     setState(() {
//       _isScanning = true;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return ScannerOverlay(
//           onScanResult: (scannedValue) {
//             Navigator.pop(context); // Fermer le scanner
//             setState(() {
//               _isScanning = false;
//             });
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ServiceHandler(service: service, data: scannedValue),
//               ),
//             );
//           },
//           onCancel: () {
//             Navigator.pop(context);
//             setState(() {
//               _isScanning = false;
//             });
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Distributeur"),
//         backgroundColor: const Color(0xFF001F5C),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             BalanceCard(),
//             const SizedBox(height: 16),
//             Text(
//               'Services',
//               style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             ServicesGrid(onServiceSelected: _startScanning),
//             const SizedBox(height: 16),
//             Text(
//               'Transactions Récentes',
//               style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//            // const RecentTransactions(),
//           ],
//         ),
//       ),
//     );
//   }
// }
