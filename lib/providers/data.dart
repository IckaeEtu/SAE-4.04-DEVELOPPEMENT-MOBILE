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

  // Récupérer les avis d'un utilisateur
  Future<List<Map<String, dynamic>>> getAvisUser(int userId) async {
    try {
      final response = await supabase
          .from(tableCritique)
          .select()
          .eq(columnIdUtilisateur, userId);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Erreur lors de la récupération des avis utilisateur: $e');
      return [];
    }
  }

  // Récupérer un avis par son ID
  Future<Map<String, dynamic>?> getAvisById(int avisId) async {
    try {
      final response = await supabase
          .from(tableCritique)
          .select()
          .eq(columnId, avisId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération de l\'avis: $e');
      return null;
    }
  }

  // Récupérer les avis d'un restaurant
  Future<List<Map<String, dynamic>>> getAvisRestaurant(int restaurantId) async {
    try {
      final response = await supabase
          .from(tableCritique)
          .select()
          .eq(columnIdRestaurant, restaurantId);

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Erreur lors de la récupération des avis restaurant: $e');
      return [];
    }
  }

  // Ajouter un avis
  Future<int?> addAvis(
      int restaurantId, int userId, String commentaire, int note, String? imageUrl) async {
    try {
      final response = await supabase.from(tableCritique).insert({
        columnIdRestaurant: restaurantId,
        columnIdUtilisateur: userId,
        'commentaire': commentaire,
        'note': note,
        'image_url': imageUrl,
      }).select(columnId).single();

      return response[columnId] as int?;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      return null;
    }
  }

  // Supprimer un avis
  Future<bool> deleteAvis(int avisId) async {
    try {
      final response = await supabase.from(tableCritique).delete().eq(columnId, avisId);
      return response.count != null && response.count! > 0;
    } catch (e) {
      print('Erreur lors de la suppression de l\'avis: $e');
      return false;
    }
  }

  // Récupérer tous les restaurants
  Future<List<Map<String, dynamic>>> getAllRestaurant() async {
    try {
      final response = await supabase.from(tableRestaurant).select();
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Erreur lors de la récupération des restaurants: $e');
      return [];
    }
  }

  // Récupérer un restaurant par son nom
  Future<Map<String, dynamic>?> getRestaurant(String nom) async {
    try {
      final response = await supabase
          .from(tableRestaurant)
          .select()
          .eq(columnNom, nom)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du restaurant: $e');
      return null;
    }
  }

  // Récupérer un restaurant par son ID
  Future<Map<String, dynamic>?> getRestaurantById(int id) async {
    try {
      final response = await supabase
          .from(tableRestaurant)
          .select()
          .eq(columnId, id)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération du restaurant par ID: $e');
      return null;
    }
  }

// SupabaseHelper.dart

Future<List<Map<String, dynamic>>> fetchTopRestaurants() async {
  try {
    // Requête Supabase pour récupérer les meilleurs restaurants par note
    final response = await supabase
        .from('critique')
        .select('id_restaurant, restaurant(nom, adresse, latitude, longitude), note')
        .order('note', ascending: false) // Tri par note décroissante
        .limit(2); // Limiter à 2 restaurants les mieux notés

    List<Map<String, dynamic>> fetchedRestaurants = [];
    if (response.isNotEmpty) {
      fetchedRestaurants = response.map<Map<String, dynamic>>((r) {
        final latitude = r['restaurant']['latitude'];
        final longitude = r['restaurant']['longitude'];

        // Vérification si latitude et longitude ne sont pas nulles
        if (latitude != null && longitude != null) {
          return {
            'id': r['id_restaurant'],
            'nom': r['restaurant']['nom'],
            'adresse': r['restaurant']['adresse'],
            'latitude': latitude,
            'longitude': longitude,
          };
        } else {
          return {
            'id': r['id_restaurant'],
            'nom': r['restaurant']['nom'],
            'adresse': r['restaurant']['adresse'],
            'latitude': 47.9025,  
            'longitude': 1.9090,  
          };
        }
      }).toList();
    }
    return fetchedRestaurants;
  } catch (e) {
    print("Erreur lors de la récupération des meilleurs restaurants: $e");
    return [];
  }
}


  // Extraire et insérer des restaurants depuis un JSON
  Future<bool> extraireRestaurants(String json) async {
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
      return true;
    } catch (e) {
      print('Erreur lors de l\'extraction des restaurants : $e');
      return false;
    }
  }

  // Initialiser et remplir la table restaurants depuis un fichier JSON
  Future<void> initialiserEtRemplirTables(String chemin) async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('tables_initialized') ?? false;

    if (!isInitialized) {
      try {
        final jsonString = await rootBundle.loadString(chemin);
        final restaurants = jsonDecode(jsonString) as List<dynamic>;

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

        await prefs.setBool('tables_initialized', true);
      } catch (e) {
        print('Erreur lors de l\'initialisation des tables: $e');
      }
    }
  }
}
