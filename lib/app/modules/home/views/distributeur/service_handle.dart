import 'package:flutter/material.dart';

import 'operations/deplafonnement.dart';
import 'operations/depot.dart';
import 'operations/paiement.dart';
import 'operations/retrait.dart';

class ServiceHandler extends StatelessWidget {
  final String service;
  final String data;

  const ServiceHandler({required this.service, required this.data, Key? key})
      : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    print("Service: $service, Data: $data");
    switch (service) {
      case 'Dépôt':
        return DepotFormPage(destinataireNumero: data);
      case 'Retrait':
        return RetraitFormPage(destinataireNumero: data);

      case 'Paiement':
        return PaiementFormPage(beneficiaireNumero: data);

      case 'Déplafonnement':
        return DeplafonnementFormPage(numeroCompte: data);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text("Erreur")),
          body: const Center(child: Text("Service non reconnu.")),
        );
    }
  }
}
