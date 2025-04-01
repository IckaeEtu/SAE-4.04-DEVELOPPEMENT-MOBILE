import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';

class RestaurantProvider extends ChangeNotifier {
  Restaurant? _selectedRestaurant;
  List<Map<String, dynamic>> _avis =;

  Restaurant? get selectedRestaurant => _selectedRestaurant;
  List<Map<String, dynamic>> get avis => _avis;

  // Méthode pour récupérer les détails d'un restaurant
  Future<void> fetchRestaurantDetails(int restaurantId) async {
    _selectedRestaurant = await Data.GetRestaurantById(restaurantId);
    notifyListeners(); // Avertir les écouteurs de la modification
  }

  // Méthode pour récupérer les avis
  Future<void> fetchAvis(int restaurantId) async {
    // Supposons que vous ayez une fonction pour récupérer les avis
    _avis = await Data.getAvisRestaurant(restaurantId) ??;
    notifyListeners();
  }

  // Méthode pour ajouter un avis
  Future<void> addAvis(int restaurantId, int userId, String commentaire, int note) async {
    await Data.addAvis(userId, restaurantId, commentaire, note);
    fetchAvis(restaurantId); // Récupérer les avis mis à jour
  }
}
