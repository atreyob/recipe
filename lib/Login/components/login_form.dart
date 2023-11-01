import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth/Dashboard.dart';
import 'package:http/http.dart' as http;
import '../../Components/already_have_an_account_acheck.dart';
import '../../Signup/signup_screen.dart';
import '../../constants.dart';

class LoginForm extends StatefulWidget {
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
      setState(() {});
//      Navigator.push(context, MaterialPageRoute(builder: (context) =>Dashboard()));
//      Navigator.pop(context);
      return null;
    }
    else{ throw Exception('Failed to create signup'); }
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
              hintText: "Your Email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: _passwordController,
              decoration: InputDecoration(
                  hintText: "Your Password",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  )
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  checklogin(_emailController.text, _passwordController.text);
                });
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context){
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
