import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/zoomable.dart';

class Calendarview extends StatefulWidget {
  String url;
  String title;

  Calendarview(this.url,this.title);

  @override
  _CalendarviewState createState() => _CalendarviewState(this.url,this.title);
}

class _CalendarviewState extends State<Calendarview> {
  String url;
  String title;
  _CalendarviewState(this.url,this.title);
  static const bar_color = const Color(0xFF183967);

  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();

  @override
  Widget build(BuildContext context) {

    String imageURL = getAllDataFromApi.serverURL+"public/calendar/"+url;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("${title}"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ZoomableWidget(
          minScale: 0.3,
          maxScale: 2.0,
          // default factor is 1.0, use 0.0 to disable boundary
          panLimit: 0.8,
          child: Container(
            child: TransitionToImage(
              image: AdvancedNetworkImage(
                imageURL,
                timeoutDuration: Duration(minutes: 1),
                useDiskCache: true,
              ),
              // This is the default placeholder widget at loading status,
              // you can write your own widget with CustomPainter.
              placeholder: CircularProgressIndicator(),
              // This is default duration
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      ),
    );
  }
}
