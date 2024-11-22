import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AppDrawer extends GetView<AuthController> {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // En-tête du drawer avec les informations de l'utilisateur
          GetX<AuthController>(
            builder: (controller) => Container(
              color: const Color(0xFF001B5E),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    child: Icon(Icons.person, color: Color(0xFF001B5E), size: 60),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.currentUser.value?.prenom ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.currentUser.value?.email ?? 'email@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Mon Profil',
                  onTap: () async {
                    Get.back();
                    await Get.toNamed('/profile');
                    // Rafraîchir les données utilisateur après modification du profil
                    controller.refreshUserData();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.date_range,
                  title: 'Transactions programmées',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/transactions');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () async {
                    Get.back();
                    await Get.toNamed('/settings');
                    // Rafraîchir les données après modification des paramètres
                    controller.refreshUserData();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Aide',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/help');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'A propos',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/about');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Déconnexion',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.deconnexion();
                        Get.offAllNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001B5E),
                      ),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      hoverColor: const Color(0xFF2684FF).withOpacity(0.1),
      onTap: onTap,
    );
  }
}