enum Statut { ACTIF, INACTIF, BLOQUE }

enum TypeCompte { CLIENT, ADMIN, AGENT, DISTRIBUTEUR }

class Compte {
  String? id;
  TypeCompte type;
  String telephone;
  String email;
  String password;
  double montant;
  Statut statut;
  double limiteMensuelle;
  String prenom;
  String nom;
  double? plafond;

  // Constructeur
  Compte({
    this.id,
    this.type = TypeCompte.CLIENT,
    required this.telephone,
    required this.email,
    required this.password,
    this.montant = 0,
    this.statut = Statut.ACTIF,
    this.limiteMensuelle = 1000000,
    this.plafond = 100000,
    required this.prenom,
    required this.nom,
  });

  // Conversion depuis Map (Firestore)
  factory Compte.fromMap(Map<String, dynamic> map) {
    return Compte(
      id: map['id'],
      type: TypeCompte.values.firstWhere((e) => e.toString() == map['type']),
      telephone: map['telephone'],
      email: map['email'],
      password: map['password'],
      montant: (map['montant'] ?? 0).toDouble(),
      statut: Statut.values.firstWhere((e) => e.toString() == map['statut']),
      limiteMensuelle: (map['limiteMensuelle'] ?? 1000000).toDouble(),
      nom: map['nom'],
      prenom: map['prenom'],
      plafond: (map['plafond'] ?? 100000).toDouble(),
    );
  }

  // Conversion vers Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'telephone': telephone,
      'email': email,
      'password': password,
      'montant': montant,
      'statut': statut.toString(),
      'limiteMensuelle': limiteMensuelle,
      'nom': nom,
      'prenom': prenom,
      'plafond': plafond
    };
  }

  // Méthode copyWith pour créer une copie avec des modifications
  Compte copyWith({
    String? id,
    String? email,
    String? prenom,
    String? nom,
    TypeCompte? type,
    String? password,
    String? telephone,
    double? montant,
    Statut? statut,
    double? limiteMensuelle,
    double? plafond
  }) {
    return Compte(
      id: id ?? this.id,
      email: email ?? this.email,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      password: password ?? this.password,
      telephone: telephone ?? this.telephone,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      limiteMensuelle: limiteMensuelle ?? this.limiteMensuelle,
      plafond: plafond ?? this.plafond
    );
  }
}
