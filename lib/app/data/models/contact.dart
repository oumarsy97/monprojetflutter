class Contact {
  String? id;
  final String displayName;
  final String phoneNumber;

  Contact({
    this.id,
    required this.displayName,
    required this.phoneNumber,
  });

  // Méthode factory pour conversion sûre
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String?,
      displayName: (map['displayName'] as String?) ?? '',
      phoneNumber: (map['phoneNumber'] as String?) ?? '',
    );
  }

  // Méthode pour convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }

  // Méthode d'égalité
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => phoneNumber.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, displayName: $displayName, phoneNumber: $phoneNumber)';
  }
}