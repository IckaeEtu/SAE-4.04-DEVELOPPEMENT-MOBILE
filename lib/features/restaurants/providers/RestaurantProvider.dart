import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/providers/data.dart';

class RestaurantProvider extends ChangeNotifier {
  var Data = SupabaseHelper();
  Restaurant? _selectedRestaurant;

  Restaurant? get selectedRestaurant => _selectedRestaurant;

  Future<Restaurant?> fetchRestaurantDetails(int restaurantId) async {
    try {
      print('Fetching restaurant with ID: $restaurantId');
      final result = await Data.getRestaurantById(restaurantId);
      print('Query result: $result');
      if (result != null) {
        return Restaurant.fromMap(result);
      }
      return null;
    } catch (e) {
      print("Error fetching restaurant details: $e");
      return null;
    }
  }

  Future<List<String?>> fetchRestaurantImages(int restaurantId) async {
    try {
      final result = await Data.getRestaurantCommentImages(restaurantId);
      if (result != null && result.isNotEmpty) {
        return result;
      }
      return [];
    } catch (e) {
      print("Error fetching restaurant images: $e");
      return [];
    }
  }
}