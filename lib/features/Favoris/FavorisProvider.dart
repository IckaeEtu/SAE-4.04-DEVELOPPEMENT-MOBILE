import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Pour encoder/décode JSON

class FavorisProvider extends ChangeNotifier {
  List<Restaurant> _favoriteRestaurants = [];

  List<Restaurant> get favoriteRestaurants => _favoriteRestaurants;

  FavorisProvider() {
    _loadFavoris();
  }

  // Charger les favoris depuis les SharedPreferences
  Future<void> _loadFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    final FavorisJson = prefs.getString('favoriteRestaurants');
    if (FavorisJson != null) {
      final List<dynamic> decoded = jsonDecode(FavorisJson);
      _favoriteRestaurants = decoded.map((r) => Restaurant.fromMap(r)).toList();
      notifyListeners();
    }
  }

  // Sauvegarder les favoris dans les SharedPreferences
  Future<void> _saveFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _favoriteRestaurants.map((r) => r.toMap()).toList();
    await prefs.setString('favoriteRestaurants', jsonEncode(encoded));
  }

  // Ajouter un restaurant aux favoris
  void addFavorite(Restaurant restaurant) {
    if (!_favoriteRestaurants.any((r) => r.id == restaurant.id)) {
      _favoriteRestaurants.add(restaurant);
      _saveFavoris();
      notifyListeners();
    }
  }

  // Supprimer un restaurant des favoris
  void removeFavorite(int restaurantId) {
    _favoriteRestaurants.removeWhere((r) => r.id == restaurantId);
    _saveFavoris();
    notifyListeners();
  }

  // Vérifier si un restaurant est favori
  bool isFavorite(int restaurantId) {
    return _favoriteRestaurants.any((r) => r.id == restaurantId);
  }
}