import 'package:flutter/material.dart';

import '../login/Header.dart';
import '../login/InputWrapper.dart';
// ALL OF THIS I UNDERSTANS except for
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,  // what is this double.infinity
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.cyan[500]!,
                Colors.cyan[300]!,
                Colors.cyan[400]!
              ]),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 80,),
                Header(),
                Expanded(child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      )
                  ),
                  child: InputWrapper(),
                ))
              ],
            ),
            ),
        );
    }
}