// lib/data/services_repository.dart
import 'package:flutter/material.dart';
import '../models/service.dart';

abstract class IServicesRepository {
  List<Service> getServices();
}

class ServicesRepository implements IServicesRepository {
  @override
  List<Service> getServices() {
    return [
      Service(
        title: 'Retrait',
        icon: Icons.money_off,
        color: const Color(0xFF4CAF50),
      ),
      Service(
        title: 'Dépôt',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF2196F3),
      ),
      Service(
        title: 'Déplafonnement',
        icon: Icons.trending_up,
        color: const Color(0xFFF44336),
      ),
      Service(
        title: 'Paiement',
        icon: Icons.payment,
        color: const Color(0xFF9C27B0),
      ),
    ];
  }
}