import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final bool isAdmin;
  final bool isLoggedIn;

  const Header({
    Key? key,
    required this.isAdmin,
    required this.isLoggedIn, required List<IconButton> actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset('images/logo.png', height: 40),
          const SizedBox(width: 10),
          const Text("TriPOTEvisor"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/best_rated_restaurant');
          },
          child: const Text("Restaurants à la une", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            // Ajoute ici la logique pour publier un avis
          },
          child: const Text("Publier un avis", style: TextStyle(color: Colors.white)),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.search, color: Colors.white),
          onSelected: (String value) {
            // Logique pour rechercher un type de nourriture
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: "Cuisine française",
              child: Text("Cuisine française"),
            ),
            const PopupMenuItem<String>(
              value: "Cuisine italienne",
              child: Text("Cuisine italienne"),
            ),
          ],
        ),
        if (isAdmin)
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
            child: const Text("Admin", style: TextStyle(color: Colors.white)),
          ),
        if (isLoggedIn)
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/logout');
            },
            child: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
          )
        else
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("Se connecter", style: TextStyle(color: Colors.white)),
          ),
      ],
      backgroundColor: Colors.green, // Change la couleur si nécessaire
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
