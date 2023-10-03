import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../getAllDataFromApi.dart';

class NoticeView extends StatefulWidget {
  String date;
  String title;
  String details;

  NoticeView(this.date,this.title,this.details);

  @override
  _NoticeViewState createState() => _NoticeViewState(this.date,this.title,this.details);
}

class _NoticeViewState extends State<NoticeView> {
  List datamynotice = [];
  static const bar_color = const Color(0xFF183967);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  String date;
  String title;
  String details;
  _NoticeViewState(this.date,this.title,this.details);


  Future<void> readNoticeFile() async {
    await getAllDataFromApi.fetchNoticeItem();
    String fileContent =  await getAllDataFromApi.readNoticeFile();

    print('File Content: $fileContent');
    setState(() => datamynotice = json.decode(fileContent));
  }

  @override
  void initState() {
    super.initState();
      readNoticeFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        centerTitle: true,
        title: const Text(
          'View Event Details',
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text("Date: "+date+"\n"+"Headline: "+title+"\n\n"+"Details: "+details,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      )
    );
  }
}
