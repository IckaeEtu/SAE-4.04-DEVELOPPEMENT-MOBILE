// lib/features/restaurants/screens/restaurant_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/data/data.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  RestaurantDetailScreen({required this.restaurantId});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;

  @override
  void initState() {
    super.initState();
    var Data = DatabaseHelper();
    _restaurantFuture = Data.getRestaurantById(widget.restaurantId);
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final restaurant = snapshot.data!;
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
            return Center(child: Text('Restaurant non trouvé'));
          }
        },
      ),
    );
  }

  // Widget pour afficher les détails du restaurant
  Widget _buildRestaurantDetails(Restaurant restaurant) {
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