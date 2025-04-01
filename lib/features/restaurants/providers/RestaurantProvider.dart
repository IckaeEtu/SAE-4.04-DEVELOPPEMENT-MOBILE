import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/providers/data.dart';

class RestaurantProvider extends ChangeNotifier {
  var Data= SupabaseHelper();
  Restaurant? _selectedRestaurant;

  Restaurant? get selectedRestaurant => _selectedRestaurant;

Future<Restaurant?> _fetchRestaurantDetails(restaurantId) async {
    try {
      print('Fetching restaurant with ID: ${restaurantId}');
      final result =
          await Data.getRestaurantById(restaurantId);
      print('Query result: $result');
      if (result != null && result.isNotEmpty) {
        final restaurant = Restaurant.fromMap((result as List).first);
        return restaurant;
      }
      return null;
    } catch (e) {
      print("Error fetching restaurant details: $e");
      return null;
    }
  }

}
