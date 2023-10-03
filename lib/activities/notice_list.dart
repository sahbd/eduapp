import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:eduapp/activities/notice_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../getAllDataFromApi.dart';

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  List datamynotice = [];
  static const color = const Color(0xFFF5F5F5);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  List data = [];
  static const bar_color = const Color(0xFF183967);
  Future<void> getUpdateNotice() async {
    if(await getAllDataFromApi.checkConnection())
      {
        String fileName = "mynotice.json";
        String dir = (await getApplicationDocumentsDirectory()).path;
        String savePath = '$dir/$fileName';
        if(await File(savePath).exists())
        {

          String url = "${getAllDataFromApi.serverURL}/json-data?data=mysettings";
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final body = response.body;
            final jsonData = json.decode(body);
            String notice = jsonData[0]['notice'];
            String appSettings = await getAllDataFromApi.readSettingsFile();
            List settings = json.decode(appSettings);
            //print("App: "+module);
            //print("Web: "+settings[0][module]);
            if(settings[0]["notice"] != notice)
            {

              await getNoticeData();
            }
          } else {
            Fluttertoast.showToast(msg: "Server Error");
          }
        }
        else
        {
          await getNoticeData();
        }
      }
    else
      {
        Fluttertoast.showToast(msg: "You are in offline mode");
      }
  }

  Future<void> getNoticeData() async{
    showDialog(context: context, builder: (context){
      return const SpinKitCubeGrid(
        color: color,
        size: 100,
      );
    });

    await getAllDataFromApi.forceNoticeUpdate();
    await getAllDataFromApi.forceSettingsUpdate();
    readNoticeFile();

    Navigator.of(context).pop();
  }


  Future<void> readNoticeFile() async {
    await getAllDataFromApi.fetchNoticeItem();
    String fileContent =  await getAllDataFromApi.readNoticeFile();

    print('File Content: $fileContent');
    setState(() => datamynotice = json.decode(fileContent));
  }

  @override
  void initState() {
    super.initState();
      getUpdateNotice();
      readNoticeFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        centerTitle: true,
        title: const Text(
          'Events',
        ),
      ),
      body:Column(
        children: [
          datamynotice.isNotEmpty?Expanded(
            child: ListView.builder(
              itemCount: datamynotice.length,
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(datamynotice[index]["id"].toString()),
                  margin: const EdgeInsets.all(10),
                  color: color,
                  child: ListTile(
                    leading: Text(datamynotice[index]["noticeDate"]),
                    title: Text(datamynotice[index]["title"]),
                    subtitle: Text(datamynotice[index]["details"]),
                    onTap: (){
                      String date = datamynotice[index]["noticeDate"];
                      String title = datamynotice[index]["title"];
                      String details = datamynotice[index]["details"];
                      Route route = MaterialPageRoute(builder: (context) => NoticeView(date, title, details));
                      Navigator.push(context, route);
                    },
                  ),
                );
              },
            ),
          ): Center(child: Text("No event available right now"))
        ],
      ),
    );
  }
}
