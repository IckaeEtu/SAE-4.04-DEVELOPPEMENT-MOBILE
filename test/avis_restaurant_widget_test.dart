import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sae_mobile/features/comments/widgets/AvisRestaurantWidget.dart';

void main() {
  testWidgets('affiche les widgets de base', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AvisRestaurantWidget(restaurantId: 1, userId: 1)));

    expect(find.text('Critiques:'), findsOneWidget);
    expect(find.text('Laisser un avis:'), findsOneWidget);
    expect(find.byType(DropdownButton<int>), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Deux TextFormField (note et commentaire)
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('affiche le message si aucun avis', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AvisRestaurantWidget(restaurantId: 1, userId: 1)));

    expect(find.text('Aucun avis trouvé.'), findsOneWidget);
  });

  testWidgets('affiche les avis si présents', (WidgetTester tester) async {
    final avisList = [
      {
        'id': 1,
        'id_restaurant': 1,
        'id_utilisateur': 1,
        'commentaire': 'Très bon restaurant !',
        'note': 5,
        'date_creation': DateTime.now().toString(),
      },
    ];

    await tester.pumpWidget(MaterialApp(
      home: AvisRestaurantWidget(restaurantId: 1, userId: 1),
    ));

    expect(find.text('Très bon restaurant !'), findsOneWidget);
    expect(find.text('Note: 5/5'), findsOneWidget);
  });

  testWidgets('affiche le formulaire d\'ajout d\'avis si l\'utilisateur est connecté', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AvisRestaurantWidget(restaurantId: 1, userId: 1)));

    expect(find.byType(DropdownButton<int>), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('affiche le message si l\'utilisateur n\'est pas connecté', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AvisRestaurantWidget(restaurantId: 1, userId: null)));

    expect(find.text('Vous devez être connecté pour laisser un avis.'), findsOneWidget);
  });
}