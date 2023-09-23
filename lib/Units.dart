import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Units extends StatefulWidget {
  @override
  State<Units> createState()  => _UnitsState();
}

class _UnitsState extends State<Units> {

  final TextEditingController _nameController = TextEditingController();// inbuilt controller

  Future insertUnit(String name) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/addunit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name' : name,
        'user_id' : 1,
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
  Future updateUnit(int id, String name) async {
    print('here');
    final response = await   http.post(
        Uri.parse('http://127.0.0.1:8000/api/updateunit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id' : id,
          'name' : name,
          'user_id' : 1
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
        Uri.parse('http://127.0.0.1:8000/api/getunits'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> getUnitFields(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getunitbyid/'+ id));
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

    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getunitbyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        //print(jsonRec[0]);
        name=jsonRec[0]["name"];
      }
    }
    _nameController.text = name;

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
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertUnit(_nameController.text);
                          }
                          else{
                            updateUnit(id, _nameController.text);
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
    Widget cancelButton = TextButton(onPressed:  (){ Navigator.of(context).pop();}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed:  (){deleteRecipe(id.toString());}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete this Unit?"),
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
        Uri.parse('http://127.0.0.1:8000/api/deleteunit/'+ id));
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
      appBar: AppBar(title: Text("Unit"), backgroundColor: Colors.cyan),
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
                final itemModal = UnitModel(snapshot.data![index]['id'], snapshot.data![index]['name']);
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

class UnitModel{
  final int unit_id;
  final String name;

  const UnitModel(this.unit_id, this.name);
}

class ResponseObj{
  int status;
  String message;
  String data;
  ResponseObj(this.status, this.message, this.data);
}