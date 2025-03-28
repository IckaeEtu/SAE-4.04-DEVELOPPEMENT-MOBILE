// import 'package:flutter/material.dart';
// import 'package:sae_mobile/data/data.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final dbHelper = DatabaseHelper();
//   await dbHelper.testDatabase();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Test Database')),
//         body: Center(
//           child: Text('Voir la console pour les résultats des tests.'),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sae_mobile/data/data.dart';
import 'package:sae_mobile/features/restaurants/screens/RestaurantDetailScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  // await dbHelper.testDatabase();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RestaurantDetailScreen(
          restaurantId: 1), // Appel du widget RestaurantDetailScreen
    );
  }
}
