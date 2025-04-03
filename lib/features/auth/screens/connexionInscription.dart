import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw 'Veuillez remplir tous les champs.';
      }

      if (_isLogin) {
        // Connexion : Vérifier si l'utilisateur existe avec cet email et mot de passe
        final response = await supabase
            .from('utilisateur')
            .select()
            .eq('email', email)
            .eq('mot_de_passe', password)
            .single();

        if (response == null) {
          throw 'Identifiants incorrects.';
        }

        // Stocker l'ID utilisateur en local
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', response['id']);
        await prefs.setString('role', response['role']);

        if (mounted) {
          print(response);
          context.go('/home');
        }
      } else {
        // Inscription : Vérifier si l'email existe déjà
        final existingUser = await supabase
            .from('utilisateur')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (existingUser != null) {
          throw 'Cet email est déjà utilisé.';
        }

        // Insérer le nouvel utilisateur
        final nom = _nomController.text.trim();
        final prenom = _prenomController.text.trim();
        final telephone = _telephoneController.text.trim();

        final response = await supabase.from('utilisateur').insert({
          'email': email,
          'mot_de_passe': password, // ⚠️ Idéalement, stocker un hash sécurisé
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'role': 'utilisateur', // Rôle par défaut
        }).select().single();

        // Stocker l'ID utilisateur
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', response['id']);
        await prefs.setString('role', response['role']);

        if (mounted) {
          context.go('/home');
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Connexion' : 'Inscription',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                if (!_isLogin) ...[
                  SizedBox(height: 16),
                  TextField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _telephoneController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
                SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLogin ? 'Se connecter' : "S'inscrire",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                          });
                        },
                  child: Text(
                    _isLogin
                        ? "Créer un compte"
                        : "Déjà un compte ? Se connecter",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
