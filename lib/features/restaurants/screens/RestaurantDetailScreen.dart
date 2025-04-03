import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/features/Favoris/FavorisProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;
  final _supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _fetchRestaurantDetails();
  }

  Future<Restaurant?> _fetchRestaurantDetails() async {
    try {
      final result = await _supabaseClient
          .from('restaurant')
          .select()
          .eq('id', widget.restaurantId);
      if (result != null && result.isNotEmpty) {
        return Restaurant.fromMap((result as List).first);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du restaurant : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du restaurant'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/home'); // Retourne directement à la page d'accueil avec GoRouter
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Ici, vous pouvez ajouter du code avant de revenir en arrière
          context.go('/home'); // Pour s'assurer que le retour se fait vers la page d'accueil
          return false; // empêche la fermeture de la page actuelle
        },
        child: FutureBuilder<Restaurant?>(
          future: _restaurantFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              return _buildRestaurantDetails(snapshot.data!);
            } else {
              return const Center(child: Text('Restaurant introuvable'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildRestaurantDetails(Restaurant restaurant) {
    final favorisProvider = Provider.of<FavorisProvider>(context);
    final isFavorite = favorisProvider.isFavorite(restaurant.id!);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(restaurant.nom,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (isFavorite) {
                    favorisProvider.removeFavorite(restaurant.id!);
                  } else {
                    favorisProvider.addFavorite(restaurant);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(restaurant.adresse,
                      style: const TextStyle(fontSize: 16))),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.category, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Type: ${restaurant.type}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(),
          Text('Description:',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(restaurant.description ?? 'N/A',
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
