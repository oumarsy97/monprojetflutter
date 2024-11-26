import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:monprojectgetx/app/modules/home/controllers/transaction_controller.dart';

import '../../../../data/models/planification.dart';
import 'transerfert_planifie.dart';

class TransfertsPlanifiesPage extends StatefulWidget {
  const TransfertsPlanifiesPage({Key? key}) : super(key: key);

  @override
  State<TransfertsPlanifiesPage> createState() => _TransfertsPlanifiesPageState();
}

class _TransfertsPlanifiesPageState extends State<TransfertsPlanifiesPage> {
  final TransactionController planificationController = Get.find<TransactionController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  String filter = '';

  @override
  void initState() {
    super.initState();
    planificationController.initPlanificationsStream();
    searchController.addListener(() {
      setState(() {
        filter = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          _buildFilterSection(),
          Expanded(
            child: Obx(
              () {
                if (planificationController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF001B5E)),
                  );
                }

                final filteredPlanifications = planificationController.planifications
                    .where((planification) =>
                        planification.destinatairePhone?.toLowerCase().contains(filter) ?? false ||
                        planification.type!.toLowerCase().contains(filter) ?? false)
                    .toList();

                if (filteredPlanifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          filter.isEmpty
                              ? 'Aucun transfert planifié'
                              : 'Aucun résultat pour le filtre "$filter"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPlanifications.length,
                  itemBuilder: (context, index) {
                    final planification = filteredPlanifications[index];
                    return _buildTransferCard(planification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par type ou destinataire...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF001B5E)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF001B5E)),
          ),
        ),
      ),
    );
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
                      const CircleAvatar(
                        backgroundColor: Color(0xFF001B5E),
                        radius: 20,
                        child: Icon(Icons.schedule, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${planification.type ?? ''}',
                            style: const TextStyle(
                              color: Color(0xFF001B5E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  const _TransferDetailsSheet({Key? key, required this.planification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Text('Détails du transfert : ${planification.type ?? 'Type inconnu'}'),
      ),
    );
  }
}
