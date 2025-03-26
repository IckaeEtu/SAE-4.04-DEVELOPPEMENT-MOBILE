import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_routeur/go_routeur.dart';
import 'package:sae_mobile/features/HomePage.dart';
import 'package:sae_mobile/features/restaurants/screens/RestaurantDetailScreen.dart';

import 'RestaurantDetailScreen.dart';
import 'HomePage.dart';

// Pour l'utiliser il faut mettre dans le bouton "contect.go('lien de la page: /restaurant/123)"
final GoRouteur routeur = GoRouteur(
    routes: <RouteBase>[
        GoRoute(
            path: '/',
            builder: () {
                return HomePage();
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
    ]
)