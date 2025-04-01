import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTopRestaurants();
  }

  Future<void> fetchTopRestaurants() async {
    try {
      final response = await supabase
          .from('critique')
          .select('id_restaurant, restaurant(nom, adresse), note')
          .order('note', ascending: false)
          .limit(2);

      List<Map<String, dynamic>> fetchedRestaurants = response.map<Map<String, dynamic>>((r) => {
            'id': r['id_restaurant'],
            'nom': r['restaurant']['nom'],
            'adresse': r['restaurant']['adresse'],
          }).toList();

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
            ? response.map((r) => {
                  'id': r['id'],
                  'nom': r['nom'],
                  'type': r['type'],
                  'adresse': r['adresse']
                }).toList()
            : [];
      });
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Où manger aujourd'hui ?", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
          SizedBox(height: 10),
          Text("Les meilleurs restaurants :", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          topRestaurants.isEmpty
              ? Text("Aucun restaurant disponible.", style: TextStyle(fontSize: 16, color: Colors.black54))
              : Column(
                  children: topRestaurants
                      .map((restaurant) => ListTile(
                            title: Text(restaurant['nom'], 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            subtitle: Text(restaurant['adresse']),
                            onTap: () => context.go('/restaurant/${restaurant['id']}'),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: fetchSearchResults,
          ),
          SizedBox(height: 20),
          Expanded(
            child: searchResults.isEmpty
                ? Center(child: Text('Aucun restaurant trouvé.', style: TextStyle(fontSize: 16, color: Colors.black87)))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final restaurant = searchResults[index];
                      return ListTile(
                        title: Text(restaurant['nom'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(restaurant['adresse']),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => context.go('/restaurant/${restaurant['id']}'),
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
}
