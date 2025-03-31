import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sae_mobile/theme/footer.dart';
import 'package:sae_mobile/theme/header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'Restaurant étoilé',
    'Fast-food',
    'Gastronomie'
  ];
  final List<String> images = [
    '/images/img1.png',
    '/images/img2.png',
    '/images/img3.png'
  ];
  Set<Map<String, dynamic>> searchResults = {};

  void fetchSearchResults(String query) async {
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
                .toSet()
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
      appBar: Header(isAdmin: true, isLoggedIn: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Où manger aujourd'hui ?",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: categories
                  .map((category) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          _searchController.text = category;
                          fetchSearchResults(category);
                        },
                        child: Text(category,
                            style: const TextStyle(fontSize: 16)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Restaurant gastronomique, fast-food, ville...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: fetchSearchResults,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 5)
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: searchResults.isEmpty
                        ? [
                            Text('Aucun restaurant trouvé.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87))
                          ]
                        : searchResults
                            .map((restaurant) => GestureDetector(
                                  onTap: () {
                                    int restaurantId = restaurant['id'];
                                    print(
                                        "Navigation vers le restaurant ID: $restaurantId");
                                    context.go('/restaurant/$restaurantId');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      restaurant['nom'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ))
                            .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images
                  .map((img) => Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(img,
                              width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Site développé par : Eliott, Mickael, David et Benjamin',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
            ),
            Footer(),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
