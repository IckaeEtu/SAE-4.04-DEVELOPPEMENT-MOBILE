import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;

  @override
  void initState() {
    super.initState();
    print(
        "RestaurantDetailScreen initState called for restaurantId: ${widget.restaurantId}"); // Log

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      var Data = DatabaseHelper();
      // s'assure que la base de donnée est bien initialisé avant de faire la requête pour les données.
      await Data.database;
      _restaurantFuture = Data.getRestaurantById(widget.restaurantId);
      print(
          "Fetching restaurant details for restaurantId: ${widget.restaurantId}"); // Log
    } catch (e) {
      print("Error fetching restaurant details: $e"); // Log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Restaurant'),
      ),
      body: FutureBuilder<Restaurant?>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          print("FutureBuilder state: ${snapshot.connectionState}"); // Log

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Loading restaurant details..."); // Log
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error loading restaurant details: ${snapshot.error}"); // Log
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final restaurant = snapshot.data!;
            print(
                "Restaurant details loaded successfully: ${restaurant.nom}"); // Log
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildRestaurantDetails(restaurant),
                  SizedBox(height: 20),

                  // Utilisation du widget ReviewWidget pour la gestion des avis
                  //ReviewWidget(restaurantId: widget.restaurantId),
                ],
              ),
            );
          } else {
            print("Restaurant not found."); // Log
            return Center(child: Text('Restaurant non trouvé'));
          }
        },
      ),
    );
  }

  // Widget pour afficher les détails du restaurant
  Widget _buildRestaurantDetails(Restaurant restaurant) {
    print("Building restaurant details widget for: ${restaurant.nom}"); // Log

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.nom,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          restaurant.adresse,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Type: ${restaurant.type}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Téléphone: ${restaurant.telephone}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Site Web: ${restaurant.siteweb}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Description: ${restaurant.description}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Heures d\'ouverture: ${restaurant.openingHours}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Accessible aux fauteuils roulants: ${restaurant.wheelchair == 1 ? 'Oui' : 'Non'}',
          style: TextStyle(fontSize: 16),
        )
      ],
    );
  }
}
