import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:monprojectgetx/app/modules/home/views/distributeur/distributeur_service.dart';

import 'app/modules/home/bindings/auth_binding.dart';
import 'app/modules/home/controllers/auth_controller.dart';
import 'app/modules/home/controllers/transaction_controller.dart';
import 'app/routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/transaction_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.lazyPut(() => AuthService());
  Get.lazyPut(() => AuthController());

  // Get.lazyPut(() => ServiceController());

  // Injecter toutes les dépendances nécessaires
  Get.put<TransactionService>(TransactionService(), permanent: true);
   Get.lazyPut(() => TransactionController());
  //  Get.lazyPut(() => ServiceController());

  // Vérifier l'utilisateur initial
  User? initialUser = FirebaseAuth.instance.currentUser;

  runApp(
    GetMaterialApp(
      title: "Application",
      debugShowCheckedModeBanner: false,
      initialRoute: initialUser != null ? AppPages.INITIAL : '/login',
      getPages: AppPages.routes,
      initialBinding: AuthBinding(), // Assurez-vous que AuthBinding est correct
    ),
  );
}
