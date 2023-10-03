import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';

import 'department_view.dart';


class Faculty extends StatefulWidget {
  @override
  _FacultyState createState() => _FacultyState();
}

class _FacultyState extends State<Faculty> {
 // DatabaseHelper databaseHelper = DatabaseHelper();
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);
  static const color = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("Faculties"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder(
            future: getAllDataFromApi.getFacultyList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: const EdgeInsets.all(10),
                        color: color,
                        child: ListTile(
                          title: Text(snapshot.data[index]),
                          onTap: () {
                            String faculty = snapshot.data[index];
                            Route route = MaterialPageRoute(
                                builder: (context) => Department(faculty));
                            Navigator.push(context, route);
                          },
                        ),
                      );
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
