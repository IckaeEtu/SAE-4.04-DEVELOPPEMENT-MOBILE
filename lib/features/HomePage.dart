import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:sae_mobile/features/Favoris/FavorisProvider.dart'; // Import FavoritesProvider
import 'package:sae_mobile/core/models/Restaurant.dart'; // Import Restaurant model
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> topRestaurants = [];
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(48.8566, 2.3522);
  final Set<Marker> _markers = {};
  String? _userRole;

  @override
  void initState() {
    super.initState();
    fetchTopRestaurants();
  }

  Future<void> _fetchUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('role');
  }

  void _navigateToAdmin() async {
    await _fetchUserRole();
    print(_userRole == 'admin');

    if (_userRole == 'admin') {
      context.go('/admin');
    } else {
      print('test');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accès refusé. Vous n\'êtes pas administrateur.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchTopRestaurants() async {
    try {
      final response = await supabase
          .from('critique')
          .select('id_restaurant, restaurant(nom, adresse, description), note')
          .order('note', ascending: false)
          .limit(3);

      List<Map<String, dynamic>> fetchedRestaurants = response
          .map<Map<String, dynamic>>((r) => {
                'id': r['id_restaurant'],
                'nom': r['restaurant']['nom'],
                'adresse': r['restaurant']['adresse'],
                'description': r['restaurant']
                    ['description'], // Ajout de la description
              })
          .toList();

      setState(() {
        topRestaurants = fetchedRestaurants;
      });
    } catch (e) {
      print("Erreur lors de la récupération des meilleurs restaurants: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchSearchResults(String query) async {
    try {
      final response = await supabase
          .from('restaurant')
          .select('id, nom, type, adresse')
          .or("nom.ilike.%$query%, type.ilike.%$query%, adresse.ilike.%$query%");

      setState(() {
        searchResults = response.isNotEmpty
            ? response
                .map((r) => {
                      'id': r['id'],
                      'nom': r['nom'],
                      'type': r['type'],
                      'adresse': r['adresse']
                    })
                .toList()
            : [];
      });
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await supabase.auth.signOut();
    if (mounted) {
      context.go('/logout');
    }
  }


  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Où manger aujourd'hui ?",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent)),
          SizedBox(height: 10),
          Text("Les meilleurs restaurants :",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          topRestaurants.isEmpty
              ? Text("Aucun restaurant disponible.",
                  style: TextStyle(fontSize: 16, color: Colors.black54))
              : Column(
                  children: topRestaurants
                      .map((restaurant) => ListTile(
                            title: Text(restaurant['nom'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurant['adresse'],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54)),
                                SizedBox(height: 4),
                                Text(
                                  restaurant['description'] ??
                                      'Aucune description disponible', // Affichage de la description
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            onTap: () =>
                                context.go('/restaurant/${restaurant['id']}'),
                          ))
                      .toList(),
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: fetchSearchResults,
          ),
          SizedBox(height: 20),
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text('Aucun restaurant trouvé.',
                        style: TextStyle(fontSize: 16, color: Colors.black87)))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final restaurant = searchResults[index];
                      return ListTile(
                        title: Text(restaurant['nom'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(restaurant['adresse']),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () =>
                            context.go('/restaurant/${restaurant['id']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorisContent() {
    final favorisProvider = Provider.of<FavorisProvider>(context);
    final favoriteRestaurants = favorisProvider.favoriteRestaurants;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Mes Restaurants Favoris",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: favoriteRestaurants.isEmpty
                ? Center(
                    child: Text(
                        "Vous n'avez pas encore de restaurants favoris.",
                        style: TextStyle(fontSize: 16, color: Colors.black87)))
                : ListView.builder(
                    itemCount: favoriteRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = favoriteRestaurants[index];
                      return Card(
                        child: ListTile(
                          title: Text(restaurant.nom,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text(restaurant.adresse),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              favorisProvider.removeFavorite(restaurant.id!);
                            },
                          ),
                          onTap: () =>
                              context.go('/restaurant/${restaurant.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page d'accueil")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text("Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
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
              onTap: () => _navigateToAdmin(),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Se déconnecter"),
              onTap: () => _logout(),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : _selectedIndex == 1
              ? _buildSearchContent()
              : _buildFavorisContent(), // Affiche les favoris
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoris'), // Change Profil en Favoris
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orangeAccent,
        onTap: _onItemTapped,
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
