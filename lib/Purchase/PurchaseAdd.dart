import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'package:data_tables/data_tables.dart';

class PurchaseAdd extends StatefulWidget{
  @override
  _PurchaseAddFormState createState() => _PurchaseAddFormState();
}

class _PurchaseAddFormState extends State<PurchaseAdd>{
  final TextEditingController _vendorController = TextEditingController();// inbuilt controller
  final TextEditingController _billnoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _grandtotalController = TextEditingController();

  final TextEditingController _itemQtyController = TextEditingController();
  final TextEditingController _itemRateController = TextEditingController();
  final TextEditingController _itemAmountController = TextEditingController();
  var ingData;
  var pdData;
  String dding = "1";
  String purchase_id  = "15";
  String parent_id  = "5";
  String prev_qty = "0";
  String pur_det_id = "0";
  String prev_ing_id = "0";

  final _formKey = GlobalKey();

  Future insertPurchase(String ing_id, String qty, String rate) async{
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/addpurchasedetail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': parent_id,
        'billno': _billnoController.text,
        'vendor': _vendorController.text,
        'pur_date': _dateController.text,
        'discount': _discountController.text == ''? "0": _discountController.text,
// user_id=5&billno=23&vendor=groc&pur_date=25-10-23&discount=0&purchase_id=0&ing_id=3&quantity=10&rate=10
        'purchase_id': purchase_id,
        'ing_id' : ing_id,
        'quantity': qty,
        'rate': rate,
      }),
    );

    if(response.statusCode == 200){
      print(response.body);
      var jsonData = json.decode(response.body);
      //{"status":1,"message":"Data Added Successfullly","data":[{"id":12,"purchase_id":15,"ing_id":2,"quantity":10,"rate":10,"amount":100,"is_active":1,"created_at":"2023-10-25T14:13:50.000000Z","updated_at":"2023-10-25T14:13:50.000000Z"},{"id":13,"purchase_id":15,"ing_id":3,"quantity":10,"rate":10,"amount":100,"is_active":1,"created_at":"2023-10-25T14:15:46.000000Z","updated_at":"2023-10-25T14:15:46.000000Z"}]}
      pdData = jsonData["data"];
      purchase_id= jsonData["purchase_id"].toString();
      purDatatable();
      _amountController.text = jsonData["amount"].toString();
      _discountController.text == ""? _discountController.text = "0": _discountController.text;
      _grandtotalController.text = (int.parse(_amountController.text) - int.parse(_discountController.text)).toString();
      setState(() {});
      Navigator.pop(context);
//      ingredientData();
      return null;
    }
    else{ throw Exception('Failed to work'); }
  }

  Future updatePurchase(String ing_id, String qty, String rate) async{
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/updatepurchasedetail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': parent_id,
        'billno': _billnoController.text,
        'vendor': _vendorController.text,
        'pur_date': _dateController.text,
        'discount': _discountController.text == ''? "0": _discountController.text,
// user_id=5&billno=23&vendor=groc&pur_date=30-10-23&discount=0&purchase_id=15&ing_id=2&quantity=1&rate=10&id=20&prev_qty=1&prev_ing_id=6
        'purchase_id': purchase_id,
        'ing_id' : ing_id,
        'quantity': qty,
        'rate': rate,
        'id': pur_det_id,
        'prev_qty': prev_qty,
        'prev_ing_id': prev_ing_id
      }),
    );

    if(response.statusCode == 200){
      print(response.body);
      var jsonData = json.decode(response.body);
      //{"status":1,"message":"Data Added Successfullly","data":[{"id":12,"purchase_id":15,"ing_id":2,"quantity":10,"rate":10,"amount":100,"is_active":1,"created_at":"2023-10-25T14:13:50.000000Z","updated_at":"2023-10-25T14:13:50.000000Z"},{"id":13,"purchase_id":15,"ing_id":3,"quantity":10,"rate":10,"amount":100,"is_active":1,"created_at":"2023-10-25T14:15:46.000000Z","updated_at":"2023-10-25T14:15:46.000000Z"}]}
      pdData = jsonData["data"];
      purDatatable();
      _amountController.text = jsonData["amount"].toString();
      _discountController.text == ""? _discountController.text = "0": _discountController.text;
      _grandtotalController.text = (int.parse(_amountController.text) - int.parse(_discountController.text)).toString();
      setState(() {});
      Navigator.pop(context);
//      ingredientData();
      return null;
    }
    else{ throw Exception('Failed to work'); }
  }

  Future<List> ingredientData() async{
    final response = await  http.get(Uri.parse("http://127.0.0.1:8000/api/getingredientsbyparentid/"+parent_id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      ingData = jsonData["data"];
      ingData.map((i){
        print(i);
      });
      purDatatable();
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Widget purDatatable(){
    print(pdData);
      if(pdData == null){
      return DataTable(
        columns: [
          DataColumn(label: Text('SrNo'),),
          DataColumn(label: Text('Particular'),),
          DataColumn(label: Text('Qty'),),
          DataColumn(label: Text('Rate'),),
          DataColumn(label: Text('Amount'),),
        ],
        rows: [],
      );
    }
    else{
      return DataTable(
        columns: [
          DataColumn(label: Text('SrNo'),),
          DataColumn(label: Text('Particular'),),
          DataColumn(label: Text('Qty'),),
          DataColumn(label: Text('Rate'),),
          DataColumn(label: Text('Amount'),),
          DataColumn(label: Text('Action'),),
        ],
        rows: List.generate(pdData.length, (index) {
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(pdData[index]["ing_name"].toString())),
            DataCell(Text(pdData[index]["quantity"].toString())),
            DataCell(Text(pdData[index]["rate"].toString())),
            DataCell(Text(pdData[index]["amount"].toString())),
          DataCell(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Expanded(child: IconButton(onPressed: (){setState(() {
            pur_det_id = pdData[index]["id"].toString();
            prev_qty = pdData[index]["quantity"].toString();
            prev_ing_id = pdData[index]["ing_id"].toString();
            dding = pdData[index]["ing_id"].toString();
            showBottomSheet(int.parse(purchase_id));
          });}, icon: Icon(Icons.edit))),
          Expanded(child: IconButton(onPressed: (){setState(() {
            showAlertDelete(context, pdData[index]["id"]);
          });}, icon: Icon(Icons.delete))),
          ]
          )),
          ]);
        }),
      );

    }
  }

  void showAlertDelete(BuildContext context, int id){
    Widget cancelButon = TextButton(onPressed:  (){ Navigator.of(context).pop();}, child: Text("Cancel"));
    Widget continueButton = TextButton(onPressed: (){deleteIngredient(id.toString());}, child: Text("Continue"));

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
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/deletepurchasedetail/'+ id));// inbuilt class
// String Uri not local
    if(response.statusCode == 200){
      print(response.body);
      var jsonData = json.decode(response.body);
      pdData = jsonData["data"];
      purDatatable();

      setState(() {});
      Navigator.pop(context);
      ingredientData();
    }
  }

  Future getPurchaseDetails() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/getpurchasedetails/' + purchase_id));
    if(response.statusCode ==200){
      var jsonData = json.decode(response.body);
      if(jsonData["data"] != null){
        pdData = jsonData["data"];
        purDatatable();
      }

      if(jsonData["purchase"] != null){
        var purchase = jsonData["purchase"];
        _vendorController.text =purchase[0]["vendor"].toString();
        _billnoController.text =purchase[0]["billno"].toString();
        _dateController.text =purchase[0]["pur_date"].toString();
        _amountController.text =purchase[0]["amount"].toString();
        _discountController.text =purchase[0]["discount"].toString();
        _grandtotalController.text =purchase[0]["grandtotal"].toString();
      }
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

  void calculateAmount(String qty, String rate){
  _itemAmountController.text = (int.parse(qty) * int.parse(rate)).toString();
  }

  void calculateGrandtotal(String amount, String discount){
    _grandtotalController.text = (int.parse(amount) * int.parse(discount)).toString();
  }
//Can we do a tasbkar\
  //Menubar : alreadty there...for recipe,
  //ok thank
  //
  void showBottomSheet(int? id) async{
    String qty="";
    String rate="";
    String amount="";
    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getpurchasedetailbyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        //print(jsonRec[0]);
       // name=jsonRec[0]["name"];
        _itemQtyController.text=jsonRec[0]["quantity"].toString();
        _itemRateController.text=jsonRec[0]["rate"].toString();
        _itemAmountController.text=jsonRec[0]["amount"].toString();
     //   ddunit=jsonRec[0]["unit_id"].toString();
      }
    }
    //_nameController.text = name;

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
                  TextField(controller: _itemQtyController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Quantity"),
                    onChanged: (String? value) {
                      setState(() {
                        calculateAmount(value!, _itemRateController.text);
                      });
                    },
                  ),
                  SizedBox(height: 10,),
                  TextField(controller: _itemRateController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Rate"),
                    onChanged: (String? value) {
                      setState(() {
                        calculateAmount(_itemQtyController.text, value!);
                      });
                    },
                  ),
                  SizedBox(height: 10,),
                  TextField(controller: _itemAmountController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Amount"), readOnly: true,),
                  SizedBox(height: 10,),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertPurchase(dding, _itemQtyController.text, _itemRateController.text);
                          }
                          else{
                            updatePurchase(dding, _itemQtyController.text, _itemRateController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 80,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _vendorController,
                  decoration: InputDecoration(labelText: 'Vendor Name'),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter vendor name';
                    }
                  },
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child:
                    TextFormField(
                      controller: _billnoController,
                      decoration: InputDecoration(labelText: 'Bill No.'),
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Please enter bill no.';
                        }
                      },
                    ),
                    ),
                    Expanded(child:
                    TextField(controller: _dateController,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(), labelText: "Select Bill Date"),
                      readOnly: true,
                      onTap: ()async{
                        DateTime? pickDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2021), lastDate: DateTime(2035));
                        if(pickDate !=null){
                          print(pickDate);
                          String formattedDate = DateFormat('dd-MM-yyyy').format(pickDate);
                          print(formattedDate);
                          setState(() {
                            _dateController.text = formattedDate;
                          });
                        }
                      },),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(child:
                    purDatatable()
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 150.0,
                      child: ElevatedButton(
                        onPressed: () { showBottomSheet(null); }, child: Text('Add Item'),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child:
                    TextField(controller: _amountController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Amount"),
                      readOnly: true,
                    ),
                    ),
                    Expanded(child:
                    TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(labelText: 'Discount'),
                      onChanged: (String? value) {
                        var discount = value!.toString();
                        setState(() {
                          calculateGrandtotal(_amountController.text, discount);
                        });
                      },
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Please enter discount';
                        }
                      },
                    ),
                    ),
                    Expanded(child:
                    TextField(controller: _grandtotalController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Grandtotal"),
                      readOnly: true,
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding / 2),
                ElevatedButton(onPressed: (

                    ){},
                  child: Text("Save".toUpperCase()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // return Form(
    //);
  }

  @override
  void initState() {
    getPurchaseDetails();
    ingredientData();
  }
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