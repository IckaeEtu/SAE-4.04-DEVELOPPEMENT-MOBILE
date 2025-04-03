import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sae_mobile/features/auth/screens/connexionInscription.dart';
import 'package:sae_mobile/features/restaurants/screens/RestaurantDetailScreen.dart';
import 'package:sae_mobile/features/HomePage.dart';
import 'package:sae_mobile/features/admin/screens/adminPage.dart';

final GoRouter router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;

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
      path: '/logout',
      builder: (BuildContext context, GoRouterState state) => AuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => HomePage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (BuildContext context, GoRouterState state) => AdminPage(),
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