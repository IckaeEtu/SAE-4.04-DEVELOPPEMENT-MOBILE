import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/restaurants/screens/RestaurantDetailScreen.dart';

// Pour l'utiliser il faut mettre dans le bouton "contect.go('lien de la page: /restaurant/123)"
final GoRouter routeur = GoRouter(routes: <RouteBase>[
  GoRoute(
    path: '/',
    builder: (context, state) {
      //return HomePage();
    },
  ),
  GoRoute(
    path: '/restaurant/:id',
    builder: (context, state) {
      final id = int.parse(state.params['id']);
      return RestaurantDetailScreen(restaurantId: id);
    },
  ),
  // Les autres routes qu'on devra mettre ..
]);
