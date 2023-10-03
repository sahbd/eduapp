import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';

import 'contact_list.dart';

class Department extends StatefulWidget {
  String dep;

  Department(this.dep);

  @override
  _DepartmentState createState() => _DepartmentState(this.dep);
}

class _DepartmentState extends State<Department> {
  String dep;

  _DepartmentState(this.dep);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);
  static const color = const Color(0xFFF5F5F5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("Departments"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder(
            future: getAllDataFromApi.getDepartmentList(dep),
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
                            String dept = snapshot.data[index];
                            Route route = MaterialPageRoute(
                                builder: (context) => Contactlist(dept));
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
