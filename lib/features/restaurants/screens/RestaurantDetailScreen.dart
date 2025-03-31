// lib/features/restaurants/screens/restaurant_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final int restaurantId;

  RestaurantDetailScreen({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un Provider pour gérer l'état du restaurant et des avis
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Restaurant'),
      ),
      body: FutureBuilder<Restaurant>(
        // Supposons une fonction pour récupérer le restaurant par ID
        future: restaurantProvider.fetchRestaurantDetails(restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final restaurant = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildRestaurantDetails(restaurant),
                  SizedBox(height: 20),
                  _buildReviewSection(restaurantId),
                  SizedBox(height: 20),
                  _buildAddReviewForm(restaurantId),
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
        // ... Autres détails (téléphone, site web, etc.)
      ],
    );
  }

  // Widget pour afficher la section des avis
  Widget _buildReviewSection(int restaurantId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        // Utilisation d'un Consumer ou FutureBuilder pour afficher les avis
        Consumer<RestaurantProvider>(
          builder: (context, restaurantProvider, child) {
            if (restaurantProvider.avis.isEmpty) {
              return Center(child: Text('Aucun avis pour le moment.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics,
              itemCount: restaurantProvider.avis.length,
              itemBuilder: (context, index) {
                final avis = restaurantProvider.avis[index];
                return _buildReviewTile(avis);
              },
            );
          },
        ),
      ],
    );
  }

  // Widget pour afficher un seul avis
  Widget _buildReviewTile(Avis avis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date: ${avis.dateCreation}', // Formater la date
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            avis.commentaire,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            'Note: ${avis.note}/5',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          // ... (Ajouter un bouton de suppression si l'utilisateur est l'auteur)
        ],
      ),
    );
  }

  // Widget pour afficher le formulaire d'ajout d'avis
  Widget _buildAddReviewForm(int restaurantId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter un avis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        // Utilisation d'un formulaire pour ajouter un avis
        // ... (Champs pour la note, le commentaire, bouton d'envoi)
        // Appel à une fonction du RestaurantProvider pour ajouter l'avis
      ],
    );
  }
}
