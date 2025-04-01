import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/features/restaurants/providers/RestaurantProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;
  final _supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _fetchRestaurantDetails();
  }

  Future<Restaurant?> _fetchRestaurantDetails() async {
    try {
      print('Fetching restaurant with ID: ${widget.restaurantId}');
      final result =
          await _supabaseClient.from('restaurant').select().eq('id', widget.restaurantId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du restaurant')),
      body: FutureBuilder<Restaurant?>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            return _buildRestaurantDetails(snapshot.data!);
          } else {
            return const Center(child: Text('Restaurant introuvable'));
          }
        },
      ),
    );
  }

  Widget _buildRestaurantDetails(Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurant.nom, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(restaurant.adresse, style: const TextStyle(fontSize: 16))),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.category, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Type: ${restaurant.type}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(),
          Text('Description:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(restaurant.description ?? 'N/A', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}