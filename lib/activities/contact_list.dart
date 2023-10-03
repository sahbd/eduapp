import 'dart:io';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

import 'contact_details_view.dart';

class Contactlist extends StatefulWidget {
  String dept;

  Contactlist(this.dept);

  @override
  _ContactlistState createState() => _ContactlistState(this.dept);
}

class _ContactlistState extends State<Contactlist> {
  String dept;

  _ContactlistState(this.dept);
  static const bar_color = const Color(0xFF183967);
  static const color = const Color(0xFFF5F5F5);

  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  late String img;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text("List of Members"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: FutureBuilder(
            future: getAllDataFromApi.getContactList(dept),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      img = "assets/images/avatar.jpg";
                      return snapshot.data[index]['photo'] != null ? Card(
                        margin: const EdgeInsets.all(10),
                        color: color,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AdvancedNetworkImage(
                                      "${getAllDataFromApi.serverURL}/public/contact/${snapshot.data[index]['photo']}",
                                      timeoutDuration: Duration(minutes: 1),
                                      useDiskCache: true,
                                    ),
                                  )),
                            ),
                          ),
                          title: Text(snapshot.data[index]['name']),
                          subtitle: Text(snapshot.data[index]['designation']),
                          onTap: () {
                            int id = snapshot.data[index]['id'];
                            Route route = MaterialPageRoute(
                                builder: (context) => Contactview(id));
                            Navigator.push(context, route);
                          },
                        ),
                      ):
                      Card(
                        margin: const EdgeInsets.all(10),
                        color: color,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(img),
                                  )),
                            ),
                          ),
                          title: Text(snapshot.data[index]['name']),
                          subtitle: Text(snapshot.data[index]['designation']),
                          onTap: () {
                            int id = snapshot.data[index]['id'];
                            Route route = MaterialPageRoute(
                                builder: (context) => Contactview(id));
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