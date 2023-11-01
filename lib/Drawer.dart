import 'package:flutter/material.dart';
import 'package:flutter_auth/Dashboard.dart';
import 'package:flutter_auth/Recipe.dart';
import 'package:flutter_auth/IngredientMaster.dart';

import 'Kids.dart';

class NavDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.33,
      child: Drawer(
        child: Container(
          color: Colors.cyan,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: const Text('Home'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Dashboard())),
              ),
              ListTile(
                title: const Text('Recipe'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Recipe())),
              ),
              ListTile(
                title: const Text('Ingredient Master'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => IngredientMaster())),
              ),
              ListTile(
                title: const Text('Kids'),
                textColor: Colors.white,
                trailing: Icon(
                  Icons.child_care,
                  color: Colors.white,
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Kids())),
              )
            ],
          ),
        )
      ),
    );
  }

}