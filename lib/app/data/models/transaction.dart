import 'package:cloud_firestore/cloud_firestore.dart';

class Transactions {
  final String id;
  final double montant;
  final String type; // 'debit' ou 'credit'
  final String description;
  final DateTime date;
  final String? emetteur;
  final String destinataire;
  final String? operateur;
  final String status;
  final String? reference;

  Transactions({
    required this.id,
    required this.montant,
    required this.type,
    required this.description,
    required this.date,
    required this.destinataire,
    this.emetteur,
    this.reference,
    required this.status,
    this.operateur,
  });

  factory Transactions.fromMap(Map<String, dynamic> map) {
    // Gestion sécurisée de la conversion du montant
    double parseMontant(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.1;
    }

    return Transactions(
      id: map['id']?.toString() ?? '',
      montant: parseMontant(map['montant'] ),
      type: map['type']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      destinataire: map['destinataire']?.toString() ?? '',
      emetteur: map['emetteur']?.toString(),
      status: map['status']?.toString() ?? 'en_attente',
      operateur: map['operateur']?.toString(),
      reference: map['reference']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'type': type,
      'description': description,
      'date': Timestamp.fromDate(date),
      'emetteur': emetteur,
      'destinataire': destinataire,
      'status': status,
      'operateur': operateur,
      'reference': reference
    };
  }
}