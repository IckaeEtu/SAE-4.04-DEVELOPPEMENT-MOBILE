import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sae_mobile/providers/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart' as material;

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
  XFile? _pickedImage;

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
        SnackBar(content: material.Text('Erreur lors du chargement des avis: $e')),
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
      await _loadAvis();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: material.Text('Erreur lors de la suppression de l\'avis: $e')),
      );
    }
  }

  Future<void> _addAvis() async {
    if (widget.userId != null) {
      String? imageUrl = await _uploadImage();

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
          _pickedImage = null;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: material.Text('Avis posté avec succès!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: material.Text('Erreur lors de l\'ajout de l\'avis : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: material.Text('Vous devez être connecté pour laisser un avis.')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    final imageBytes = await _pickedImage!.readAsBytes();

    final storagePath =
        'images/${DateTime.now().millisecondsSinceEpoch}${path.extension(_pickedImage!.path)}';

    try {
      await supabase.storage.from("images").uploadBinary(
            storagePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: _pickedImage!.mimeType,
              upsert: true,
            ),
          );

      final imageUrl = supabase.storage.from("images").getPublicUrl(storagePath);
      return imageUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Ajouté cette ligne
      children: [
        Flexible( // Modifié Expanded en Flexible
          child: avisList.isEmpty
              ? Center(child: material.Text('Aucun avis trouvé.'))
              : ListView.builder(
                  itemCount: avisList.length,
                  itemBuilder: (context, index) {
                    return _buildAvisItem(avisList[index]);
                  },
                ),
        ),
        ElevatedButton(
          onPressed: () => _showAddAvisDialog(context),
          child: Icon(Icons.add_comment),
        ),
      ],
    );
  }

  Future<void> _showAddAvisDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: material.Text('Ajouter un avis'),
          content: SingleChildScrollView(
            child: _buildAvisForm(),
          ),
          actions: <Widget>[
            TextButton(
              child: material.Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvisItem(Map<String, dynamic> avis) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          material.Text(DateTime.parse(avis['date_creation']).toString(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          if (avis['img'] != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
              child: Image.network(avis['img'], fit: BoxFit.cover),
            ),
          material.Text(avis['commentaire'] ?? ''),
          material.Text('Note: ${avis['note']}/5', style: TextStyle(fontWeight: FontWeight.bold)),
          if (widget.userId == avis['id_utilisateur'])
            ElevatedButton(
                onPressed: () async {
                  await _deleteAvis(avis['id']);
                },
                child: material.Text('Supprimer cet avis')),
        ],
      ),
    );
  }

  Widget _buildAvisForm() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter formSetState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            material.Text('Note:'),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton<int>(
                  value: newNote,
                  items: List.generate(5, (index) => index + 1)
                      .map((value) => DropdownMenuItem(value: value, child: material.Text(value.toString())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        newNote = value;
                      });
                    }
                  },
                );
              },
            ),
            material.Text('Commentaire:'),
            TextFormField(
              onChanged: (value) => newCommentaire = value,
              decoration: InputDecoration(border: OutlineInputBorder()),
              maxLines: 3,
            ),
            ElevatedButton(
              onPressed: () async {
                final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1980, maxHeight: 1980);
                if (image != null) {
                  formSetState(() {
                    _pickedImage = image;
                  });
                }
              },
              child: material.Text('Choisir une image'),
            ),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Image sélectionnée: ${_pickedImage!.name}'),
              ),
            ElevatedButton(onPressed: _addAvis, child: material.Text('Envoyer')),
          ],
        );
      },
    );
  }
}