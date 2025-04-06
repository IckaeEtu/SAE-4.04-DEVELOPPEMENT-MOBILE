import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response =
        await supabase.from('utilisateur').select('id, email, role');

    setState(() {
      _users = List<Map<String, dynamic>>.from(response);
      _filteredUsers = _users;
      _loading = false;
    });
  }

  void _searchUser(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              user['email'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _editUserRole(String userId, String newRole) async {
    await supabase
        .from('utilisateur')
        .update({'role': newRole}).eq('id', userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rôle mis à jour !'),
        backgroundColor: Colors.green,
      ),
    );

    await _fetchUsers();
  }

  void _showEditDialog(Map<String, dynamic> user) {
    String newRole = user['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modifier le rôle"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: newRole,
              items: ['admin', 'utilisateur']
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => newRole = value);
                }
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              _editUserRole(user['id'], newRole);
              Navigator.pop(context);
            },
            child: Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Gestion des Utilisateurs"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un utilisateur',
                suffixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchUser,
            ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(child: Text("Aucun utilisateur trouvé."))
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          child: ListTile(
                            title: Text(user['email']),
                            subtitle: Text("Rôle : ${user['role']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(user),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
