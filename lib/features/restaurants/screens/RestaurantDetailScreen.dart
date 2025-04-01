import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase directly

class RestaurantDetailScreen extends StatelessWidget {
  final int restaurantId;

  const RestaurantDetailScreen({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;

  // Duplicate Supabase initialization (NOT RECOMMENDED long-term)
  final _supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _fetchRestaurantDetails();
  }

  Future<Restaurant?> _fetchRestaurantDetails() async {
    //  final dbHelper = SupabaseHelper(); // Not using SupabaseHelper at all now
    //  final db = dbHelper.getSupabaseClient();
    final db = _supabaseClient; // Use the local client
    try {
      print('Fetching restaurant with ID: ${widget.restaurantId}');
      final result =
          await db.from('restaurant').select().eq('id', widget.restaurantId);
      print('Query result: $result');
      if (result != null && result.isNotEmpty) {
        final restaurant = Restaurant.fromMap((result as List).first);
        print('Restaurant object: $restaurant');
        return restaurant;
      }
      print('Restaurant not found');
      return null;
    } catch (e) {
      print("Error fetching restaurant details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un Provider pour gérer l'état du restaurant
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
      ),
      body: FutureBuilder<Restaurant?>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final restaurant = snapshot.data!;
            return _buildRestaurantDetails(restaurant);
          } else {
            return const Center(child: Text('Restaurant not found'));
          }
        },
      ),
    );
  }

Widget _buildRestaurantDetails(Restaurant restaurant) {
  return Card( // Encapsulate in a Card
    elevation: 4, // Add a subtle shadow
    margin: const EdgeInsets.all(16), // Add margin around the card
    child: Padding(
      padding: const EdgeInsets.all(16), // Add padding inside the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.nom,
            style: const TextStyle(
              fontSize: 28, // Larger and bolder
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey, // A bit more refined color
            ),
          ),
          const SizedBox(height: 12),
          Row( // Use a Row to place icon and text
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded( // Use Expanded to take available space
                child: Text(
                  restaurant.adresse,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 20, thickness: 1, color: Colors.grey), // Subtle divider
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Type: ${restaurant.type}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Slightly bolder
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Téléphone: ${restaurant.telephone}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.web, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Site Web: ${restaurant.siteweb ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue), // Link color
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 20, thickness: 1, color: Colors.grey), // Another divider
          const SizedBox(height: 8),
          Text(
            'Description:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            restaurant.description ?? 'N/A',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Heures d\'ouverture:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            restaurant.openingHours ?? 'N/A',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.accessible, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Accessible aux fauteuils roulants: ${restaurant.wheelchair == 1 ? 'Oui' : 'Non'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}