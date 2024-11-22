import 'package:get/get.dart';
import '../modules/home/bindings/auth_binding.dart';
import '../modules/home/bindings/transaction_binding.dart';
import '../modules/home/views/distributeur/distributer_home.dart';
import '../modules/home/views/home_client.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/inscription_view.dart';
import '../modules/home/views/login_view.dart';
import '../modules/home/views/transactions/transaction_list.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(
      name: '/login', 
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/inscription', 
      page: () => InscriptionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home', 
      page: () => HomeClient(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/distributeur', 
      page: () => DistributeurPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/transactions',
      page: () => const TransactionView(),
      binding: TransactionBinding(),
    ),
  ];
}