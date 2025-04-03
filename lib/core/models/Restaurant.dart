// lib/core/models/restaurant.dart

class Restaurant {
  int? id;
  String nom;
  String type;
  String adresse;
  String telephone;
  String? siteweb;
  String? commune;
  String? description;
  String? photo;
  String? openingHours;
  int wheelchair;
  int codeRegion;
  int codeDepartement;
  int codeCommune;

  Restaurant({
    this.id,
    required this.nom,
    required this.type,
    required this.adresse,
    required this.telephone,
    this.siteweb,
    this.commune,
    this.description,
    this.photo,
    this.openingHours,
    required this.wheelchair,
    required this.codeRegion,
    required this.codeDepartement,
    required this.codeCommune,
  });

  // Méthode pour créer une instance de Restaurant à partir d'un Map (utile pour les données de la base de données)
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      nom: map['nom'] ?? '',
      type: map['type'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      siteweb: map['siteweb'],
      commune: map['commune'],
      description: map['description'],
      photo: map['photo'],
      openingHours: map['opening_hours'],
      wheelchair: map['wheelchair'] ?? 0,
      codeRegion: map['code_region'] ?? 0,
      codeDepartement: map['code_departement'] ?? 0,
      codeCommune: map['code_commune'] ?? 0,
    );
  }

  // Méthode pour convertir une instance de Restaurant en Map (utile pour l'insertion ou la mise à jour dans la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'adresse': adresse,
      'telephone': telephone,
      'siteweb': siteweb,
      'commune': commune,
      'description': description,
      'photo': photo,
      'opening_hours': openingHours,
      'wheelchair': wheelchair,
      'code_region': codeRegion,
      'code_departement': codeDepartement,
      'code_commune': codeCommune,
    };
  }
}