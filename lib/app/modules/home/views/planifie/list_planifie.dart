import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/planification.dart';
import '../../controllers/transaction_controller.dart';
import 'transerfert_planifie.dart';

class TransfertsPlanifiesPage extends StatefulWidget {
  const TransfertsPlanifiesPage({Key? key}) : super(key: key);

  @override
  State<TransfertsPlanifiesPage> createState() => _TransfertsPlanifiesPageState();
}

class _TransfertsPlanifiesPageState extends State<TransfertsPlanifiesPage> {
  final TransactionController planificationController = Get.find<TransactionController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filtrage des transferts
  String _selectedType = 'Tous';
  final List<String> _filterTypes = ['Tous', 'journaliere', 'hebdomadaire', 'mensuel'];

  @override
  void initState() {
    super.initState();
    planificationController.initPlanificationsStream();
  }

  // Méthode de filtrage des planifications
  List<Planification> _filterPlanifications() {
    if (_selectedType == 'Tous') {
      return planificationController.planifications;
    }
    return planificationController.planifications
        .where((p) => p.type == _selectedType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Transferts Planifiés',
          style: TextStyle(
            color: Color(0xFF001B5E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001B5E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF001B5E)),
            onPressed: () => Get.to(() => const TransfertPlanifiePage()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre de type de transfert
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterTypes.map((type) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      selectedColor: const Color(0xFF001B5E).withOpacity(0.2),
                      backgroundColor: Colors.grey[200],
                    ),
                  )
                ).toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (planificationController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF001B5E)),
                  );
                }

                final filteredPlanifications = _filterPlanifications();

                if (filteredPlanifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun transfert planifié',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Regroupement par type
                final groupedPlanifications = _groupPlanificationsByType(filteredPlanifications);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedPlanifications.length,
                  itemBuilder: (context, index) {
                    final type = groupedPlanifications.keys.elementAt(index);
                    final planificationsOfType = groupedPlanifications[type]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Color(0xFF001B5E),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...planificationsOfType.map((planification) => 
                          _buildTransferCard(planification)
                        ).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour regrouper les planifications par type
  Map<String, List<Planification>> _groupPlanificationsByType(List<Planification> planifications) {
    final grouped = <String, List<Planification>>{};
    
    for (var planification in planifications) {
      final type = planification.type ?? 'Non défini';
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(planification);
    }
    
    return grouped;
  }

  Widget _buildTransferCard(Planification planification) {
    final destinataire = planification.destinatairePhone ?? '';
    final montant = planification.montant?.toString() ?? '0';
    final dateStr = planification.dateProchainExecution ?? '';
    final heure = planification.heure ?? '00';
    final minute = planification.minute ?? '00';
    
    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      print('Erreur de parsing de date: $e');
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _showTransferDetails(planification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getTypeColor(planification.type),
                        radius: 20,
                        child: Icon(Icons.schedule, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinataire,
                            style: const TextStyle(
                              color: Color(0xFF001B5E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date != null 
                              ? '${DateFormat('dd/MM/yyyy').format(date)} à $heure:$minute'
                              : 'Date invalide',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '$montant FCFA',
                    style: const TextStyle(
                      color: Color(0xFF001B5E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Couleur personnalisée en fonction du type de transfert
  Color _getTypeColor(String? type) {
    switch (type) {
      case 'journaliere':
        return Colors.green;
      case 'hebdomadaire':
        return Colors.blue;
      case 'mensuel':
        return Colors.orange;
      default:
        return const Color(0xFF001B5E);
    }
  }

  void _showTransferDetails(Planification planification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferDetailsSheet(planification: planification),
    );
  }
}


class _TransferDetailsSheet extends StatelessWidget {
  final Planification planification;
  final TransactionController planificationController = Get.find<TransactionController>();

  _TransferDetailsSheet({
    Key? key,
    required this.planification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final destinataire = planification.destinatairePhone ?? '';
    final montant = planification.montant?.toString() ?? '0';
    final dateStr = planification.dateProchainExecution ?? '';
    final heure = planification.heure ?? '00';
    final minute = planification.minute ?? '00';
    
    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      print('Erreur de parsing de date: $e');
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Détails du transfert planifié',
                    style: TextStyle(
                      color: Color(0xFF001B5E),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailItem(
                    'Destinataire',
                    destinataire,
                    Icons.person_outline,
                  ),
                  _buildDetailItem(
                    'Montant',
                    '$montant FCFA',
                    Icons.payments_outlined,
                  ),
                  _buildDetailItem(
                    'Date',
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Date invalide',
                    Icons.calendar_today_outlined,
                  ),
                  _buildDetailItem(
                    'Heure',
                    '$heure:$minute',
                    Icons.access_time,
                  ),
                  _buildDetailItem(
                    'Type',
                    planification.type ?? 'Non défini',
                    Icons.repeat,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(
                        () => TransfertPlanifiePage(
                          //planification: planification,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001B5E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    label: const Text(
                      'Modifier le transfert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer ce transfert planifié ?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                 // await planificationController.deletePlanification(planification.id!);
                                  Navigator.pop(context); // Fermer la boîte de dialogue
                                  Navigator.pop(context); // Fermer la feuille de détails
                                  Get.snackbar(
                                    'Succès',
                                    'Transfert planifié supprimé avec succès',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'Erreur',
                                    'Erreur lors de la suppression: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Supprimer le transfert',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF001B5E), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF001B5E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}