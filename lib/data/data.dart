import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static Database? _database;
  static final String _databaseName = 'restaurant_db.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiWeb;

    final path = _databaseName;
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Restaurant (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        type TEXT NOT NULL,
        adresse TEXT NOT NULL,
        telephone TEXT NOT NULL,
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

    await db.execute('''
      CREATE TABLE Critique (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_restaurant INTEGER NOT NULL,
        id_utilisateur INTEGER NOT NULL,
        note INTEGER NOT NULL CHECK (note BETWEEN 1 AND 5),
        commentaire TEXT,
        date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        signaler INTEGER,
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE,
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE TypeCuisine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE RestaurantTypeCuisine (
        id_restaurant INTEGER NOT NULL,
        id_type_cuisine INTEGER NOT NULL,
        PRIMARY KEY (id_restaurant, id_type_cuisine),
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE,
        FOREIGN KEY (id_type_cuisine) REFERENCES TypeCuisine(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE UtilisateurTypeCuisine (
        id_utilisateur INTEGER NOT NULL,
        id_type_cuisine INTEGER NOT NULL,
        PRIMARY KEY (id_utilisateur, id_type_cuisine),
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE,
        FOREIGN KEY (id_type_cuisine) REFERENCES TypeCuisine(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE RestaurantPrefere (
        id_utilisateur INTEGER NOT NULL,
        id_restaurant INTEGER NOT NULL,
        PRIMARY KEY (id_utilisateur, id_restaurant),
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE,
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE
      )
    ''');
  }

  // Fonctions d'accès aux données (à adapter)
  Future<List<Map<String, dynamic>>> getAvisUser(int userId) async {
    final db = await database;
    return await db.query('Critique', where: 'id_utilisateur = ?', whereArgs: [userId]);
  }

  Future<Map<String, dynamic>?> getAvisById(int avisId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Critique', where: 'id = ?', whereArgs: [avisId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAvisRestaurant(int restaurantId) async {
    final db = await database;
    return await db.query('Critique', where: 'id_restaurant = ?', whereArgs: [restaurantId]);
  }

  Future<int> addAvis(int userId, int restaurantId, String avis, int note) async {
    final db = await database;
    return await db.insert('Critique', {
      'id_utilisateur': userId,
      'id_restaurant': restaurantId,
      'commentaire': avis,
      'note': note,
    });
  }

  Future<int> deleteAvis(int avisId) async {
    final db = await database;
    return await db.delete('Critique', where: 'id = ?', whereArgs: [avisId]);
  }

  Future<List<Map<String, dynamic>>> getAllRestaurant() async {
    final db = await database;
    return await db.query('Restaurant');
  }

  Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Restaurant', where: 'nom = ?', whereArgs: [nom]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> extraireRestaurants(String json) async {
    final db = await database;
    try {
      final restaurants = jsonDecode(json) as List<dynamic>;

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
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }

Future<void> testDatabase() async {
    print('Début des tests de la base de données...');

    // 1. Test de l'extraction et de l'insertion des restaurants
    final extractionSuccess = await extraireRestaurants(sampleJson);
    if (extractionSuccess) {
      print('Extraction des restaurants réussie.');
    } else {
      print('Erreur lors de l\'extraction des restaurants.');
    }

    // 2. Test de la récupération des restaurants
    final allRestaurants = await getAllRestaurant();
    if (allRestaurants.isNotEmpty) {
      print('Restaurants récupérés avec succès :');
      for (var restaurant in allRestaurants) {
        print(restaurant);
      }
    } else {
      print('Aucun restaurant trouvé.');
    }

    print('Fin des tests de la base de données.');
  }
}

String sampleJson = '''
[
  {
    "name": "Restaurant A",
    "type": "Italian",
    "com_nom": "Rue de la Paix",
    "commune": "Paris",
    "phone": "0123456789",
    "website": "www.restaurant-a.com",
    "description": "Un restaurant italien authentique.",
    "photo": "restaurant_a.jpg",
    "opening_hours": "12:00-22:00",
    "wheelchair": "yes",
    "code_region": 11,
    "code_departement": 75,
    "code_commune": 75101
  },
  {
    "name": "Restaurant B",
    "type": "French",
    "com_nom": "Avenue des Champs-Élysées",
    "commune": "Paris",
    "phone": "0987654321",
    "website": "www.restaurant-b.com",
    "description": "Un restaurant français classique.",
    "photo": "restaurant_b.jpg",
    "opening_hours": "19:00-23:00",
    "wheelchair": "no",
    "code_region": 11,
    "code_departement": 75,
    "code_commune": 75008
  }
]
''';