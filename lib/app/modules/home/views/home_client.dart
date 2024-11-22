import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'app_draw.dart';
import 'balance_view.dart';
import 'header_section.dart';
import 'quick_services.dart';
import 'transactions/transaction_list.dart';

class HomeClient extends GetView<AuthController> {
  HomeClient({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color backgroundColor = const Color(0xFF001B5E);
  final Color primaryTextColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Obx(() {
          // Si l'utilisateur n'est pas connecté
          if (controller.currentUser.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vous n\'êtes pas connecté',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed('/'), // Redirection
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(color: Color(0xFF001B5E)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Contenu principal après connexion
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeaderWidget(), // Header utilisateur
                const SizedBox(height: 16),
                BalanceCard(), // Vue solde
                const SizedBox(height: 16),
                QuickServices(), // Services rapides
                const SizedBox(height: 16),
                TransactionView(), // Liste des transactions
              ],
            ),
          );
        }),
      ),
    );
  }
}
