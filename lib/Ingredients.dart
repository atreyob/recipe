import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_auth/Recipe.dart';

class Ingredients extends StatefulWidget{
  const Ingredients({super.key, required this.recModal});
  final RecipeModel recModal;

  @override
  State<StatefulWidget> createState() => _IngredientsState();
}

 class _IngredientsState extends State<Ingredients> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  var ingData;
  String dding = "1";

// custom function
Future insertIngredient(String ing_id, String qty, String carbs, String proteins, String expiry, String remark) async{
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/addingredient'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'recipe_id': widget.recModal.recipe_id.toString(),
        'ing_id' : ing_id,
        'quantity': qty,
        'carbs': carbs,
        'protein': proteins,
        'expiry_date': expiry,
        'details': remark
      }),
    );
    if(response.statusCode == 200){
      print(response.body);
      setState(() {});
      Navigator.pop(context);
      ingredientData();
      return null;
    }
    else{ throw Exception('Failed to work'); }
  }
  
  Future<List> ingredientData() async{
    final response = await  http.get(Uri.parse("http://127.0.0.1:8000/api/getingredients/"+ widget.recModal.recipe_id.toString()));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      ingData = jsonData["im"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

   // Define a function to update an ingredient with the provided data
   Future updateIngredient(int id, String ing_id, String qty, String carbs, String proteins, String expiry, String remark) async {
     // Send an HTTP POST request to update the ingredient
     final response = await http.post(
       Uri.parse('http://127.0.0.1:8000/api/updateingredient'),
       headers: <String, String>{
         'Content-Type': 'application/json;charset=UTF-8',
       },
       body: jsonEncode(<String, dynamic>{
         'id': id,
         'ing_id': ing_id,
         'quantity': qty,
         'carbs': carbs,
         'protein': proteins,
         'expiry_date': expiry,
         'remark': remark
       }),
     );
     // Check if the HTTP response status code is 200 (OK)
     if (response.statusCode == 200) {
       // If successful, print the response body
       print(response.body);
       // Update the state of the widget (Assuming this code is inside a StatefulWidget)
       setState(() {});
       // Close the current screen and return to the previous screen (Assuming you're using a Navigator)
       Navigator.pop(context);
       // Call a function to refresh ingredient data
       ingredientData();
       // Return null to signify a successful update
       return null;
     } else {
       // If the HTTP response status code is not 200, throw an exception
       throw Exception('Failed to update ingredient');
     }
   }

  Widget ingList(){
    List<IngObj> ingList = List<IngObj>.from(
        ingData.map((i){
          return IngObj.fromJSON(i);
        })
    );
    return DropdownButtonFormField(
      hint: Text("Select Ingredient"),
      isExpanded: true,
      items: ingList.map((e){
        return DropdownMenuItem(child: Text(e.name), value: e.id,);
      }).toList(),
      onSaved: (String? value){
        dding = value!.toString();
        setState(() {
          dding;
          print(dding);
        });},
      value: dding, onChanged: (String? value) {
      dding = value!.toString();
      setState(() {
        dding;
        print(dding);
      });
    },
    );

  }

  void showBottomSheet(int? id) async{
    String qty="";
    String carbs="";
    String protien="";
    String remark="";
    String expiry_date="";

    if(id != null){
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/getingredientbyid/"+ id.toString()));
      if(response.statusCode == 200){
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        dding = jsonRec[0]["ing_id"].toString();
        qty = jsonRec[0]["quantity"].toString();
        carbs = jsonRec[0]["carbs"].toString();
        protien = jsonRec[0]["protein"].toString();
        remark = jsonRec[0]["remark"].toString();
        expiry_date = jsonRec[0]["expiry_date"];
      }
      else{
        throw Exception('Failed to load data');
      }
    }
    _qtyController.text =qty;
    _carbController.text =carbs;
    _proteinController.text = protien;
    _remarkController.text = remark;
    _expiryController.text = expiry_date;

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
                  ingList(),
                  SizedBox(height: 10,),
                  TextField(controller: _qtyController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Quantity"),),
                  SizedBox(height: 10,),
                  TextField(controller: _carbController,
                  decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Carbs"),),
                  SizedBox(height: 10,),
                  TextField(controller: _proteinController,
                  decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Proteins"),),
                  SizedBox(height: 10,),
                  TextField(controller: _expiryController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(), labelText: "Select Expiry Date"),
                  readOnly: true,
                  onTap: ()async{
                    DateTime? pickDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2015), lastDate: DateTime(2025));
                    if(pickDate !=null){
                      print(pickDate);
                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickDate);
                      print(formattedDate);
                      setState(() {
                        _expiryController.text = formattedDate;
                      });
                    }
                  },),
                  SizedBox(height: 10),
                  TextField(controller: _remarkController,
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Details"),),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertIngredient(dding, _qtyController.text, _carbController.text, _proteinController.text, _expiryController.text, _remarkController.text);
                          }
                          else{
                            updateIngredient(id, dding, _qtyController.text, _carbController.text, _proteinController.text, _expiryController.text, _remarkController.text);
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
            )
    );
  }

  //function to delete the ingredients.. it will alert first to user, after user confirm the delete action it will delete the record and refresh the screen
  void showAlertDelete(BuildContext context, int id){
    Widget cancelButon = TextButton(onPressed:  (){ Navigator.of(context, rootNavigator: true).pop(false);}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed: (){deleteIngredient(id.toString()); Navigator.of(context, rootNavigator: true).pop(true);}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete the ingredient"),
      actions: [
        cancelButon,
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

  Future deleteIngredient(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/deleteingredient/'+ id));// inbuilt class
// String Uri not local
    if(response.statusCode == 200){
      print(response.body);
      setState(() {});
      ingredientData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recModal.recipe_name),
      ),
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
  // DONT UNDERSTAND THIS
          // IF IT WORKS IT GOES HERE!
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final id = snapshot.data![index]['id'];
                // final itemModal = IngredientModel(widget.recModal.recipe_id, snapshot.data![index]['id'], snapshot.data![index]['ingredient_name'],
                //     snapshot.data![index]['quantity'], snapshot.data![index]['carbs'], snapshot.data![index]['protein'],
                //     snapshot.data![index]['expiry_date'], snapshot.data![index]['remark']);
                return Card(margin: EdgeInsets.all(5),
                  child: ListTile(
                    title: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(snapshot.data![index]['name'],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    trailing: Container(width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: IconButton(onPressed: () {
                            setState(() {
                              showBottomSheet(id);
                            });
                          }, icon: Icon(Icons.edit))),
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
        future: ingredientData(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => showBottomSheet(null)),
        child: Icon(Icons.add),
      ),
    );
  }//Explained
}

class IngredientModel{
  final int recipe_id;
  final int ing_id;
  final String Ing_name;
  final String Ing_qty;
  final String Ing_carbs;
  final String Ing_proteins;
  final String Ing_expiry;
  final String Ing_remark;// not mutable

 const IngredientModel(this.recipe_id, this.ing_id, this.Ing_name, this.Ing_qty, this.Ing_carbs, this.Ing_proteins, this.Ing_expiry, this.Ing_remark);
}

class IngObj{
  String id, name;
  IngObj({required this.id, required this.name});
  factory IngObj.fromJSON(Map<String, dynamic> json){
    return IngObj(
      id:json["id"].toString(),
      name:json["name"],
    );
  }
}