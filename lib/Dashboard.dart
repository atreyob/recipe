import 'package:flutter/material.dart';
import 'package:flutter_auth/main.dart';

import 'Drawer.dart';

void main() => runApp(MyApp());

class Dashboard extends StatelessWidget{
  const Dashboard({super.key});

  static const appTitle = 'Scheduler';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState  extends State<MyHomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Text("Dashboard"),
      ),
      drawer: NavDrawer(),
    );
  }
}