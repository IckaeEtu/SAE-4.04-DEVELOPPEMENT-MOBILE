import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sae_mobile/features/HomePage.dart';

import 'dart:convert';

import 'package:sae_mobile/theme/header.dart';
import 'package:sae_mobile/theme/footer.dart';
import 'package:sae_mobile/data/data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

