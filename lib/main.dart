import 'package:flutter/material.dart';
import 'package:recipe/Recipe.dart';
import 'SplashScreen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
    debugShowCheckedModeBanner: false,
        home: Recipe(),
    );
  }
}