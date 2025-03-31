import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io'; // Pour obtenir le chemin de stockage local

class DatabaseHelper {
  static Database? _database;
  static final String _databaseName = 'restaurant_db.db';

  // Méthode pour obtenir la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiWeb;

    final path = await getDatabasesPath();
    
    String dbPath = '$_databaseName';
    
    return await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  // Créer les tables nécessaires dans la base de données
// Créer les tables nécessaires dans la base de données
Future<void> _createDb(Database db, int version) async {
  // Création de la table Restaurant
    print('Création des tables...');

  await db.execute('''
    CREATE TABLE Restaurant (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      type TEXT NOT NULL,
      adresse TEXT NOT NULL,
      telephone TEXT,
      siteweb TEXT,
      commune TEXT,
      description TEXT,
      photo TEXT,
      opening_hours TEXT,
      wheelchair INTEGER DEFAULT 0,
      code_region INTEGER NOT NULL,
      code_departement INTEGER NOT NULL,
      code_commune INTEGER NOT NULL
    )
  ''');
  print('Table Restaurant créée.');

  // Création de la table Utilisateur
  await db.execute('''
    CREATE TABLE Utilisateur (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE,
      mot_de_passe TEXT NOT NULL,
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      telephone TEXT,
      role TEXT NOT NULL DEFAULT 'utilisateur'
    )
  ''');

  // Création de la table Critique
  await db.execute('''
    CREATE TABLE Critique (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_restaurant INTEGER NOT NULL,
      id_utilisateur INTEGER NOT NULL,
      note INTEGER NOT NULL,
      commentaire TEXT,
      date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      signaler INTEGER DEFAULT 0,
      FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE,
      FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
    )
  ''');
}

  // Charger le fichier JSON depuis les assets
  Future<String> loadJsonFromAssets() async {
    final jsonString = await rootBundle.loadString('lib/data/restaurants_orleans.json');
    return jsonString;
  }

  // Extraire et insérer les restaurants dans la base de données
  Future<bool> extraireRestaurants() async {
    final db = await database;
    try {
      final jsonString = await loadJsonFromAssets();
      final restaurants = jsonDecode(jsonString) as List<dynamic>;

      for (var restaurant in restaurants) {
        final existingRestaurant = await getRestaurant(restaurant['name']);

        if (existingRestaurant == null) {
          await db.insert('Restaurant', {
            'nom': restaurant['name'] ?? 'Nom inconnu',
            'type': restaurant['type'] ?? 'Type inconnu',
            'adresse': '${restaurant['com_nom'] ?? 'Commune inconnue'}, ${restaurant['commune'] ?? 'Commune inconnue'}',
            'telephone': restaurant['phone'] ?? 'Téléphone inconnu',
            'siteweb': restaurant['website'] ?? 'Site web non disponible',
            'description': restaurant['description'] ?? 'Aucune description',
            'photo': restaurant['photo'] ?? 'Photo non disponible',
            'opening_hours': restaurant['opening_hours'] ?? 'Horaires non disponibles',
            'wheelchair': restaurant['wheelchair'] == 'yes' ? 1 : 0,
            'code_region': restaurant['code_region'] ?? 'Code région inconnu',
            'code_departement': restaurant['code_departement'] ?? 'Code département inconnu',
            'code_commune': restaurant['code_commune'] ?? 'Code commune inconnu',
          });
        }
      }
      print("bien inséré");
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }
Future<void> afficherRestaurantsDepuisJson() async {
    try {
      // Charger le fichier JSON depuis les assets
      final jsonString = await loadJsonFromAssets();

      // Décoder les données JSON
      final List<dynamic> restaurants = jsonDecode(jsonString);

      // Afficher les restaurants dans la console
      for (var restaurant in restaurants) {
        print('Nom : ${restaurant['name']}');
        print('Type : ${restaurant['type']}');
        print('Adresse : ${restaurant['com_nom']}, ${restaurant['commune']}');
        print('Téléphone : ${restaurant['phone']}');
        print('Site Web : ${restaurant['website']}');
        print('Description : ${restaurant['description'] ?? 'Aucune description'}');
        print('Photo : ${restaurant['photo']}');
        print('Heures d\'ouverture : ${restaurant['opening_hours']}');
        print('Accessibilité fauteuil roulant : ${restaurant['wheelchair']}');
        print('Code région : ${restaurant['code_region']}');
        print('Code département : ${restaurant['code_departement']}');
        print('Code commune : ${restaurant['code_commune']}');
        print('----------------------------------------');
      }
    } catch (e) {
      print('Erreur lors du chargement ou de l\'affichage des restaurants : $e');
    }
  }



  // Récupérer un restaurant par son nom
  Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Restaurant', where: 'nom = ?', whereArgs: [nom]);
    return result.isNotEmpty ? result.first : null;
  }
}
