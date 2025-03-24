
import 'package:flutter/material.dart';
import 'package:sae_mobile/theme/footer.dart';
import 'package:sae_mobile/theme/header.dart';
import 'package:http/http.dart' as http;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> categories = ['Restaurant étoilé', 'Fast-food', 'Gastronomie'];
  List<String> images = [
  '/assets/images/img1.png',
  '/assets/images/img2.png',
  '/assets/images/img3.png',

];
  String searchResult = "";
  

  void fetchSearchResults(String query) async {
    final response = await http.get(Uri.parse('https://yourbackend.com/recuperationRestaurant.php?query=$query'));
    if (response.statusCode == 200) {
      setState(() {
        searchResult = response.body;
      });
    } else {
      setState(() {
        searchResult = 'Erreur lors de la récupération des données';
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
            Text("Où manger aujourd'hui ?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: categories.map((category) => ElevatedButton(
                onPressed: () {
                  _searchController.text = category;
                  fetchSearchResults(category);
                },
                child: Text(category),
              )).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Restaurant gastronomique, fast-food...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                fetchSearchResults(value);
              },
            ),
            SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(searchResult))),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((img) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(img, width: 80, height: 80),
              )).toList(),
            ),
            SizedBox(height: 10),
            Center(child: Text('Site développé par : Eliott, Mickael, David et Benjamin')),

            Footer(),
          ],
        ),
      ),
    );
  }
}