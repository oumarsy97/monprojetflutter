// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/auth_controller.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool isBalanceVisible = true;
  final AuthController authController = Get.find<AuthController>();
  
  // Updated colors
  final primaryColor = const Color(0xFF001B5E);
  final secondaryColor = const Color.fromARGB(255, 4, 49, 162);
  final white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(10),
      height: 290,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde disponible',
                style: TextStyle(
                  color: white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(
                  isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: white.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    isBalanceVisible = !isBalanceVisible;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Obx(() => Text(
            isBalanceVisible 
                ? '${authController.userBalance.toStringAsFixed(0)} FCFA'
                : '********',
            style: TextStyle(
              color: white,
              fontSize: 32,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 5),
          Obx(() {
            final telephone = authController.userPhone;
            if (telephone.isNotEmpty) {
              return Center(
                child: Container(
                  width: 150,
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    data: telephone,
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: primaryColor,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}