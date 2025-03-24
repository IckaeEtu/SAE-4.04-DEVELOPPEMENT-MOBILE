import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routes/router.dart';

void main() {
  runApp(RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routerConfig: routeur,
      title: 'Restaurants Orléans',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RestaurantListScreen(),
    );
  }
}

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<dynamic> restaurants =;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response = await http.get(Uri.parse('http://localhost/SAE-401-D-VELOPPEMENT-WEB-PHP/recuperationRestaurant.php'));
    if (response.statusCode == 200) {
      setState(() {
        restaurants = json.decode(response.body);
      });
    } else {
      throw Exception('Impossible de charger les restaurants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants à Orléans'),
      ),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(restaurants[index]['nom']),
              subtitle: Text(restaurants[index]['description']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(id: restaurants[index]['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RestaurantDetailScreen extends StatefulWidget {
  final int id;

  RestaurantDetailScreen({required this.id});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Map<String, dynamic> restaurant = {};

  @override
  void initState() {
    super.initState();
    fetchRestaurantDetails();
  }

  Future<void> fetchRestaurantDetails() async {
    final response = await http.get(Uri.parse('http://localhost/SAE-401-D-VELOPPEMENT-WEB-PHP/restaurant_info.php?id=${widget.id}'));
    if (response.statusCode == 200) {
      setState(() {
        restaurant = json.decode(response.body);
      });
    } else {
      throw Exception('Impossible de charger les détails du restaurant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant['nom'] ?? 'Chargement...'),
      ),
      body: restaurant.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${restaurant['description']}', style: TextStyle(fontSize: 18)),
                  Text('Adresse: ${restaurant['adresse']}', style: TextStyle(fontSize: 16)),
                  // ... Autres détails
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}