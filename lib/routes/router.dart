import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/features/HomePage.dart';
import 'package:sae_mobile/features/restaurants/screens/RestaurantDetailScreen.dart';

final GoRouter routeur = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/restaurant/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('ID de restaurant invalide.')),
          );
        }
        return RestaurantDetailScreen(restaurantId: id);
      },
    ),
  ],
);