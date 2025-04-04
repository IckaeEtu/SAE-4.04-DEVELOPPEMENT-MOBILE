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
          'img': imageUrl,
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
    try {
      final response =
        await supabase.from(tableCritique).delete().eq(columnId, avisId);
        print('Avis $avisId supprimé.');
        return 0;
    }
    catch (e) {
      print('Erreur Supabase: $e');
      return 0;
    }
  
  }

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

  // Extraire et insérer des restaurants depuis un JSON
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

  // Initialiser et remplir la table restaurants depuis un fichier JSON
  Future<void> initialiserEtRemplirTables(String chemin) async {
    print('Initialisation des tables...');
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
    } else {
      print('Tables déjà initialisées.');
    }
  }

  Future<List<String?>> getRestaurantCommentImages(int restaurantId) async {
    print('Récupération des images des commentaires pour le restaurant $restaurantId...');
    try {
      final response = await supabase
          .from(SupabaseHelper.tableCritique)
          .select('img') // Sélectionne uniquement la colonne 'img'
          .eq(SupabaseHelper.columnIdRestaurant, restaurantId)
          .not('img', 'is', null); // Exclut les lignes où 'img' est null

      if (response == null || response.isEmpty) {
        print('Aucune image trouvée pour le restaurant $restaurantId.');
        return [];
      }

      // Extrait les URLs des images de la réponse
      List<String?> imageUrls = (response as List<dynamic>)
          .map((item) => (item as Map<String, dynamic>)['img'] as String?)
          .toList();

      print('Images des commentaires du restaurant $restaurantId: $imageUrls');
      return imageUrls;
    } catch (e) {
      print('Erreur Supabase lors de la récupération des images des commentaires: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }
}
