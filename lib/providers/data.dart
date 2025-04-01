import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

final supabase = Supabase.instance.client;

class SupabaseHelper {
  // Constantes pour les noms de tables et de colonnes
  static const String tableCritique = 'critique';
  static const String tableRestaurant = 'restaurant';
  static const String columnId = 'id';
  static const String columnIdUtilisateur = 'id_utilisateur';
  static const String columnIdRestaurant = 'id_restaurant';
  static const String columnNom = 'nom';

  // Fonctions d'accès aux données (à adapter)
  Future<List<Map<String, dynamic>>> getAvisUser(int userId) async {
    print('Récupération des avis pour l\'utilisateur $userId...');
    final response = await supabase
        .from(tableCritique)
        .select()
        .eq(columnIdUtilisateur, userId);
    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    print('Avis de l\'utilisateur $userId: ${response}');
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getAvisById(int avisId) async {
    print('Récupération de l\'avis $avisId...');
    final response = await supabase
        .from(tableCritique)
        .select()
        .eq(columnId, avisId)
        .single();
    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    return response as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAvisRestaurant(int restaurantId) async {
    print('Récupération des avis pour le restaurant $restaurantId...');
    final response = await supabase
        .from(tableCritique)
        .select()
        .eq(columnIdRestaurant, restaurantId);
    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    print('Avis du restaurant $restaurantId: ${response}');
    return response as List<Map<String, dynamic>>;
  }

  Future<int> addAvis(int restaurantId, int userId, String commentaire,
      int note, String? imageUrl) async {
    print('Ajout d\'un avis pour le restaurant $restaurantId...');
    final response = await supabase
        .from(tableCritique)
        .insert({
          columnIdRestaurant: restaurantId,
          columnIdUtilisateur: userId,
          'commentaire': commentaire,
          'note': note,
          'image_url': imageUrl,
        })
        .select(columnId)
        .single();

    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    return (response as Map<String, dynamic>)[columnId] as int;
  }

  Future<int> deleteAvis(int avisId) async {
    print('Suppression de l\'avis $avisId...');
    final response =
        await supabase.from(tableCritique).delete().eq(columnId, avisId);

    if (response.error != null) {
      print('Erreur Supabase: ${response.error}');
      throw response.error!;
    }
    print('Avis $avisId supprimé.');
    return response.count ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAllRestaurant() async {
    print('Récupération de tous les restaurants...');
    final response = await supabase.from(tableRestaurant).select();
    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    print('Restaurants récupérés: ${response}');
    return response as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    print('Récupération du restaurant $nom...');
    final response = await supabase
        .from(tableRestaurant)
        .select()
        .eq(columnNom, nom)
        .single();

    try {
      if (response == null || response.isEmpty) {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Erreur Supabase: $e');
      throw e;
    }
    return response as Map<String, dynamic>?;
  }

  Future<bool> extraireRestaurants(String json) async {
    print('Extraction des restaurants...');
    try {
      final restaurants = jsonDecode(json) as List<dynamic>;

      for (var restaurant in restaurants) {
        final existingRestaurant = await getRestaurant(restaurant['name']);

        if (existingRestaurant == null) {
          await supabase.from(tableRestaurant).insert({
            columnNom: restaurant['name'],
            'type': restaurant['type'],
            'adresse': '${restaurant['com_nom']}, ${restaurant['commune']}',
            'telephone': restaurant['phone'] ?? 'Non renseigné',
            'siteweb': restaurant['website'] ?? 'Non renseigné',
            'description': restaurant['description'] ?? 'Aucune description',
            'photo': restaurant['photo'],
            'opening_hours': restaurant['opening_hours'],
            'wheelchair': restaurant['wheelchair'] == 'yes' ? 1 : 0,
            'code_region': restaurant['code_region'],
            'code_departement': restaurant['code_departement'],
            'code_commune': restaurant['code_commune'],
          });
        }
      }
      print('Extraction réussie.');
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }

  Future<void> initialiserEtRemplirTables(String chemin) async {
    print('Initialisation des tables...');
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('tables_initialized') ?? false;

    if (!isInitialized) {
      try {
        final jsonString = await rootBundle.loadString(chemin);
        final restaurants = jsonDecode(jsonString) as List<dynamic>;

        // 1. Initialisation de la table Restaurant
        for (var restaurant in restaurants) {
          await supabase.from(tableRestaurant).insert({
            columnNom: restaurant['name'],
            'type': restaurant['type'],
            'adresse': '${restaurant['com_nom']}, ${restaurant['commune']}',
            'telephone': restaurant['phone'] ?? 'Non renseigné',
            'siteweb': restaurant['website'] ?? 'Non renseigné',
            'description': restaurant['description'] ?? 'Aucune description',
            'photo': restaurant['photo'],
            'opening_hours': restaurant['opening_hours'],
            'wheelchair': restaurant['wheelchair'] == 'yes' ? 1 : 0,
            'code_region': restaurant['code_region'],
            'code_departement': restaurant['code_departement'],
            'code_commune': restaurant['code_commune'],
          });
        }

        print('Table Restaurant initialisée et remplie avec succès.');

        // ... (initialisation des autres tables)

        await prefs.setBool('tables_initialized', true);
        print('Tables initialisées et remplies avec succès.');
      } catch (e) {
        print(
            'Erreur lors de l\'initialisation et du remplissage des tables : $e');
      }
    } else {
      print('Tables déjà initialisées.');
    }
  }
  Future<Map<String, dynamic>?> getRestaurantById(int id) async {
  print('Récupération du restaurant avec l\'id $id...');
  final response = await supabase
      .from(tableRestaurant)
      .select()
      .eq(columnId, id)
      .single();

  try {
    if (response == null || response.isEmpty) {
      throw Exception('Aucune donnée trouvée.');
    }
  } catch (e) {
    print('Erreur Supabase: $e');
    throw e;
  }
  return response as Map<String, dynamic>?;
}

extension on PostgrestMap {
  get error => null;

  get data => null;
}

extension on PostgrestList {
  get error => null;

  get data => null;
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

}