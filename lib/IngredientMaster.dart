import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IngredientMaster extends StatefulWidget {
  @override
  State<IngredientMaster> createState()  => _IngredientMasterState();
}

class _IngredientMasterState extends State<IngredientMaster> {

  final TextEditingController _nameController = TextEditingController();// inbuilt controller
  final TextEditingController _qtyController = TextEditingController();// inbuilt controller
  var unitData;
  String ddunit = "1";
  String parent_id = "5";

  Future insertIngredientMaster(String name, String qty, String unitId ) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/addingredientmaster'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name' : name,
        'quantity': qty,
        'unit_id': unitId,
        'user_id' : parent_id,
      }),
    );
    if(response.statusCode == 200){
      var jsonData = json.decode(response.body);
      setState(() {});
      Navigator.pop(context);
      fetchData();
      return null;
    }
    else{ throw Exception('Failed to create album'); }
  }
  Future updateIngredientMaster(int id, String name, String qty, String unit_id) async {
    print('here');
    final response = await   http.post(
        Uri.parse('http://127.0.0.1:8000/api/updateingredientmaster'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id' : id,
          'name' : name,
          'quantity': qty,
          'unit_id': unit_id,
          'user_id' : parent_id
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
        Uri.parse('http://127.0.0.1:8000/api/getingredientmaster/'+ parent_id),
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      unitData = jsonData["units"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> getIngredientMasterFields(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getingredientmasterbyid/'+ id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      ddunit = jsonRec[0];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Widget unitList(){
    print(unitData);
    List<UnitObj> unitList = List<UnitObj>.from(
     unitData.map((i){
       return UnitObj.fromJSON(i);
     })
    );

    return DropdownButtonFormField(
      hint: Text("Select Unit"),
        isExpanded: true,
        items: unitList.map((e){
          return DropdownMenuItem(child: Text(e.name), value: e.id,);
        }).toList(),
        onSaved: (String? value){
          ddunit = value!.toString();
        setState(() {
          ddunit;
          print(ddunit);
        });},
      value: ddunit, onChanged: (String? value) {
        ddunit = value!.toString();
        setState(() {
          ddunit;
          print(ddunit);
        });
        },
    );
  }

  void showBottomSheet(int? id) async {
    String name= '';
    String qty= '';
    String unit_id= '';
    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getingredientmasterbyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        //print(jsonRec[0]);
        name=jsonRec[0]["name"];
        qty=jsonRec[0]["quantity"].toString();
        ddunit=jsonRec[0]["unit_id"].toString();
      }
    }
    _nameController.text = name;
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
                  unitList(),
                  SizedBox(height: 10,),
                  TextField(controller: _qtyController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Quantity"),),
                  SizedBox(height: 10,),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertIngredientMaster(_nameController.text, _qtyController.text, ddunit);
                          }
                          else{
                            updateIngredientMaster(id, _nameController.text, _qtyController.text, ddunit);
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

  //function to open alert dialog after clicking on delete button on recipe item in the list. we are passing 'id' to this function so that we can
  //call function deleteRecipe and pass that id to it.
  showAlertDelete(BuildContext context, int id)
  {
    Widget cancelButton = TextButton(onPressed:  (){ Navigator.of(context,rootNavigator: true).pop(false);}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed:  (){deleteIngredientMaster(id.toString()); Navigator.of(context, rootNavigator: true).pop(true);}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete this Ingredient?"),
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

  Future deleteIngredientMaster(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/deleteingredientmaster/'+ id));
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {});
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
      appBar: AppBar(title: Text("Ingredient Master"), backgroundColor: Colors.cyan),
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
                final itemModal = IngredientMasterModel(snapshot.data![index]['id'], snapshot.data![index]['name'], snapshot.data![index]['quantity'].toString(), snapshot.data![index]['unit_id'].toString());
                return Card(margin: EdgeInsets.all(5),
                  child: ListTile(
                    title: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(snapshot.data![index]['name'],
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

class IngredientMasterModel{
  final int im_id;
  final String name;
  final String qty;
  final String unit_id;

  const IngredientMasterModel(this.im_id, this.name, this.qty, this.unit_id);
}

class ResponseObj{
  int status;
  String message;
  String data;
  ResponseObj(this.status, this.message, this.data);
}

class UnitObj{
  String id, name;
  UnitObj({required this.id, required this.name});
  factory UnitObj.fromJSON(Map<String, dynamic> json){
    return UnitObj(
      id:json["id"].toString(),
      name:json["name"],
    );
  }
}