import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';

class Statics extends StatefulWidget {
  String title;
  String details;
  Statics(this.title, this.details);

  @override
  _StaticsState createState() => _StaticsState(this.title, this.details);
}

class _StaticsState extends State<Statics> {
  String details;
  String title;

  _StaticsState(this.title, this.details);

  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("$title"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text(
            details,
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
