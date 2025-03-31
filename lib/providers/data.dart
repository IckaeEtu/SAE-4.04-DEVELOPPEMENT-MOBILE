import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class SupabaseHelper {
  // Fonctions d'accès aux données (à adapter)
  Future<List<Map<String, dynamic>>> getAvisUser(int userId) async {
    final response =
        await supabase.from('Critique').select().eq('id_utilisateur', userId);
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getAvisById(int avisId) async {
    final response =
        await supabase.from('Critique').select().eq('id', avisId).single();
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getAvisRestaurant(int restaurantId) async {
    final response = await supabase
        .from('Critique')
        .select()
        .eq('id_restaurant', restaurantId);
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as List<Map<String, dynamic>>;
  }

  Future<int> addAvis(
      int userId, int restaurantId, String avis, int note) async {
    final response = await supabase
        .from('Critique')
        .insert({
          'id_utilisateur': userId,
          'id_restaurant': restaurantId,
          'commentaire': avis,
          'note': note,
        })
        .select('id')
        .single();

    if (response.error != null) {
      throw response.error!;
    }
    return response.data['id'] as int;
  }

  Future<int> deleteAvis(int avisId) async {
    final response = await supabase.from('Critique').delete().eq('id', avisId);
    if (response.error != null) {
      throw response.error!;
    }
    return response.count ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAllRestaurant() async {
    final response = await supabase.from('restaurant').select();
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as List<Map<String, dynamic>>;
  }

  Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    final response =
        await supabase.from('restaurant').select().eq('nom', nom).single();
    if (response.error != null) {
      throw response.error!;
    }
    return response.data as Map<String, dynamic>?;
  }

  Future<bool> extraireRestaurants(String json) async {
    try {
      final restaurants = jsonDecode(json) as List<dynamic>;

      for (var restaurant in restaurants) {
        final existingRestaurant = await getRestaurant(restaurant['name']);

        if (existingRestaurant == null) {
          await supabase.from('restaurant').insert({
            'nom': restaurant['name'],
            'type': restaurant['type'],
            'adresse': '${restaurant['com_nom']}, ${restaurant['commune']}',
            'telephone': restaurant['phone'],
            'siteweb': restaurant['website'],
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
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }

  Future<void> testDatabase() async {
    print('Début des tests de la base de données...');

    final extractionSuccess = await extraireRestaurants(sampleJson);
    if (extractionSuccess) {
      print('Extraction des restaurants réussie.');
    } else {
      print('Erreur lors de l\'extraction des restaurants.');
    }

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

  Future<void> initialiserEtRemplirTables(String chemin) async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('tables_initialized') ?? false;

    if (!isInitialized) {
      try {
        final jsonString = await rootBundle.loadString(chemin);
        final restaurants = jsonDecode(jsonString) as List<dynamic>;

        // 1. Initialisation de la table Restaurant
        for (var restaurant in restaurants) {
          await supabase.from('restaurant').insert({
            'nom': restaurant['name'],
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
