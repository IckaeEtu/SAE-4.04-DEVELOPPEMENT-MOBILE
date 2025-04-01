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
    );
  }
}
