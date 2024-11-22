import 'package:flutter/material.dart';

class ServicesGrid extends StatelessWidget {
  final Function(BuildContext, String) onServiceSelected;

  const ServicesGrid({required this.onServiceSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = ["dépôt", "retrait", "deplafonnement", "paiement"];
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onServiceSelected(context, services[index]),
          child: Card(
            child: Center(child: Text(services[index].toUpperCase())),
          ),
        );
      },
    );
  }
}
