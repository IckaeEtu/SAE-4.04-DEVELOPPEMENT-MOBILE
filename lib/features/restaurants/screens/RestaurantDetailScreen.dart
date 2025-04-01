// // lib/features/restaurants/screens/restaurant_detail_screen.dart

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../core/models/restaurant.dart';
// import '../../core/models/avis.dart';
// import '../../providers/restaurant_provider.dart'; // Exemple de Provider

// class RestaurantDetailScreen extends StatelessWidget {
//   final int restaurantId;

//   RestaurantDetailScreen({required this.restaurantId});

//   @override
//   Widget build(BuildContext context) {
//     // Utilisation d'un Provider pour gérer l'état du restaurant
//     final restaurantProvider = Provider.of<RestaurantProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Détails du Restaurant'),
//       ),
//       body: FutureBuilder<Restaurant>(
//         // Utilisation de la fonction GetRestaurantById importée
//         future: Data.GetRestaurantById(restaurantId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Erreur: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final restaurant = snapshot.data!;
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ListView(
//                 children: [
//                   _buildRestaurantDetails(restaurant),
//                   SizedBox(height: 20),
//                   // Utilisation du widget ReviewWidget pour la gestion des avis
//                   ReviewWidget(restaurantId: restaurantId),
//                 ],
//               ),
//             );
//           } else {
//             return Center(child: Text('Restaurant non trouvé'));
//           }
//         },
//       ),
//     );
//   }

//   // Widget pour afficher les détails du restaurant
//   Widget _buildRestaurantDetails(Restaurant restaurant) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           restaurant.nom,
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 8),
//         Text(
//           restaurant.adresse,
//           style: TextStyle(fontSize: 16),
//         ),
//         SizedBox(height: 8),
//         Text(
//           'Type: ${restaurant.type}',
//           style: TextStyle(fontSize: 16),
//         ),
//         // ... Autres détails (téléphone, site web, etc.)
//       ],
//     );
//   }
// }
