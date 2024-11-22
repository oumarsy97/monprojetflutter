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
    return Transactions(
      id: map['id'] ?? '',
      montant: (map['montant'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(), // Conversion Timestamp -> DateTime
      destinataire: map['destinataire'] ?? '',
      emetteur: map['emetteur'],
      status: map['status'] ?? 'en_attente',
      operateur: map['operateur'],

      reference: map['reference'],
    );
  }

  get total => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'type': type,
      'description': description,
      'date': date,
      'emetteur': emetteur,
      'destinataire': destinataire,
      'status': status,
      'operateur': operateur,
      'reference': reference
    };
  }
}
