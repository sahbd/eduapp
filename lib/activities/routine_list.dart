import 'dart:convert';
import 'dart:io';
import 'package:eduapp/activities/routine_view.dart';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Routine extends StatefulWidget {
  @override
  _RoutineState createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  int? user_id = 0;
  List datamyroutine = [];
  static const color = const Color(0xFFF5F5F5);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);


  Future<void> readRoutineFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await getAllDataFromApi.fetchRoutineItem();
    String temp_fileContent =  await getAllDataFromApi.readRoutineFile();
    List temp_data = [];
    temp_data = await json.decode(temp_fileContent);
    String check = await prefs.getString("isParentLoggedIn") ?? "";
    //print("Check:  "+check);
    if (check == null) {
      setState(() {
        user_id = 0;
      });
    }else {
      setState(() {
        user_id = prefs.getInt('user_id');
      });
    }

    if(user_id == 0)
    {
      temp_data.removeWhere((row) => row['user_id'] != 0);
    }
    else
      {
        temp_data.removeWhere((row) => row['user_id'] != 0 && row['user_id'] != user_id);
      }

    String fileContent = json.encode(temp_data);

    //print('File Content: $fileContent');

    setState(() {
      datamyroutine = json.decode(fileContent);
    });
  }

  Future<void> getUpdateRoutine() async {
    if(await getAllDataFromApi.checkConnection())
    {
      String fileName = "myroutine.json";
      String dir = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$dir/$fileName';
      if(await File(savePath).exists())
      {

        String url = "${getAllDataFromApi.serverURL}/json-data?data=mysettings";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final body = response.body;
          final jsonData = json.decode(body);
          String routine = jsonData[0]['notification'];
          String appSettings = await getAllDataFromApi.readSettingsFile();
          List settings = json.decode(appSettings);
          //print("App: "+module);
          //print("Web: "+settings[0][module]);
          if(settings[0]["notification"] != routine)
          {

            await getRoutineData();
          }
        } else {
          Fluttertoast.showToast(msg: "Server Error");
        }
      }
      else
      {
        await getRoutineData();
      }
    }
    else
    {
      Fluttertoast.showToast(msg: "You are in offline mode");
    }

  }

  Future<void> getRoutineData() async{
    showDialog(context: context, builder: (context){
      return const SpinKitCubeGrid(
        color: color,
        size: 100,
      );
    });

    await getAllDataFromApi.forceRoutineUpdate();
    await getAllDataFromApi.forceSettingsUpdate();
    readRoutineFile();

    Navigator.of(context).pop();

  }

  @override
  void initState() {
    super.initState();
    readRoutineFile();
    getUpdateRoutine();

  }

  void resetList() {
    setState(() {
    });
  }



    @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("List of notification"),
      ),
      body: Column(
        children: [
          datamyroutine.isNotEmpty?Expanded(
            child: ListView.builder(
              itemCount: datamyroutine.length,
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(datamyroutine[index]["id"].toString()),
                  margin: const EdgeInsets.all(10),
                  color: color,
                  child: ListTile(

                    title: Text(datamyroutine[index]["title"]),
                    onTap: (){
                      String title = datamyroutine[index]["title"];
                      String photo = datamyroutine[index]["message"];
                      Route route = MaterialPageRoute(builder: (context) => Routineview(photo,title));
                      Navigator.push(context, route);
                    },
                  ),
                );
              },
            ),
          ): Center(child: Text("No notice available right now"))
        ],
      ),
    );
  }
}
