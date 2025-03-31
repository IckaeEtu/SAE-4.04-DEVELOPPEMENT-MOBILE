import 'package:flutter/material.dart';
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
  List<String> categories = ['Restaurant', 'Fast_food', 'bar'];
  List<String> images = ['/images/img1.png', '/images/img2.png', '/images/img3.png'];
  Set<String> searchResults = {};

  void fetchSearchResults(String query) async {
    try {
      final response = await supabase.from('restaurant')
          .select()
          .or("nom.ilike.%$query%, type.ilike.%$query%, adresse.ilike.%$query%");
      if (response.isNotEmpty) {
        setState(() {
          searchResults = response.map((restaurant) => '${restaurant['nom']} - ${restaurant['type']} - ${restaurant['adresse']}').toSet();
        });
      } else {
        setState(() {
          searchResults = {'Aucun restaurant trouvé pour votre recherche.'};
        });
      }
    } catch (e) {
      setState(() {
        searchResults = {'Erreur lors de la recherche: $e'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(isAdmin: true, isLoggedIn: false),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Où manger aujourd'hui ?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: categories.map((category) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _searchController.text = category;
                  fetchSearchResults(category);
                },
                child: Text(category, style: TextStyle(fontSize: 16)),
              )).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Restaurant gastronomique, fast-food, ville...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                fetchSearchResults(value);
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: searchResults.map((result) {
                      // Extraire uniquement le nom du restaurant
                      String restaurantName = result.split(' - ')[0];

                      return GestureDetector(
                        onTap: () {
                          // Action à effectuer lorsque l'on clique sur le nom du restaurant
                          // Par exemple, naviguer vers une nouvelle page de détails
                          print("Restaurant cliqué: $restaurantName");
                          // Vous pouvez remplacer le print par une navigation vers une page de détails
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            restaurantName,
                            style: TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((img) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(img, width: 80, height: 80, fit: BoxFit.cover),
                ),
              )).toList(),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Site développé par : Eliott, Mickael, David et Benjamin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
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
