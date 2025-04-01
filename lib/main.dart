import 'package:flutter/material.dart';
import 'package:sae_mobile/features/HomePage.dart';
import 'package:sae_mobile/providers/data.dart';
import 'package:sae_mobile/routes/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://whkthddurdismomaktwj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indoa3RoZGR1cmRpc21vbWFrdHdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMxNDY3MzQsImV4cCI6MjA1ODcyMjczNH0.w91hFeZKgnJ0rmqDM4hf99xHyLCcCqG4vU2qDQTd7hs',
  );
  final supabaseHelper = SupabaseHelper();
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routeur,
    );
  }
}
