import 'package:get/get.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  void logout() {
    Get.find<AuthController>().deconnexion();
    Get.offAllNamed('/login');
  }
}