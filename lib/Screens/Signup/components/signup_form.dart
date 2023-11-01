import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget{
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>{
  String dropdownvalue = 'Select Occupation';
  var items =[
    'Select Occupation',
    'IT',
    'Banking',
    'Consultant',
    'Professional',
    'Teaching',
    'Other'
  ];

  int id=1;
  String radioButtonItem = 'Male';
  final TextEditingController _nameController = TextEditingController();// inbuilt controller
  final TextEditingController _phonenoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  Future insertSignup(String name, String password, String phone_no, String email, String occupation, String gender) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/addsignup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name' : name,
        'password': password,
        'phone_no': phone_no,
        'email': email,
        'occupation': occupation,
        'gender': gender
      }),
    );
    if(response.statusCode == 200){
      print(response.body);
      var jsonData = json.decode(response.body);
      setState(() {});
      Navigator.pop(context);
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
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            controller: _nameController,
            onSaved: (name) {},
            decoration: InputDecoration(
              hintText: "Your Name",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.man),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              controller: _phonenoController,
              onSaved: (phone){},
              decoration: InputDecoration(
                hintText: "Your Phone No",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.phone),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child:           TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              controller: _emailController,
              onSaved: (email) {},
              decoration: InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email),
                ),
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
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: DropdownButton(
              value: dropdownvalue,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((item){
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }
              ).toList(),
              onChanged: (String? newValue){
                setState((){
                  dropdownvalue = newValue!;
                });
              },
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio(value: 1, groupValue: id, onChanged: (val){
                  setState(() {
                    radioButtonItem = 'Male';
                    id =1;
                  });
                },),
                Text('Male', style: new TextStyle(fontSize: 17.0),),
                Radio(value: 2, groupValue: id, onChanged: (val){
                  setState(() {
                    radioButtonItem= 'Female';
                    id=2;
                  });
                },),
                Text('Female', style: new TextStyle(fontSize: 17.0),),
                Radio(value: 3, groupValue: id, onChanged: (val){
                  setState(() {
                    radioButtonItem = 'Other';
                    id=3;
                  });
                },),
                Text('Other', style: new TextStyle(fontSize: 17.0),),
              ],
            )
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () {
              setState(() {
                  insertSignup(_nameController.text, _passwordController.text, _phonenoController.text, _emailController.text, dropdownvalue, id.toString());
              });
            },
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
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
