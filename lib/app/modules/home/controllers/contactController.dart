import 'package:get/get.dart';
import '../../../../services/auth_service.dart';
import '../../../data/models/contact.dart';

class ContactsFavorisController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Liste observable des contacts favoris
  final RxList<Contact> contactsFavoris = <Contact>[].obs;

  // Observable pour gérer l'état de chargement
  final RxBool isLoading = false.obs;

  // Observable pour gérer les erreurs
  final Rx<String?> errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    chargerContactsFavoris();
  }

  // Méthode pour charger les contacts favoris
  Future<void> chargerContactsFavoris() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Récupérer les données brutes
      final contactsData = await _authService.getContactsFavoris();

      // Conversion sécurisée
      contactsFavoris.value = (contactsData as List)
          .map<Contact>((e) => Contact.fromMap(e is Map<String, dynamic> 
            ? e 
            : {}))
          .toList();

    } catch (e) {
      errorMessage.value = "Erreur lors du chargement des contacts favoris: $e";
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour basculer le statut de favori d'un contact
  Future<void> basculerContactFavori(Contact contact) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      bool contactExiste = estContactFavori(contact);

      if (contactExiste) {
        await supprimerContactFavori(contact);
      } else {
        await ajouterContactFavori(contact);
      }
    } catch (e) {
      errorMessage.value = "Erreur lors de la gestion du contact favori: $e";
      print(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour ajouter un contact favori
  Future<void> ajouterContactFavori(Contact contact) async {
    try {
      if (!estContactFavori(contact)) {
        final result = await _authService.creerContact(contact);

        if (result != null) {
          await chargerContactsFavoris();
          Get.snackbar('Succès', 'Contact ajouté aux favoris',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Information', 'Ce contact est déjà dans vos favoris',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = "Erreur lors de l'ajout du contact: $e";
      print(errorMessage.value);
    }
  }

  // Méthode pour supprimer un contact favori
  Future<void> supprimerContactFavori(Contact contact) async {
    try {
      Contact? contactASupprimer = contactsFavoris
          .firstWhereOrNull((c) => c.phoneNumber == contact.phoneNumber);

      if (contactASupprimer != null) {
        final bool supprime = await _authService.supprimerContactFavori(contactASupprimer.id!);

        if (supprime) {
          await chargerContactsFavoris();
          Get.snackbar('Succès', 'Contact retiré des favoris',
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      errorMessage.value = "Erreur lors de la suppression du contact: $e";
      print(errorMessage.value);
    }
  }

  // Méthode pour vérifier si un contact est déjà favori
  bool estContactFavori(Contact contact) {
    return contactsFavoris.any((c) => c.phoneNumber == contact.phoneNumber);
  }
}