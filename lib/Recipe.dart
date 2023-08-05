import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:recipe/login/Button.dart';

class Recipe extends StatefulWidget {
    @override
    State<Recipe> createState()  => _RecipeState();
}

class _RecipeState extends State<Recipe> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  Future insertRecipe(String recipe_name, String recipe_quantity, String details) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/addrecipe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name' : recipe_name,
        'quantity': recipe_quantity,
        'details': details
    }),
    );
  if(response.statusCode == 200){
       setState(() {});
       Navigator.pop(context);
       fetchData();
       return null;
    }
    else{ throw Exception('Failed to create album'); }
  }

  Future updateRecipe(int id, String recipe_name, String recipe_quantity, String details) async {
    print('here');
    final response = await   http.post(
      Uri.parse('http://127.0.0.1:8000/api/updaterecipe'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id' : id,
        'name' : recipe_name,
        'quantity': recipe_quantity,
        'details': details
      })
    );
    if(response.statusCode == 200){
      setState(() {});
      Navigator.pop(context);
      fetchData();
      return null;
    }
    else{
      throw Exception('Failed to update record'); }
  }
  Future<List> fetchData() async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getrecipes'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> getRecipeFields(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getrecipebyid/'+ id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  void showBottomSheet(int? id) async {
    String name= '';
    String qty= '';
    String details= '';

    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getrecipebyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        //print(jsonRec[0]);
        name=jsonRec[0]["recipe_name"];
        qty=jsonRec[0]["recipe_quantity"].toString();
        details=jsonRec[0]["details"];
      }
    }
    _nameController.text = name;
    _detailsController.text = details;
    _qtyController.text = qty;

    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) =>
            Container(
              padding: EdgeInsets.only(
                top: 30, left: 15, right: 15, bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 50,
              ),
              child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(controller: _nameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Name"),),
                  SizedBox(height: 10,),
                  TextField(controller: _qtyController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Quantity"),),
                  SizedBox(height: 10),
                  TextField(controller: _detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Details"),),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertRecipe(_nameController.text, _qtyController.text, _detailsController.text);
                          }
                          else{
                            updateRecipe(id, _nameController.text, _qtyController.text, _detailsController.text);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(id == null ? "Add" : "Update",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            )
                        ),
                      ),
                    ),
                  )
                ],),
            ));
  }

  //function to open alert dialog after clicking on delete button on recipe item in the list. we are passing 'id' to this function so that we can
  //call function deleteRecipe and pass that id to it.
  showAlertDelete(BuildContext context, int id)
  {
    Widget cancelButton = TextButton(onPressed:  (){ Navigator.of(context).pop();}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed:  (){deleteRecipe(id.toString());}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete this Recipe?"),
      actions: [
        cancelButton,
        continueButton
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return alertDialog;
        }
    );
  }

  Future deleteRecipe(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/deleterecipe/'+ id));
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {});
      Navigator.pop(context);
      fetchData();

      return null;
    }
    else {
      throw Exception('Failed to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Recipe"), backgroundColor: Colors.cyan),
      body: FutureBuilder(
        builder: (context, snapshot) {
          // WHILE THE CALL IS BEING MADE AKA LOADING
          if (ConnectionState.active != null && !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // WHEN THE CALL IS DONE BUT HAPPENS TO HAVE AN ERROR
          if (ConnectionState.done != null && snapshot.hasError) {
            return Center(child: Text("error"));
          }

          // IF IT WORKS IT GOES HERE!
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final id = snapshot.data![index]['id'];
              return Card(margin: EdgeInsets.all(5),
                child: ListTile(
                  title: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(snapshot.data![index]['recipe_name'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  trailing: Container(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: IconButton(onPressed: () {
                          setState(() {
                            showBottomSheet(id);
                          });
                        }, icon: Icon(Icons.edit))),
                        Expanded(child: IconButton(onPressed: () {}, icon: Image.asset('lib/icons/vegetables.png'))),
                        Expanded(child: IconButton(onPressed: () {
                          setState(() {
                            showAlertDelete(context, id);
                          });
                        }, icon: Icon(Icons.delete))),
                      ],
                    ),
                  ),
                ),
              );
            }
          );
        },
        future: fetchData(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => showBottomSheet(null)),
        child: Icon(Icons.add),
      ),
    );
  }
}

class ResponseObj{
  int status;
  String message;
  String data;
    ResponseObj(this.status, this.message, this.data);
}

class ResponseObject{
  int status;
  String message;
  List<RecipeObject> data;

  ResponseObject({required this.status, required this.message, required this.data});

}

class RecipeObject{
  String recipe_name;
  String recipe_quantity;
  String details;

  RecipeObject({required this.recipe_name, required this.recipe_quantity, required this.details});
  factory RecipeObject.fromJson(Map<String, dynamic> json) => RecipeObject(
        recipe_name: json["recipe_name"], recipe_quantity: json['recipe_quantity'],
        details: json["details"]);

  Map<String, dynamic> toJson() => {
    "recipe_name": recipe_name,
    "recipe_quantity": recipe_quantity,
    "details": details
  };
  }