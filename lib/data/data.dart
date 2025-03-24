import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'restaurant_db.db'); // Nom de votre base de données

    return await openDatabase(
      path,
      version: 1, // Schéma de la base de données (important pour les migrations)
      onCreate: _createDb,
    );
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
      );

      CREATE TABLE Utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        mot_de_passe TEXT NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        telephone TEXT,
        role TEXT NOT NULL DEFAULT 'utilisateur'
      );

      CREATE TABLE Critique (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_restaurant INTEGER NOT NULL,
        id_utilisateur INTEGER NOT NULL,
        note INTEGER NOT NULL,
        commentaire TEXT,
        date_creation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        signaler INTEGER,
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE,
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE
      );

      CREATE TABLE TypeCuisine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL
      );

      CREATE TABLE RestaurantTypeCuisine (
        id_restaurant INTEGER NOT NULL,
        id_type_cuisine INTEGER NOT NULL,
        PRIMARY KEY (id_restaurant, id_type_cuisine),
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE,
        FOREIGN KEY (id_type_cuisine) REFERENCES TypeCuisine(id) ON DELETE CASCADE
      );

      CREATE TABLE UtilisateurTypeCuisine (
        id_utilisateur INTEGER NOT NULL,
        id_type_cuisine INTEGER NOT NULL,
        PRIMARY KEY (id_utilisateur, id_type_cuisine),
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE,
        FOREIGN KEY (id_type_cuisine) REFERENCES TypeCuisine(id) ON DELETE CASCADE
      );

      CREATE TABLE RestaurantPrefere (
        id_utilisateur INTEGER NOT NULL,
        id_restaurant INTEGER NOT NULL,
        PRIMARY KEY (id_utilisateur, id_restaurant),
        FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id) ON DELETE CASCADE,
        FOREIGN KEY (id_restaurant) REFERENCES Restaurant(id) ON DELETE CASCADE
      );
    ''');
  }
}

Future<bool> extraireRestaurants(List<Map<String, dynamic>> restaurants) async {
    final db = await database;
    try {
      for (var restaurant in restaurants) {
        var existingRestaurant = await getRestaurant(restaurant['name']);

        if (existingRestaurant == null) {
          var data = {
            'nom': restaurant['name'],
            'type': restaurant['type'],
            'adresse': (restaurant['com_nom'] ?? '') + ', ' + (restaurant['commune'] ?? ''),
            'telephone': restaurant['phone'],
            'siteweb': restaurant['website'],
            'description': restaurant['description'] ?? 'Aucune description',
            'opening_hours': restaurant['opening_hours'],
            'wheelchair': restaurant['wheelchair'] == 'yes' ? 1 : 0,
            'code_region': restaurant['code_region'],
            'code_departement': restaurant['code_departement'],
            'code_commune': restaurant['code_commune'],
            'photo': restaurant['photo'],
          };

          await db.insert('Restaurant', data,
              conflictAlgorithm: ConflictAlgorithm.replace); // Utilisation de insert
        }
      }
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }

Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'Restaurant',
      where: 'nom = ?',
      whereArgs: [nom],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

Future<Map<String, dynamic>?> getRestaurantById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'Restaurant',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }