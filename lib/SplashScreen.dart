import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe/login/LoginPage.dart';
class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Container(
        color: Colors.cyan,
          child: Center( child: Text('Recipe' , style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white ),)),
      ),
    );
  }

  @override
  void initState() {
    Timer(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => LoginPage(),
      ));
    });
  }
}