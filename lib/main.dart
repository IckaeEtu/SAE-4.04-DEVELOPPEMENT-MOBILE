import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/router.dart'; // Assurez-vous que le chemin est correct
import 'package:sae_mobile/features/HomePage.dart';
import 'package:sae_mobile/providers/data.dart';
import 'package:sae_mobile/routes/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:sae_mobile/features/Favoris/FavorisProvider.dart'; // Import FavoritesProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://whkthddurdismomaktwj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indoa3RoZGR1cmRpc21vbWFrdHdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNDY3MzQsImV4cCI6MjA1ODcyMjczNH0.w91hFeZKgnJ0rmqDM4hf99xHyLCcCqG4vU2qDQTd7hs',
  );

  runApp(
    // Enveloppe MyApp avec ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => FavorisProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router, // Utilisez la variable router que vous avez définie
    );
  }
}