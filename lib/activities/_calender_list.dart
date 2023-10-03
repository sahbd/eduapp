import 'dart:convert';
import 'package:eduapp/home_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:eduapp/activities/calender_view.dart';
import 'package:eduapp/activities/routine_view.dart';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class Calendar_ extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar_> {
  List datamycalendar = [];
  static const color = const Color(0xFFF5F5F5);
  static const bar_color = const Color(0xFF183967);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();

  Future<void> readCalendarFile() async {
    await getAllDataFromApi.fetchNoticeItem();
    String fileContent = await getAllDataFromApi.readCalenderFile();

    //print('File Content: $fileContent');
    setState(() => datamycalendar = json.decode(fileContent));
  }

  Future<void> getUpdateRoutine() async {
    if(await getAllDataFromApi.checkConnection())
    {
      String fileName = "mycalendar.json";
      String dir = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$dir/$fileName';
      if(await File(savePath).exists())
      {

        String url = "${getAllDataFromApi.serverURL}/json-data?data=mysettings";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final body = response.body;
          final jsonData = json.decode(body);
          String calendar = jsonData[0]['calendar'];
          String appSettings = await getAllDataFromApi.readSettingsFile();
          List settings = json.decode(appSettings);
          //print("App: "+module);
          //print("Web: "+settings[0][module]);
          if(settings[0]["calendar"] != calendar)
          {

            await getCalendarData();
          }
        } else {
          Fluttertoast.showToast(msg: "Server Error");
        }
      }
      else
      {
        await getCalendarData();
      }
    }
    else
    {
      Fluttertoast.showToast(msg: "You are in offline mode");
    }
  }

  Future<void> getCalendarData() async{
    showDialog(context: context, builder: (context){
      return const SpinKitCubeGrid(
        color: color,
        size: 100,
      );
    });

    await getAllDataFromApi.forceCalendarUpdate();
    await getAllDataFromApi.forceSettingsUpdate();
    readCalendarFile();

    Navigator.of(context).pop();
  }


  @override
  void initState() {
    super.initState();
    getUpdateRoutine();
    readCalendarFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("List of Calendars"),
      ),
      body: Column(
        children: [
          datamycalendar.isNotEmpty?Expanded(
            child: ListView.builder(
              itemCount: datamycalendar.length,
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(datamycalendar[index]["id"].toString()),
                  margin: const EdgeInsets.all(10),
                  color: color,
                  child: ListTile(

                    title: Text(datamycalendar[index]["title"]),
                    onTap: (){
                      String title = datamycalendar[index]["title"];
                      String photo = datamycalendar[index]["calendarURL"];
                      Route route = MaterialPageRoute(builder: (context) => Calendarview(photo,title));
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
