import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class Kids extends StatefulWidget {
  @override
  State<Kids> createState()  => _KidsState();
}

class _KidsState extends State<Kids> {
  String relationvalue = 'Select Relationship';
  var relationItems =[
    'Select Relationship',
    'Mother',
    'Father',
    'Guardian'
  ];

  String dietvalue = 'Select Diet';
  var dietItems =[
    'Select Diet',
    'Veg',
    'Nov Veg',
    'Vegan'
  ];

  int gender=1;
  String radioButtonItem = 'Male';
  String parent_id = "5"; //we will change dynamically later.

  final TextEditingController _nameController = TextEditingController();// inbuilt controller
  final TextEditingController _ageController = TextEditingController();// inbuilt controller

  Future insertKids(String name, String age, String relation, String diet, String gender ) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/addkid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name' : name,
        'age': age,
        'gender': gender,
        'relation': relation,
        'parent_id' : parent_id,
        'diet': diet
      }),
    );
    if(response.statusCode == 200){
      var jsonData = json.decode(response.body);
      if(jsonData['status'] == 0){
        Fluttertoast.showToast(msg: jsonData['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else{
        setState(() {});
        Navigator.pop(context);
        fetchData();
      }
      return null;
    }
    else{ throw Exception('Failed to create album'); }
  }

  Future updateKids(int id, String name, String age, String relation, String diet, String gender) async {
    final response = await   http.post(
        Uri.parse('http://127.0.0.1:8000/api/updatekid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id' : id,
          'name' : name,
          'age': age,
          'relation': relation,
          'parent_id' : parent_id,
          'diet': diet,
          'gender': gender
        })
    );
    if(response.statusCode == 200){
      var jsonData = json.decode(response.body);
      if(jsonData['status'] == 0){
        Fluttertoast.showToast(msg: jsonData['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else{
        setState(() {});
        Navigator.pop(context);
        fetchData();
      }
      return null;
    }
    else{
      throw Exception('Failed to update record'); }
  }
  Future<List> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/getkids/'+parent_id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> getKidsFields(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getkidbyid/'+ id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      relationvalue = jsonRec[0];
      dietvalue = jsonRec[0];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Widget relationList(){
    return DropdownButtonFormField(
      hint: Text("Select Relation"),
      isExpanded: true,
      items: relationItems.map((e){
        return DropdownMenuItem(child: Text(e), value: e,);
      }).toList(),
      onSaved: (String? value){
        relationvalue = value!.toString();
        setState(() {
          relationvalue;
        });},
      value: relationvalue, onChanged: (String? value) {
      relationvalue = value!.toString();
      setState(() {
        relationvalue;
      });
    },
    );
  }

  Widget dietList(){
    return DropdownButtonFormField(
      hint: Text("Select Diet"),
      isExpanded: true,
      items: dietItems.map((e){
        return DropdownMenuItem(child: Text(e), value: e,);
      }).toList(),
      onSaved: (String? value){
        dietvalue = value!.toString();
        setState(() {
          dietvalue;
        });},
      value: dietvalue, onChanged: (String? value) {
      dietvalue = value!.toString();
      setState(() {
        dietvalue;
      });
    },
    );
  }

  void showBottomSheet(int? id) async {
    String name= '';
    String age= '';
    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getkidbyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        //print(jsonRec[0]);
        name=jsonRec[0]["name"];
        age=jsonRec[0]["age"].toString();
        relationvalue=jsonRec[0]["relation"].toString();
        dietvalue=jsonRec[0]["diet"].toString();
        gender = int.parse(jsonRec[0]["gender"].toString() );
      }
    }
    _nameController.text = name;
    _ageController.text = age;

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
                  relationList(),
                  dietList(),
                  SizedBox(height: 10,),
                  TextField(controller: _ageController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Age"),),
                  SizedBox(height: 10,),
                  Padding(padding: EdgeInsets.symmetric(vertical: defaultPadding),
                    child: StatefulBuilder(builder: (BuildContext context, StateSetter setState){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Radio(value: 1, groupValue: gender, onChanged: (val){
                            setState(() {
                              radioButtonItem = "Male";
                              gender  =1;
                            });
                          },),
                          Text('Male', style: new TextStyle(fontSize: 17.0),),
                          Radio(value: 2, groupValue: gender, onChanged: (val){
                            setState(() {
                              radioButtonItem = "Female";
                              gender = 2;
                            });
                          },),
                          Text('Female', style: new  TextStyle(fontSize: 17.0),),
                          Radio(value: 3, groupValue: gender, onChanged: (val){
                            setState(() {
                              radioButtonItem = "Other";
                              gender  = 3;
                            });
                          },),
                          Text('Other', style: new  TextStyle(fontSize: 17.0),),
                        ],
                      );
                    },)

                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertKids(_nameController.text, _ageController.text, relationvalue,dietvalue,  gender.toString());
                          }
                          else{
                            updateKids(id, _nameController.text, _ageController.text, relationvalue,dietvalue,  gender.toString());
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
    Widget cancelButton = TextButton(onPressed:  (){ Navigator.of(context, rootNavigator: true).pop(false);}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed:  (){deleteKid(id.toString()); Navigator.of(context, rootNavigator: true).pop(true);}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete this kid entry?"),
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

  Future deleteKid(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/deletekid/'+ id));
    if (response.statusCode == 200) {
      print(response.body);
       setState(() {});
//      Navigator.pop(context);
     // build(context);
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
      appBar: AppBar(title: Text("Kids"), backgroundColor: Colors.cyan),
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
                final itemModal = KidModel(snapshot.data![index]['id'], snapshot.data![index]['name'], snapshot.data![index]['age'].toString(), snapshot.data![index]['relation'].toString(), snapshot.data![index]['diet'].toString());
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

class KidModel{
  final int k_id;
  final String name;
  final String age;
  final String relation;
  final String diet;

  const KidModel(this.k_id, this.name, this.age, this.relation, this.diet);
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