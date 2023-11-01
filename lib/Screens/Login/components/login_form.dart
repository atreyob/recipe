import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../../Dashboard.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Signup/signup_screen.dart';
import 'package:flutter_auth/Recipe.dart';
class LoginForm extends StatefulWidget{
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>{
  final TextEditingController _emailController = TextEditingController();// inbuilt controller
  final TextEditingController _passwordController = TextEditingController();

  Future checklogin( String email, String password) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/checklogin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'password': password,
        'email': email,
      }),
    );
    if(response.statusCode == 200){
      print(response.body);
      var jsonData = json.decode(response.body);
      if(jsonData['status'] == 1){
     Navigator.push(context, MaterialPageRoute(builder: (context) =>Dashboard()));
      }
      else{
        Fluttertoast.showToast(msg: "Invalid login details",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        textColor: Colors.white,
        fontSize: 16.0);
      }
      setState(() {});
//      Navigator.pop(context);
      return null;
    }
    else{ throw Exception('Failed to create signup'); }
  }

  void _showErrorDialog(BuildContext context){
    final alert = AlertDialog(
      title: Text("Error"),
      content: Text("Login Failed"),
      actions: [TextButton(child: Text("Ok"), onPressed: () {})],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.go,
              obscureText: true,
              controller: _passwordController,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {setState(() {
                checklogin(_emailController.text, _passwordController.text);
              });},
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
