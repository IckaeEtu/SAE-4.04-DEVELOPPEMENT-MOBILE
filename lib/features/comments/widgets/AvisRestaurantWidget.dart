import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sae_mobile/providers/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class AvisRestaurantWidget extends StatefulWidget {
  final int restaurantId;
  final int? userId;

  const AvisRestaurantWidget({
    super.key,
    required this.restaurantId,
    this.userId,
  });

  @override
  _AvisRestaurantWidgetState createState() => _AvisRestaurantWidgetState();
}

class _AvisRestaurantWidgetState extends State<AvisRestaurantWidget> {
  List<Map<String, dynamic>> avisList = [];
  bool isLoading = true;
  int newNote = 1;
  String newCommentaire = '';
  String? newImageUrl;
  final dbHelper = SupabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadAvis();
  }

  Future<void> _loadAvis() async {
    setState(() {
      isLoading = true;
    });
    try {
      avisList = await dbHelper.getAvisRestaurant(widget.restaurantId);
      print("avisList: $avisList");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des avis: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAvis(int avisId) async {
    try {
      await dbHelper.deleteAvis(avisId);
      _loadAvis();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'avis: $e')),
      );
    }
  }

  Future<void> _addAvis() async {
    if (widget.userId != null) {
      String? imageUrl;
      if (newImageUrl != null) {
        imageUrl = await _uploadImage(File(newImageUrl!));
      }
      try {
        await dbHelper.addAvis(
          widget.restaurantId,
          widget.userId!,
          newCommentaire,
          newNote,
          imageUrl,
        );
        _loadAvis();
        setState(() {
          newCommentaire = '';
          newNote = 1;
          newImageUrl = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'avis: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour laisser un avis.'),
        ),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final filePath = 'test.jpg'; // Test avec un nom de fichier simple
      final response = await Supabase.instance.client.storage
          .from('images')
          .upload(filePath, image);

      try {
        if (response == null || response.isEmpty) {
          throw Exception('Aucune donnée trouvée.');
        }
      } catch (e) {
        print('Erreur Supabase: $e');
        throw e;
      }

      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newImageUrl = pickedFile.path;
      });
    }
  }

  void _showAddAvisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Laisser un avis'),
          content: SingleChildScrollView(child: _buildAvisForm()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAvisDialog(context),
        child: Icon(Icons.add_comment),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Critiques:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (avisList.isEmpty)
              Text('Aucun avis trouvé.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: avisList.length,
                itemBuilder: (context, index) {
                  return _buildAvisItem(avisList[index]);
                },
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisItem(Map<String, dynamic> avis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateTime.parse(avis['date_creation']).toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (avis['img'] != null) // Modification ici
            Image.network(
              avis['img'],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          Text(avis['commentaire'] ?? ''),
          Text(
            'Note: ${avis['note']}/5',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (widget.userId == avis['id_utilisateur'])
            ElevatedButton(
              onPressed: () => _deleteAvis(avis['id']),
              child: Text('Supprimer cet avis'),
            ),
        ],
      ),
    );
  }

  Widget _buildAvisForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note:'),
        DropdownButton<int>(
          value: newNote,
          items: List.generate(5, (index) => index + 1)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString()),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                newNote = value;
              });
            }
          },
        ),
        Text('Commentaire:'),
        TextFormField(
          onChanged: (value) => newCommentaire = value,
          decoration: InputDecoration(border: OutlineInputBorder()),
          maxLines: 3,
        ),
        ElevatedButton(onPressed: _pickImage, child: Text('Choisir une image')),
        if (newImageUrl != null)
          Text('Image sélectionnée: ${newImageUrl!.split('/').last}'),
        ElevatedButton(onPressed: _addAvis, child: Text('Envoyer')),
      ],
    );
  }
}
