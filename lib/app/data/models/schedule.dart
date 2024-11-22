import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduledTransfer {
  final String id;
  final String destinataire;
  final double montant;
  final String emetteur;
  final double frais;
  final DateTime dateExecution;
  late final String statut; // PENDING, EXECUTED, CANCELLED
  final String type; // UNIQUE, RECURRENT
  final RecurrencePattern? recurrence;

  ScheduledTransfer({
    required this.id,
    required this.destinataire,
    required this.montant,
    required this.frais,
    required this.dateExecution,
    required this.emetteur,
    this.statut = 'PENDING',
    this.type = 'UNIQUE',
    this.recurrence,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinataire': destinataire,
        'emetteur': emetteur,
        'montant': montant,
        'frais': frais,
        'dateExecution': dateExecution.toIso8601String(),
        'statut': statut,
        'type': type,
        'recurrence': recurrence?.toJson(),
      };

  factory ScheduledTransfer.fromJson(Map<String, dynamic> json) =>
      ScheduledTransfer(
        id: json['id'],
        destinataire: json['destinataire'],
        emetteur: json['emetteur'],
        montant: json['montant'],
        frais: json['frais'],
        dateExecution: DateTime.parse(json['dateExecution']),
        statut: json['statut'] ?? 'PENDING',
        type: json['type'] ?? 'UNIQUE',
        recurrence: json['recurrence'] != null
            ? RecurrencePattern.fromJson(json['recurrence'])
            : null,
      );
}

class RecurrencePattern {
  final String frequence; // DAILY, WEEKLY, MONTHLY, YEARLY
  final int? interval;
  final DateTime? endDate;

  RecurrencePattern({
    required this.frequence,
    this.interval = 1,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'frequence': frequence,
        'interval': interval,
        'endDate': endDate?.toIso8601String(),
      };

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) =>
      RecurrencePattern(
        frequence: json['frequence'],
        interval: json['interval'] ?? 1,
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      );
}
