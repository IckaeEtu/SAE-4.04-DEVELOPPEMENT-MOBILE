class Avis {
  final int id;
  final int idRestaurant;
  final int idUtilisateur;
  final String commentaire;
  final int note;
  final DateTime dateCreation;

  Avis({
    required this.id,
    required this.idRestaurant,
    required this.idUtilisateur,
    required this.commentaire,
    required this.note,
    required this.dateCreation,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'],
      idRestaurant: json['id_restaurant'],
      idUtilisateur: json['id_utilisateur'],
      commentaire: json['commentaire'],
      note: json['note'],
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }
}