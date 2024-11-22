import 'package:get/get.dart';
import 'package:monprojectgetx/app/modules/home/controllers/transaction_controller.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/transaction_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Injecter les dépendances dans le bon ordre
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TransactionService>(TransactionService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<TransactionService>(TransactionService(), permanent: true); // Ajout de TransactionService
    Get.put<TransactionController>(TransactionController(), permanent: true);
  }
}
