import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sae_mobile/theme/footer.dart';
import 'package:sae_mobile/theme/header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = ['Restaurant étoilé', 'Fast-food', 'Gastronomie'];
  Set<Map<String, dynamic>> searchResults = {};
  List<Map<String, dynamic>> topRestaurants = [];
  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(48.8566, 2.3522); 
  final Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();
    fetchTopRestaurants();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    // Implémentation simplifiée - utilisez geolocator en production
    setState(() {
      _currentPosition = LatLng(48.8566, 2.3522); // Paris
      _markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: _currentPosition,
          infoWindow: InfoWindow(title: 'Votre position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
    _addRestaurantMarkers();
  }

void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("current"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Votre position"),
        ),
      );
    });
  }


  void _addRestaurantMarkers() async {
    final response = await supabase.from('restaurant').select('id, nom, latitude, longitude');
    
    if (response != null && response.isNotEmpty) {
      setState(() {
        for (var restaurant in response) {
          if (restaurant['latitude'] != null && restaurant['longitude'] != null) {
            _markers.add(
              Marker(
                markerId: MarkerId(restaurant['id'].toString()),
                position: LatLng(restaurant['latitude'], restaurant['longitude']),
                infoWindow: InfoWindow(
                  title: restaurant['nom'],
                  onTap: () => context.go('/restaurant/${restaurant['id']}'),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            );
          }
        }
      });
    }
  }

  void fetchTopRestaurants() async {
    try {
      final response = await supabase
          .from('critique')
          .select('id_restaurant, avg(note) as moyenne, restaurant!inner(id, nom, adresse)')
          .order('moyenne', ascending: false)
          .limit(2);

      List<Map<String, dynamic>> fetchedRestaurants = response
          .map((r) => {
            'id': r['restaurant']['id'], 
            'nom': r['restaurant']['nom'], 
            'adresse': r['restaurant']['adresse']
          })
          .toList();

      setState(() {
        topRestaurants = fetchedRestaurants; 
      });
    } catch (e) {
      print("Erreur lors de la récupération des meilleurs restaurants: $e");
    }
  }

  void fetchSearchResults(String query) async {
    try {
      final response = await supabase
          .from('restaurant')
          .select('id, nom, type, adresse')
          .or("nom.ilike.%$query%, type.ilike.%$query%, adresse.ilike.%$query%");

      setState(() {
        searchResults = response.isNotEmpty
            ? response.map((r) => {
                'id': r['id'],
                'nom': r['nom'],
                'type': r['type'],
                'adresse': r['adresse']
              }).toSet()
            : {};
      });
    } catch (e) {
      setState(() {
        searchResults = {};
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, 
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Restaurants à la une"),
              onTap: () => context.go('/best_rated_restaurant'),
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text("Publier un avis"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text("Admin"),
              onTap: () => context.go('/admin'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Se déconnecter"),
              onTap: () => context.go('/logout'),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildSearchContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        onTap: _onItemTapped,
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Où manger aujourd'hui ?", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
          SizedBox(height: 20),
          
          // Carte Google Maps
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 12,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: categories.map((category) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent, 
                foregroundColor: Colors.white),
              onPressed: () {
                _searchController.text = category;
                fetchSearchResults(category);
              },
              child: Text(category, style: const TextStyle(fontSize: 16)),
            )).toList(),
          ),
          SizedBox(height: 20),
          Text("Les meilleurs restaurants :", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          topRestaurants.isEmpty
              ? Text("Aucun restaurant disponible.", 
                  style: TextStyle(fontSize: 16, color: Colors.black54))
              : Column(
                  children: topRestaurants.map((restaurant) => ListTile(
                    title: Text(restaurant['nom'], 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(restaurant['adresse']),
                    onTap: () => context.go('/restaurant/${restaurant['id']}'),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSearchContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un restaurant...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: fetchSearchResults,
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: searchResults.isEmpty
                  ? [Text('Aucun restaurant trouvé.', style: TextStyle(fontSize: 16, color: Colors.black87))]
                  : searchResults.map((restaurant) => ListTile(
                        title: Text(restaurant['nom'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(restaurant['adresse']),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          int restaurantId = restaurant['id'];
                          print("Navigation vers le restaurant ID: $restaurantId");
                          context.go('/restaurant/$restaurantId');
                        },
                      )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}