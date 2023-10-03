import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/zoomable.dart';

class Routineview extends StatefulWidget {
  String url;
  String title;
  Routineview(this.url,this.title);

  @override
  _RoutineviewState createState() => _RoutineviewState(this.url,this.title);
}

class _RoutineviewState extends State<Routineview> {
  String url;
  String title;
  _RoutineviewState(this.url,this.title);

  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);
  @override
  Widget build(BuildContext context) {

    String imageURL = getAllDataFromApi.serverURL+"public/routine/"+url;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("${title}"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text(
            url,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
