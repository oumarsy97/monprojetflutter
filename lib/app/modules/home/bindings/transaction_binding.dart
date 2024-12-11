// transaction_binding.dart
import 'package:get/get.dart';

import '../controllers/transaction_controller.dart';


class TransactionBinding implements Bindings {
  @override
  void dependencies() {
    // Injecter TransactionController
    Get.lazyPut(() => TransactionController());
    Get.put<TransactionController>(TransactionController());
  
  }
}
