// ignore_for_file: override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import '../../../data/models/Compte.dart';
import '../controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends GetView<AuthController> {
  LoginView({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;
  final _isLoading = false.obs;
  final _error = RxString('');

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      _isLoading.value = true;
      _error.value = '';

      try {
        bool success = await controller.connexion(
          _emailController.text,
          _passwordController.text,
        );

        if (success) {
          Object role = controller.currentUser.value?.type ?? '';
          role == TypeCompte.DISTRIBUTEUR ? Get.offAllNamed('/distributeur') : Get.offAllNamed('/home');
        } else {
          throw 'Identifiants incorrects';
        }
      } catch (e) {
        _error.value = e.toString();
        Get.snackbar(
          'Erreur',
          'Échec de connexion: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      } finally {
        _isLoading.value = false;
      }
    }
  }

  void _handleGoogleLogin() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      bool success = await controller.loginWithGoogle();
      
      if (success) {
        Object role = controller.currentUser.value?.type ?? '';
        role == TypeCompte.DISTRIBUTEUR ? Get.offAllNamed('/distributeur') : Get.offAllNamed('/home');
      } else {
        throw 'Échec de la connexion avec Google';
      } 
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Échec de connexion Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _handleFacebookLogin() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      bool success = await controller.loginWithFacebook();
      
      if (success) {
        Object role = controller.currentUser.value?.type ?? '';
        role == TypeCompte.DISTRIBUTEUR ? Get.offAllNamed('/distributeur') : Get.offAllNamed('/home');
      } else {
        throw 'Échec de la connexion avec Google';
      } 
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Échec de connexion Facebook: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _handlePhoneLogin() async {
  String phoneNumber = ''; // Déclaration de la variable ici
  // Logique pour la connexion par téléphone
  phoneNumber = await Get.dialog<String>(
    // Affiche une boîte de dialogue pour saisir le numéro de téléphone
    AlertDialog(
      title: Text('Connexion par téléphone'),
      content: TextField(
        decoration: InputDecoration(labelText: 'Numéro de téléphone'),
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          phoneNumber = value; // Mise à jour de la variable
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: phoneNumber),
          child: Text('Envoyer'),
        ),
      ],
    ),
  ) ?? '';

  if (phoneNumber.isNotEmpty) {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      bool success = await controller.connexionParTelephone(phoneNumber);
      
      if (success) {
        Object role = controller.currentUser.value?.type ?? '';
        role == TypeCompte.DISTRIBUTEUR ? Get.offAllNamed('/distributeur') : Get.offAllNamed('/home');
      } else {
        throw 'Échec de la connexion par téléphone';
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Erreur',
        'Échec de connexion par téléphone: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      _isLoading.value = false;
    }
  }
}

 // Méthodes de style mises à jour
  Widget _buildLogo() {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/logo.webp',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'TransEasy',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Bleu foncé pour le titre
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous à votre compte',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.blue[700], // Bleu moyen pour le sous-titre
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        icon: Image.asset(
          'assets/images/google_logo.png', // Assurez-vous d'avoir ce logo dans vos assets
          height: 24,
          width: 24,
        ),
        label: Text(
          'Continuer avec Google',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        onPressed: _handleGoogleLogin,
      ),
    );
  }

  Widget _buildPhoneButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: _handlePhoneLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Text(
          'Se connecter par téléphone',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

 
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color.fromARGB(220, 255, 255, 255)),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      labelStyle: GoogleFonts.poppins(color: Colors.blue[800]),
      errorStyle: TextStyle(color: Colors.red[300]),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
          onPressed: _isLoading.value ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color.fromARGB(255, 4, 125, 223), // Bouton de connexion en bleu
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Se connecter',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        )),
        _buildDivider(),
        _buildGoogleButton(),
        _buildPhoneButton(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.facebook, color: Colors.white),
            label: Text(
              'Continuer avec Facebook',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900], // Bouton Facebook en bleu foncé
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handleFacebookLogin,
          ),
        ),
        // Reste des boutons avec des styles bleus
        TextButton(
          onPressed: () => Get.toNamed('/reset-password'),
          child: Text(
            'Mot de passe oublié?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed('/inscription'),
          child: RichText(
            text: TextSpan(
              text: "Vous n'avez pas de compte? ",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: "S'inscrire",
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 114, 180, 228),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration(
              label: 'Email',
              icon: Icons.email,
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir votre email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Veuillez saisir un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: _passwordController,
            decoration: _inputDecoration(
              label: 'Mot de passe',
              icon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword.value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () => _obscurePassword.value = !_obscurePassword.value,
              ),
            ),
            obscureText: _obscurePassword.value,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir votre mot de passe';
              }
              return null;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white70, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OU',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.white70, thickness: 1)),
        ],
      ),
    );
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 79, 114), // Bleu ciel clair
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildLoginForm(),
                  Obx(() => _error.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _error.value,
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink()),
                  _buildButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }
}
