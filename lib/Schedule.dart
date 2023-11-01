import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  @override
  State<Schedule> createState()  => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String firstDate = "";
  DateTime vFirstDate = DateTime.now();
  var ingData;
  String dding = "1";
  int ddtype = 0;
  var scheduleData;
  String kid_id = "15";
  String selectedDate ="";

  List<ScheduleType> types = <ScheduleType>[const ScheduleType(0, "Select Time"), const ScheduleType(1, "Breakfast"),
    const ScheduleType(2, "Lunch"), const ScheduleType(3, "Mid Snack"), const ScheduleType(4, "Dinner")];

  getCurrentDate(){
    final now = DateTime.now();
    var date = DateTime(now.year, now.month+1, 0).toString();
    var dateParse = findFirstDateOfTheWeek(now);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    setState(() {
      firstDate = formattedDate.toString();
      vFirstDate = dateParse;
    });
  }

  Future insertSchedule() async{
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/addschedule'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kid_id': kid_id,
        'recipe_id': dding,
        'date': selectedDate,
        'type': ddtype.toString(),
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
      }

      return null;
    }
    else{ throw Exception('Failed to work'); }
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime){
  return dateTime.subtract(Duration(days: dateTime.weekday -1));
  }

  Future<List> getRecipes() async{
    final response = await  http.get(Uri.parse("http://127.0.0.1:8000/api/getrecipes/"+kid_id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      ingData = jsonData["data"];
      ingData.map((i){
        print(i);
      });
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> getScheduleOfWeek() async{
    final response = await  http.get(Uri.parse("http://127.0.0.1:8000/api/getschedules/"+kid_id));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List jsonRec = jsonData["data"];
      scheduleData= jsonData["data"];
      // List<WeekSchedule> ls = WeekSchedule(id: "0", name : "name", type: "type", date: "date", recipe_id: "recipe_id") as List<WeekSchedule>;
      // for(int i = 0; i <= jsonRec.length-1; i++){
      //   print(i);
      //  ls.add(WeekSchedule(id: jsonRec[i]["id"].toString(), name: jsonRec[i]["name"].toString(), type: jsonRec[i]["type"].toString(),
      //      date: jsonRec[i]["date"].toString(), recipe_id: jsonRec[i]["recipe_id"].toString()));
      // }

      // scheduleData = List<WeekSchedule>.from(
      //     jsonData["data"].map((i){
      //       return WeekSchedule.fromJSON(i);
      //     })
      // );
//(id: i.id, name: i.name, type: i.type, date: i.date, recipe_id: i.recipe_id)

//       jsonData["data"].map((i){
//         return scheduleData.add(i);
//       });
//       scheduleData = jsonData["data"];
      return jsonRec;
    }
    else {
      throw Exception('Failed to load data');
    }
  }

  Widget schType(){
        return DropdownButtonFormField(
          hint: Text("Select Schedule Time"),
          isExpanded: true,
          items: types.map((e) {
            return DropdownMenuItem(child: Text(e.name), value: e.id,);
          }).toList(),
            onSaved: (int? value){
            ddtype = value!;
            setState(() {
              ddtype;
            });
    },
    value: ddtype,
            onChanged: (int? value) {
              ddtype = value!;
              setState(() {
                ddtype;
                print(ddtype);
              });
            });
  }

  Widget ingList(){
    List<IngObj> ingList = List<IngObj>.from(
        ingData.map((i){
          return IngObj.fromJSON(i);
        })
    );
    return DropdownButtonFormField(
      hint: Text("Select Recipe"),
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

  void showBottomSheet(int? id) async{
    if (id != null) {
      final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8000/api/getschedulebyid/' + id.toString()));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        List jsonRec = jsonData["data"];
        // _itemQtyController.text=jsonRec[0]["quantity"].toString();
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
                  schType(),
                  SizedBox(height: 10,),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(id == null){
                            insertSchedule();
                          }
                          else{
                            // updatePurchase(dding, _itemQtyController.text, _itemRateController.text);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(id == null ? "Save" : "Update",
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Schedule"), backgroundColor: Colors.cyan),
      body: FutureBuilder(
        builder: (context, snapshot) {
          final weekdays = DateFormat().dateSymbols.WEEKDAYS;
          getScheduleOfWeek();
          // IF IT WORKS IT GOES HERE!
          return ListView.builder(
              itemCount: weekdays.length,
              itemBuilder: (context, index) {
                String rec_name ="";
                if(scheduleData != null){
                  scheduleData.map((e){
                    if(e.date == DateFormat("yyyy-MM-dd").parse(firstDate).toString()){
                      rec_name = e.name;
                    }
                  });
                }
                return Card(margin: EdgeInsets.all(5),
                  child: ListTile(
                    title: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(weekdays[index] + ' (' + DateFormat("dd/MM/yyyy").format(vFirstDate.add(Duration(days: index))).toString() + ')',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    subtitle: Padding(padding: EdgeInsets.symmetric(vertical: 5),
                    // child: Text(DateFormat("yyyy-MM-dd").parse(firstDate).toString(), style: TextStyle(fontSize: 18, color: Colors.black),),),
                    //   child: Text(scheduleData.where((element) => element.date == DateFormat("yyyy-MM-dd").format(vFirstDate.add(Duration(days: index))).toString()).length > 0? scheduleData.where((element) => element.date == DateFormat("yyyy-MM-dd").format(vFirstDate.add(Duration(days: index))).toString()).first.name: '', style: TextStyle(fontSize: 18, color: Colors.black),),),
                    child: Text(rec_name, style: TextStyle(fontSize: 18, color: Colors.black),),),
                    trailing: Container(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: IconButton(onPressed: () {
                            setState(() {
                              selectedDate = DateFormat("yyyy-MM-dd").format(vFirstDate.add(Duration(days: index))).toString();
                              showBottomSheet(null);
                            });
                          }, icon: Icon(Icons.add))),
                          Expanded(child: IconButton(onPressed: () {
                            setState(() {
                            });
                          }, icon: Icon(Icons.edit))),
                          Expanded(child: IconButton(onPressed: () {
                            setState(() {
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
//        future: fetchData(),
      ),
    );
  }
  @override
  void initState() {
    getCurrentDate();
    getRecipes();
    getScheduleOfWeek();
  }
}

abstract class  ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

class ResponseObj{
  int status;
  String message;
  String data;
  ResponseObj(this.status, this.message, this.data);
}

class IngObj{
  String id, name;
  IngObj({required this.id, required this.name});
  factory IngObj.fromJSON(Map<String, dynamic> json){
    return IngObj( id:json["id"].toString(), name:json["name"], );
  }
}

class ScheduleType{
  const ScheduleType(this.id, this.name);
  final String name;
  final int id;
}

class WeekSchedule{
  String id, name, type, date, recipe_id;
  WeekSchedule({required this.id, required this.name, required this.type, required this.date, required this.recipe_id});
  // factory WeekSchedule.fromJSON(Map<String, dynamic> json){
  //   return WeekSchedule( id:json["id"].toString(), name:json["name"], type: json["type"], date: json["date"], recipe_id: json["recipe_id"] );
  // }
}
