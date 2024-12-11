import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/Compte.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/services.dart';

class InscriptionView extends GetView<AuthController> {
  final String? nom;
  final String? prenom;
  final String? email;

  // Constructeur avec paramètres optionnels
  InscriptionView({
    this.nom,
    this.prenom,
    this.email,
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeConfirmationController = TextEditingController();
  final _emailController = TextEditingController();
  
  final RxBool _obscureCode = true.obs;
  final RxBool _obscureCodeConfirmation = true.obs;

  @override
  Widget build(BuildContext context) {
    // Initialisez les contrôleurs avec les valeurs passées si elles existent
    if (prenom != null) _prenomController.text = prenom!;
    if (nom != null) _nomController.text = nom!;
    if (email != null) _emailController.text = email!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo animé
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.webp',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Titres animés
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'TransEasy',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Créez votre compte',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildForm(context),
                    const SizedBox(height: 24),
                    _buildLoginLink(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormField(
                controller: _telephoneController,
                labelText: 'Numéro de téléphone',
                hintText: '7X XXX XX XX',
                context: context,
                icon: Icons.phone_android,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _prenomController,
                labelText: 'Prénom',
                hintText: 'Entrez votre prénom',
                context: context,
                icon: Icons.person_outline,
                isRequired: false,
                isPrefilledField: prenom != null,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nomController,
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
                context: context,
                icon: Icons.person,
                isRequired: false,
                isPrefilledField: nom != null,
              ),
              const SizedBox(height: 16),
              Obx(() => _buildFormField(
                controller: _codeController,
                labelText: 'Code',
                hintText: 'Entrez votre code',
                isPassword: true,
                context: context,
                icon: Icons.lock_outline,
                showPassword: _obscureCode.value,
                onTogglePassword: () => _obscureCode.value = !_obscureCode.value,
                isRequired: true,
              )),
              const SizedBox(height: 16),
              Obx(() => _buildFormField(
                controller: _codeConfirmationController,
                labelText: 'Confirmer le code',
                hintText: 'Confirmez votre code',
                isPassword: true,
                context: context,
                icon: Icons.lock,
                showPassword: _obscureCodeConfirmation.value,
                onTogglePassword: () => _obscureCodeConfirmation.value = !_obscureCodeConfirmation.value,
                isRequired: true,
              )),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Entrez votre email',
                context: context,
                icon: Icons.email_outlined,
                isRequired: false,
                isPrefilledField: email != null,
              ),
              const SizedBox(height: 24),
              _buildInscriptionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required BuildContext context,
    required IconData icon,
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? onTogglePassword,
    required bool isRequired,
    bool isPrefilledField = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isPrefilledField,
      obscureText: isPassword ? (showPassword ?? true) : false,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: isPrefilledField ? 'Champ pré-rempli' : hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ?? true ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
                onPressed: onTogglePassword,
              )
            : isPrefilledField 
                ? Icon(Icons.lock, color: Theme.of(context).primaryColor.withOpacity(0.7))
                : null,
        labelStyle: TextStyle(
          color: isPrefilledField 
            ? Colors.grey 
            : Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isPrefilledField 
              ? Colors.grey.shade300 
              : Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isPrefilledField ? Colors.grey.shade200 : Colors.grey.shade50,
      ),
      validator: (value) {
        if (isPrefilledField) return null;
        
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Ce champ est requis';
        }
        if (value != null && value.isNotEmpty) {
          if (labelText.contains('Email') && !value.contains('@')) {
            return 'Veuillez entrer une adresse email valide';
          }
          if (labelText == 'Confirmer le code' && value != _codeController.text) {
            return 'Les codes ne correspondent pas';
          }
        }
        return null;
      },
      keyboardType: labelText.contains('Email')
          ? TextInputType.emailAddress
          : labelText.contains('Numéro de téléphone')
              ? TextInputType.phone
              : TextInputType.text,
      inputFormatters: [
        if (labelText.contains('Numéro de téléphone'))
          LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildInscriptionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            final nouveauCompte = Compte(
              email: _emailController.text.isEmpty ? null : _emailController.text,
              password: _codeController.text,
              type: TypeCompte.CLIENT,
              telephone: _telephoneController.text,
              prenom: _prenomController.text.isEmpty ? null : _prenomController.text,
              nom: _nomController.text.isEmpty ? null : _nomController.text,
            );

            final success = await controller.inscription(nouveauCompte);
            
            if (success) {
              Get.offAllNamed('/home');
            }
          } catch (e) {
            Get.snackbar(
              'Erreur',
              'Erreur lors de l\'inscription: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(16),
              icon: const Icon(Icons.error_outline, color: Colors.white),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.how_to_reg, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'S\'inscrire',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Déjà inscrit ? ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          TextButton.icon(
            onPressed: () => Get.toNamed('/login'),
            icon: const Icon(
              Icons.login,
              color: Colors.white,
              size: 16,
            ),
            label: const Text(
              'Se connecter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}