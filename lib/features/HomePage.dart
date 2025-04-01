import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/theme/footer.dart';
import 'package:sae_mobile/theme/header.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
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
  Set<Map<String, dynamic>> searchResults = {};
  List<Map<String, dynamic>> topRestaurants = [];
  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(48.8566, 2.3522); // Paris
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    fetchTopRestaurants();
  }

  void fetchTopRestaurants() async {

  try {
    // RÃ©cupÃ©ration des deux meilleurs restaurants avec leurs infos
    final response = await supabase
        .from('critique')
        .select('id_restaurant, restaurant(nom, adresse), avg(note) as moyenne')
        .order('moyenne', ascending: false) // Tri des notes moyennes (descendant)
        .limit(2); // On rÃ©cupÃ¨re les 2 meilleurs restaurants

    // Construction de la liste des meilleurs restaurants
    List<Map<String, dynamic>> fetchedRestaurants = response.map<Map<String, dynamic>>((r) => {
      'id': r['id_restaurant'],
      'nom': r['restaurant']['nom'],
      'adresse': r['restaurant']['adresse'],
    }).toList();

    setState(() {
      topRestaurants = fetchedRestaurants; // Mise Ã  jour de la liste des meilleurs restaurants
    });
  } catch (e) {
    print("Erreur lors de la rÃ©cupÃ©ration des meilleurs restaurants: $e");
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
              title: Text("Restaurants Ã  la une"),
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
              title: Text("Se dÃ©connecter"),
              onTap: () => context.go('/logout'),
            ),
      appBar: AppBar(title: const Text("Page d'accueil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Les meilleurs restaurants :",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            topRestaurants.isEmpty
                ? Text(
                    "Aucun restaurant disponible.",
                    style: TextStyle(fontSize: 16, color: Colors.black54))
                : Column(
                    children: topRestaurants.map((restaurant) {
                      return ListTile(
                        title: Text(
                          restaurant['nom'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(restaurant['adresse']),
                        onTap: () {
                          // Navigation vers la page de détail du restaurant
                          context.go('/restaurant/${restaurant['id']}');  // Utilisation de context.go
                        },
                      );
                    }).toList(),
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
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OÃ¹ manger aujourd'hui ?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: categories.map((category) => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white),
            onPressed: () {
              _searchController.text = category;
              fetchSearchResults(category);
            },
            child: Text(category, style: const TextStyle(fontSize: 16)),
          )).toList(),
        ),
        SizedBox(height: 20),
        Text("Les meilleurs restaurants :", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        topRestaurants.isEmpty
            ? Text("Aucun restaurant disponible.", style: TextStyle(fontSize: 16, color: Colors.black54))
            : Column(
                children: topRestaurants.map((restaurant) => ListTile(
                  title: Text(restaurant['nom'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  ? [Text('Aucun restaurant trouvÃ©.', style: TextStyle(fontSize: 16, color: Colors.black87))]
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
