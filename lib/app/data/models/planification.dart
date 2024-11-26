class Planification {
  // Constants
  static const List<String> typesValides = ['journalier', 'hebdomadaire', 'mensuel'];
  static const String statusEnAttente = 'en_attente';
  static const String statusComplete = 'complete';
  static const String statusAnnule = 'annule';

  final String? dateProchainExecution;
  final String? destinatairePhone;
  final String? emetteurPhone;
  final String? heure;
  final String? minute;
  final double? montant;
  final String? status;
  final String? type;

  // Constructor with named parameters
  const Planification({
    this.dateProchainExecution,
    this.destinatairePhone,
    this.emetteurPhone,
    this.heure,
    this.minute,
    this.montant,
    this.status,
    this.type,
  });

  // Factory constructor from JSON
  factory Planification.fromJson(Map<String, dynamic> json) {
    return Planification(
      dateProchainExecution: json['date_prochaine_execution']?.toString(),
      destinatairePhone: json['destinataire_telephone']?.toString(),
      emetteurPhone: json['emetteur_telephone']?.toString(),
      heure: json['heure']?.toString(),
      minute: json['minute']?.toString(),
      montant: double.tryParse(json['montant']?.toString() ?? ''),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'date_prochaine_execution': dateProchainExecution,
      'destinataire_telephone': destinatairePhone,
      'emetteur_telephone': emetteurPhone,
      'heure': heure,
      'minute': minute,
      'montant': montant,
      'status': status,
      'type': type,
    };
  }

  // CopyWith method
  Planification copyWith({
    String? dateProchainExecution,
    String? destinatairePhone,
    String? emetteurPhone,
    String? heure,
    String? minute,
    double? montant,
    String? status,
    String? type,
  }) {
    return Planification(
      dateProchainExecution: dateProchainExecution ?? this.dateProchainExecution,
      destinatairePhone: destinatairePhone ?? this.destinatairePhone,
      emetteurPhone: emetteurPhone ?? this.emetteurPhone,
      heure: heure ?? this.heure,
      minute: minute ?? this.minute,
      montant: montant ?? this.montant,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  // Validation methods
  bool isTypeValide() => type != null && typesValides.contains(type);

  bool isMontantValide() => montant != null && montant! > 0;

  bool isHeureValide() {
    if (heure == null || minute == null) return false;
    final h = int.tryParse(heure!);
    final m = int.tryParse(minute!);
    return h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60;
  }

  // New validation methods
  bool isPhoneNumberValide(String? phoneNumber) {
    if (phoneNumber == null) return false;
    // Add your phone number validation logic here
    // This is a simple example - adjust according to your needs
    return phoneNumber.length >= 8 && phoneNumber.length <= 15;
  }

  bool isDateValide() {
    if (dateProchainExecution == null) return false;
    try {
      final date = DateTime.parse(dateProchainExecution!);
      return date.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  // Global validation
  bool isValide() {
    return isTypeValide() &&
        isMontantValide() &&
        isHeureValide() &&
        isPhoneNumberValide(destinatairePhone) &&
        isPhoneNumberValide(emetteurPhone) &&
        isDateValide();
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Planification('
        'dateProchainExecution: $dateProchainExecution, '
        'destinatairePhone: $destinatairePhone, '
        'emetteurPhone: $emetteurPhone, '
        'heure: $heure, '
        'minute: $minute, '
        'montant: $montant, '
        'status: $status, '
        'type: $type)';
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Planification &&
        other.dateProchainExecution == dateProchainExecution &&
        other.destinatairePhone == destinatairePhone &&
        other.emetteurPhone == emetteurPhone &&
        other.heure == heure &&
        other.minute == minute &&
        other.montant == montant &&
        other.status == status &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      dateProchainExecution,
      destinatairePhone,
      emetteurPhone,
      heure,
      minute,
      montant,
      status,
      type,
    );
  }
}