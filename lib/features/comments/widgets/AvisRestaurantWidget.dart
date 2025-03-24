import 'package:flutter/material.dart';
import 'package:sae_mobile/data/data.dart';

class AvisRestaurantWidget extends StatefulWidget {
  final int restaurantId;
  final int? userId;

  const AvisRestaurantWidget({super.key, required this.restaurantId, this.userId});

  @override
  _AvisRestaurantWidgetState createState() => _AvisRestaurantWidgetState();
}

class _AvisRestaurantWidgetState extends State<AvisRestaurantWidget> {
  List<Map<String, dynamic>> avisList = [];
  bool isLoading = true;
  int newNote = 1;
  String newCommentaire = '';
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadAvis();
  }

  Future<void> _loadAvis() async {
    avisList = await dbHelper.getAvisRestaurant(widget.restaurantId);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteAvis(int avisId) async {
    await dbHelper.deleteAvis(avisId);
    _loadAvis();
  }

  Future<void> _addAvis() async {
    if (widget.userId != null) {
      await dbHelper.addAvis(widget.restaurantId, widget.userId!, newCommentaire, newNote);
      _loadAvis();
      setState(() {
        newCommentaire = '';
        newNote = 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour laisser un avis.')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Critiques:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (avisList.isEmpty)
        Text('Aucun avis trouvé.')
      else
//List<int> liste1 = [1, 2, 3];
//List<int> liste2 = [0, ...liste1, 4, 5]; // liste2 contient [0, 1, 2, 3, 4, 5]
        ...avisList.map((avis) => _buildAvisItem(avis)),
      SizedBox(height: 20),
      Text('Laisser un avis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (widget.userId != null)
        _buildAvisForm()
      else
        Text('Vous devez être connecté pour laisser un avis.'),
    ],
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
          Text(DateTime.parse(avis['date_creation']).toString(), style: TextStyle(fontWeight: FontWeight.bold)),
          Text(avis['commentaire'] ?? ''),
          Text('Note: ${avis['note']}/5', style: TextStyle(fontWeight: FontWeight.bold)),
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
              .map((value) => DropdownMenuItem(value: value, child: Text(value.toString())))
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
        ElevatedButton(
          onPressed: _addAvis,
          child: Text('Envoyer'),
        ),
      ],
    );
  }
}