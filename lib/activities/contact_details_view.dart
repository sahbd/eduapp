import 'dart:async';

import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final startColor = Color(0xFFaa7ce4);
final endColor = Color(0xFF183967);
final titleColor = Color(0xff444444);
final textColor = Color(0xFFa9a9a9);
final shadowColor = Color(0xffe9e9f4);

class Contactview extends StatefulWidget {
  int id;

  Contactview(this.id);

  @override
  _ContactviewState createState() => _ContactviewState(this.id);
}

class _ContactviewState extends State<Contactview> {
  int id;
  _ContactviewState(this.id);
  static const bar_color = const Color(0xFF183967);
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  List dataContact = [];

  late String usercode;
  late String name;
  late String designation;
  late String email;
  late String phone;
  late String mobile;
  late int privacyStatus;
  late String photo;
  bool _loggedIn = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //readContactDetails();
    _getPref().then(updateLogin);
    super.initState();
  }

  Future<bool> _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool outputs = prefs.getBool('AppLogin')??false;

    return outputs;
  }

  void updateLogin(bool value) {
    setState(() {
      this._loggedIn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    int desiredId = id; // Replace with the desired ID
    Future<dynamic> futureItem = getAllDataFromApi.getItemById(desiredId);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                height: 200,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [startColor, endColor])),
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 20),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40, right: 125),
                        child: Text(
                          'Contact Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 90),
                child: FutureBuilder(
                    future: futureItem,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        dynamic item = snapshot.data;

                        name = item['name'];
                        designation = item['designation'];
                        email = item['email'];
                        phone = item['phone'];
                        mobile = item['mobile'];
                        //print(item['privacyStatus']);
                        privacyStatus = item['privacyStatus'];
                        if (item['privacyStatus'] == 0 ||
                            _loggedIn == true) {
                          //privacyStatus = item['privacyStatus'];
                        } else {
                          phone = "Private Number";
                          mobile = "Private Number";
                        }
                        if (item['photo'] == null) {
                          photo = "avatar.jpg";
                        } else {
                          photo = "${item['photo']}";
                        }

                        print(photo);
                        return ListView(
                          children: <Widget>[
                            CardHolder(name, designation, email, phone, mobile,
                                privacyStatus, photo),
                            SizedBox(
                              height: 80,
                            )
                          ],
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
            ],
          )),
    );
  }

}

class CardHolder extends StatelessWidget {
  String name;
  String designation;
  String email;
  String phone;
  String mobile;
  int privacyStatus;
  String photo;

  CardHolder(this.name, this.designation, this.email, this.phone, this.mobile,
      this.privacyStatus, this.photo);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      height: 500,
      width: 400,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: titleColor.withOpacity(.1),
                blurRadius: 20,
                spreadRadius: 10),
          ]),
      child: new CardH(
          name, designation, email, phone, mobile, privacyStatus, photo),
    );
  }
}

class CardH extends StatelessWidget {
  String name;
  String designation;
  String email;
  String phone;
  String mobile;
  int privacyStatus;
  String photo;

  CardH(this.name, this.designation, this.email, this.phone, this.mobile,
      this.privacyStatus, this.photo);

  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const color = const Color(0xFF183967);
  static const color_light = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Container(
          child: Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AdvancedNetworkImage(
                      "${getAllDataFromApi.serverURL}/public/contact/${photo}",
                      timeoutDuration: Duration(minutes: 1),
                      useDiskCache: true,
                    ), fit: BoxFit.fill),
                ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          name,
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              designation,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          padding: EdgeInsets.only(left: 20, right: 20, top: 8),
          width: 320,
          height: 130,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 30,
                    spreadRadius: 5)
              ],
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Phone: $phone"),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Mobile: $mobile"),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Email: $email"),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 300,
              child: Divider(
                height: 1,
                color: titleColor.withOpacity(.3),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Material(
                    color: color_light,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      onTap: () async {
                        //print(phone);
                        String webURL = "tel:${phone}";
                        if (await canLaunchUrl(Uri.parse(webURL))) {
                          await launchUrl(Uri.parse(webURL));
                        } else {
                          throw 'Could not launch $webURL';
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.call,
                          color: color,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Material(
                    color: color_light,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      onTap: () async {
                        String webURL = "sms:${phone}";
                        if (await canLaunchUrl(Uri.parse(webURL))) {
                          await launchUrl(Uri.parse(webURL));
                        } else {
                          throw 'Could not launch $webURL';
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.sms,
                          color: color,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Material(
                    color: color_light,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      onTap: () async {
                        String webURL = "mailto:${email}";
                        if (await canLaunchUrl(Uri.parse(webURL))) {
                          await launchUrl(Uri.parse(webURL));
                        } else {
                          throw 'Could not launch $webURL';
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.email,
                          color: color,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }


}
