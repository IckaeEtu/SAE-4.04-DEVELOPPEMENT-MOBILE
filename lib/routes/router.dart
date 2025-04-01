import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/screens/connexionInscription.dart';
import 'package:sae_mobile/features/restaurants/screens/RestaurantDetailScreen.dart';
import '../features/HomePage.dart';

final GoRouter router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;

    // Utilisez state.uri.path au lieu de state.location
    if (state.uri.path == '/' && isAuthenticated) {
      return '/home';
    }

    if (!isAuthenticated && state.uri.path == '/home') {
      return '/';
    }

    return null;
  },
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => AuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => HomePage(),
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