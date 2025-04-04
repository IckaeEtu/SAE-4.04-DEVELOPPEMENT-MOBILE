import 'package:flutter/material.dart';
import 'package:sae_mobile/core/models/Restaurant.dart';
import 'package:sae_mobile/features/Favoris/FavorisProvider.dart';
import 'package:sae_mobile/features/comments/widgets/AvisRestaurantWidget.dart';
import 'package:sae_mobile/providers/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/features/restaurants/providers/RestaurantProvider.dart';
class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({Key? key, required this.restaurantId})
      : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Future<Restaurant?>? _restaurantFuture;
  Future<List<String?>>? _commentImagesFuture;

  @override
  void initState() {
    super.initState();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    _restaurantFuture =
        restaurantProvider.fetchRestaurantDetails(widget.restaurantId);
    _commentImagesFuture =
        restaurantProvider.fetchRestaurantImages(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du restaurant'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          context.go('/home');
          return false;
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
          // ... (le reste de votre code reste le même)
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
          const SizedBox(height: 20),
          // Affichage des images
          FutureBuilder<List<String?>>(
            future: _commentImagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur : ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return _buildImageGallery(snapshot.data!);
              } else {
                return const SizedBox.shrink(); // Aucune image à afficher
              }
            },
          ),
          const SizedBox(height: 20),
          // Ajout du widget AvisRestaurantWidget
          AvisRestaurantWidget(restaurantId: restaurant.id!),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String?> images) {
  if (images.length <= 3) {
    return Row(
      children: images
          .where((image) => image != null)
          .map((image) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(
                  image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ))
          .toList(),
    );
  } else {
    return Row(
      children: images
              .take(2)
              .where((image) => image != null)
              .map((image) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ))
              .toList() +
          [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: Center(
                  child: Text('+${images.length - 2}', style: const TextStyle(fontSize: 20)),
                ),
              ),
            )
          ],
    );
  }
}
}