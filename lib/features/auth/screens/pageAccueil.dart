import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil'), actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
        )
      ]),
      body: Center(child: Text('Bienvenue sur l\'application !')),
    );
  }
}