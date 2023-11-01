import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth/Drawer.dart';
import 'dart:convert';
import '../Recipe.dart';
import 'PurchaseAdd.dart';

class Purchase extends StatefulWidget {
  @override
  State<Purchase> createState()  => _PurchaseState();
}
// Main Purchase widget which is a StatefulWidget

class _PurchaseState extends State<Purchase> {
  // Function to fetch data from the API

  Future<List> fetchData() async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/getpurchases'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  //function to open alert dialog after clicking on delete button on recipe item in the list. we are passing 'id' to this function so that we can
  //call function deleteRecipe and pass that id to it.
  showAlertDelete(BuildContext context, int id)
  {
    Widget cancelButton = TextButton(onPressed:  (){ Navigator.of(context).pop();}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed:  (){deleteRecipe(id.toString());}, child: Text("Continue"));

    AlertDialog alertDialog = AlertDialog(
      title: Text("Alert!"),
      content: Text("Are you sure you want to delete this purchase?"),
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
  // Function to delete a recipe by ID from the API

  Future deleteRecipe(String id) async {
    final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/deletepurchase/'+ id));
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
      appBar: AppBar(title: Text("Purchase"), backgroundColor: Colors.cyan),
      drawer: NavDrawer(),
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
                final itemModal = RecipeModel(snapshot.data![index]['id'], snapshot.data![index]['vendor']);
                return Card(margin: EdgeInsets.all(5),
                  child: ListTile(
                    title: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(snapshot.data![index]['vendor'],
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
       onPressed: (() => Navigator.of(context).push(MaterialPageRoute(builder: (context) => PurchaseAdd()))),
       child: Icon(Icons.add),
     ),
    );
  }
}

class PurchaseModel{
  final int id;
  final String vendor;
  final String billno;
  final String date;
  final String discount;
  final String amount;
  final String grandtotal;

  const PurchaseModel(this.id, this.vendor, this.billno, this.date, this.discount, this.amount, this.grandtotal);
}

class ResponseObj{
  int status;
  String message;
  String data;
  ResponseObj(this.status, this.message, this.data);
}