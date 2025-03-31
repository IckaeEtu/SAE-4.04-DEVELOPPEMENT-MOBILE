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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routes/router.dart';
import 'package:sae_mobile/data/data.dart';
import 'package:sae_mobile/features/auth/screens/connexionInscription.dart';
import 'package:sae_mobile/features/auth/screens/apresConnexion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://whkthddurdismomaktwj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indoa3RoZGR1cmRpc21vbWFrdHdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNDY3MzQsImV4cCI6MjA1ODcyMjczNH0.w91hFeZKgnJ0rmqDM4hf99xHyLCcCqG4vU2qDQTd7hs',
  );

  final supabaseHelper = SupabaseHelper();
  await supabaseHelper
      .initialiserEtRemplirTables("data/restaurants_orleans.json");

  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth App',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HomePage(),
        '/auth': (context) => AuthPage(),
      },
    );
  }
}
