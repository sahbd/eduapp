import 'dart:async' show Future;
import 'dart:convert';
import 'package:eduapp/activities/external_link_view.dart';
import 'package:eduapp/activities/faculty_view.dart';
import 'package:eduapp/activities/gallery_view.dart';
import 'package:eduapp/activities/static_item_view.dart';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eduapp/notification_services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'activities/calender_list.dart';
import 'activities/calender_view.dart';
import 'activities/contact_details_view.dart';
import 'activities/department_view.dart';
import 'activities/notice_list.dart';
import 'activities/notification_list.dart';
import 'activities/parent_login.dart';
import 'activities/routine_list.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationServices notificationServices = NotificationServices();

  static const color = const Color(0xFF183967);
  static const color_light = const Color(0xFF569AF6);
  bool _checkConnection = true;
  String isLogin = 'false';
  late String app_phone;
  late String app_fb;
  late String app_tw;
  late String app_web;


  late String pref_email;
  late String pref_password;
  late String pref_token;
  String pref_user_type = 'public';
  int pref_user_id = 0;

  void regenerateGrid() {
    setState(() {

    });
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _checkConnection = true;
        //print("Internet: " + _checkConnection.toString());
        //return _checkConnection;
      }
    } on SocketException catch (_) {
      _checkConnection = false;
      //print("Internet: " + _checkConnection.toString());
      //return _checkConnection;
    }
    return _checkConnection;
  }

  List data = [];
  String getFacultyWiseView = "1";
  late String appSettings;
  Future<void> updateApp() async {
    if(await checkConnection()){
      showDialog(context: context, builder: (context){
        return SpinKitCubeGrid(
          color: color,
          size: 100,
        );
      });


      final response = await http
          .get(Uri.parse('${getAllDataFromApi.serverURL}/json-data?data=mymenu'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveFile(body.toString());


        var jsonText = await readFile();
        setState(() => data = json.decode(jsonText));

      }
      else
      {
        Fluttertoast.showToast(msg: "Network Error! Please restart the App");
      }

      Navigator.of(context).pop();
    }
    else
      {
        Fluttertoast.showToast(msg: "Please check your internet connection!");
      }

  }

  //Main Menu ###############################################################

  Future<void> getUpdateMainMenu() async {

    if(await checkConnection())
      {
        String fileName = "mymenu.json";
        String dir = (await getApplicationDocumentsDirectory()).path;
        String savePath = '$dir/$fileName';
        if(await File(savePath).exists())
        {

          String url = "${getAllDataFromApi.serverURL}/json-data?data=mysettings";
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final body = response.body;
            final jsonData = json.decode(body);
            String module = jsonData[0]['module'];
            String contact = jsonData[0]['contact'];
            String social_page = jsonData[0]['social_page'];
            String external = jsonData[0]['external'];
            String static = jsonData[0]['static'];
            String website = jsonData[0]['website'];
            appSettings = await getAllDataFromApi.readSettingsFile();
            List settings = json.decode(appSettings);
            //print("App: "+module);
            //print("Web: "+settings[0][module]);
            if(settings[0]["module"] != module)
              {

                await getMainMenu();
              }
            if(settings[0]["contact"] != contact)
            {

              await getAllDataFromApi.forceContactUpdate();
            }
            if(settings[0]["social_page"] != social_page)
            {

              await getAllDataFromApi.forceSocialPageUpdate();
            }
            if(settings[0]["external"] != external)
            {

              await getAllDataFromApi.forceExternalUpdate();
            }
            if(settings[0]["static"] != static)
            {

              await getAllDataFromApi.forceStaticUpdate();
            }
            if(settings[0]["website"] != website)
            {

              await getAllDataFromApi.forceWebsiteUpdate();
            }
          } else {
            Fluttertoast.showToast(msg: "Server Error");
          }
        }
        else
          {
            await getMainMenu();
          }
      }
    else
      {
        Fluttertoast.showToast(msg: "You are in offline mode");
      }

  }

  Future<void> getMainMenu() async{
    showDialog(context: context, builder: (context){
      return const SpinKitCubeGrid(
        color: color,
        size: 100,
      );
    });

    final response = await http
        .get(Uri.parse('${getAllDataFromApi.serverURL}/json-data?data=mymenu'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final body = response.body;
      //print(body);
      saveFile(body.toString());


      var jsonText = await readFile();
      setState(() => data = json.decode(jsonText));

    }
    await getAllDataFromApi.forceSettingsUpdate();
    Navigator.of(context).pop();
  }
  //End Main Menu
  Future<void> fetchMenuItem() async {
    //print('fetch');
    String fileName = "mymenu.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
      {
        var jsonText = await readFile();
        setState(() => data = json.decode(jsonText));
      }
    else
      {
        if(await checkConnection())
          {
            showDialog(context: context, builder: (context){
              return const SpinKitCubeGrid(
                color: color,
                size: 100,
              );
            });

            final response = await http
                .get(Uri.parse('${getAllDataFromApi.serverURL}/json-data?data=mymenu'));
            if (response.statusCode == 200) {
              // If the server did return a 200 OK response,
              // then parse the JSON.
              final body = response.body;
              print(body);
              saveFile(body.toString());


              var jsonText = await readFile();
              setState(() => data = json.decode(jsonText));

            }

            Navigator.of(context).pop();
          }
        else
          {

          }

      }

  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mymenu.json'; // 3

    return filePath;
  }

  void saveFile(String jsonText) async {
    File file = File(await getFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readFile() async {
    File file = File(await getFilePath()); // 1
    String temp_fileContent = await file.readAsString();
    List temp_data = [];
    temp_data = await json.decode(temp_fileContent);
    if(pref_user_type == 'public')
      {
        String rowIdToRemove = 'parent';
        temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
        rowIdToRemove = 'staff';
        temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
        rowIdToRemove = 'student';
        temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
      }

    if(pref_user_type == 'parent')
    {
      String rowIdToRemove = 'staff';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
      rowIdToRemove = 'student';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
    }

    if(pref_user_type == 'staff')
    {
      String rowIdToRemove = 'parent';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
      rowIdToRemove = 'student';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
    }

    if(pref_user_type == 'student')
    {
      String rowIdToRemove = 'parent';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
      rowIdToRemove = 'staff';
      temp_data.removeWhere((row) => row['user_type'] == rowIdToRemove);
    }


    //print("got it");
    String fileContent = json.encode(temp_data);
    print('Read File Content: $fileContent');
    return fileContent;
  }

  Future<void> firstTime() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      // Code to execute only the first time the app is launched
      print('First time app launch');
      // ... Add your code here ...
      getAllDataFromApi.fetchSocialPageItem();
      getAllDataFromApi.fetchNoticeItem();
      getAllDataFromApi.fetchNotificationItem();
      getAllDataFromApi.fetchCalenderItem();
      getAllDataFromApi.fetchContactItem();
      getAllDataFromApi.fetchStaticItem();
      getAllDataFromApi.fetchRoutineItem();
      getAllDataFromApi.fetchSettingsItem();
      getAllDataFromApi.fetchWebsiteItem();
      getAllDataFromApi.fetchExternalItem();

      // Save the flag to indicate that the app has been launched before
      await prefs.setBool('isFirstTime', false);
    }

  }


  Future<void> getSharedPrefsParentLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? isLogin = prefs.getString("isParentLoggedIn");
    var jsonText = await readFile();

    String check = await prefs.getString("isParentLoggedIn") ?? "";
    if (check == null) {
      setState(() {
        isLogin = 'false';
        data = json.decode(jsonText);
      });
    } else {

      setState(() {
        data = json.decode(jsonText);
        isLogin = prefs.getString("isParentLoggedIn")!;
        pref_user_type = prefs.getString('user_type')!;
        pref_user_id = prefs.getInt('user_id')!;
        pref_email = prefs.getString('pref_email')!;
        pref_password = prefs.getString('pref_password')!;
        pref_token = prefs.getString('pref_token')!;
      });
    }
  }

  Future<void> getSharedPrefsParentLogout() async {
    var jsonText = await readFile();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('isParentLoggedIn', 'false');
    await prefs.setString('user_type', 'public');
    await prefs.setInt('user_id', 0);
    await prefs.setString('pref_email', '');
    await prefs.setString('pref_password', '');
    await prefs.setString('pref_token', '');
    setState(() {
      data = json.decode(jsonText);
      isLogin = 'false';
      pref_user_type = 'public';
    });
  }

  int _selectedIndex = 2;

  Future<void> _onItemTapped(int index) async {

    app_phone = await getAllDataFromApi.getAppPhone("5");

    app_fb = await getAllDataFromApi.getAppPhone("1");

    app_tw = await getAllDataFromApi.getAppPhone("2");
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:

        if (await canLaunchUrl(Uri.parse('tel:'+app_phone))) {
          await launchUrl(Uri.parse('tel:'+app_phone));
        } else {
          throw 'Could not launch $app_phone';
        }
        break;
      case 1:

        List websiteList = [];
        String fileContent =  await getAllDataFromApi.readWebsiteFile();
        websiteList = json.decode(fileContent);
        String webURL = "https://"+websiteList[0]["webURL"];
        //Fluttertoast.showToast(msg: webURL);

        if (await canLaunchUrl(Uri.parse(webURL))) {
          await launchUrl(Uri.parse(webURL));
        } else {
          throw 'Could not launch $webURL';
        }

        break;
      case 2:

        Route route = MaterialPageRoute(builder: (context) => Calendar());
        Navigator.push(context, route);



        break;
      case 3:

        if (await canLaunchUrl(Uri.parse('https://'+app_fb))) {
          await launchUrl(Uri.parse('https://'+app_fb));
        } else {
          throw 'Could not launch $app_fb';
        }

        break;
      case 4:

        if (await canLaunchUrl(Uri.parse('https://'+app_tw))) {
          await launchUrl(Uri.parse('https://'+app_tw));
        } else {
          throw 'Could not launch $app_tw';
        }

        break;
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();

    notificationServices.firebaseInit(context);
    //notificationServices.isTokenRefresh();
    notificationServices.subscribe();
    //pushScreenNavigator();
    //notificationServices.initLocalNotifications(context, message);
    //loadJsonData();
    firstTime();
    fetchMenuItem();
    getSharedPrefsParentLogin();
    getUpdateMainMenu();

  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        centerTitle: true,
        title: Text("${getAllDataFromApi.appName}"),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: FutureBuilder(
            future: getAllDataFromApi.getSocialPageList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {

              return ListView.builder(
                itemCount: (snapshot.data?.length ?? 0) + 2,
                itemBuilder: (context, index) {

                  if (index == 0) {
                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              color_light,
                              Colors.white,
                            ],
                          )
                      ),
                      accountName: Text(
                        "INFOSCHOOL",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.black),
                      ),
                      accountEmail: Text("admin@infoschool.ca",
                      style: TextStyle(color: Colors.black),),
                      currentAccountPicture: Image(
                        image: AssetImage("assets/images/logo.png"),
                      ),
                    );
                  }
                  if (index == 1) {
                    if(isLogin == 'false')
                      {
                        return ListTile(
                          iconColor: color,
                          leading: Icon(Icons.people),
                          title: const Text('Login'),
                          onTap: () async {
                            Route route = MaterialPageRoute(builder: (context) => LoginScreen());
                            Navigator.push(context, route).then((value){
                              setState(() {
                                getSharedPrefsParentLogin();
                                fetchMenuItem();
                              });
                            });

                          },
                        );
                      }
                    else
                      {
                        return ListTile(
                          iconColor: color,
                          leading: Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () async {
                            String url = "${getAllDataFromApi.serverURL}/deviceLogout?email=${pref_email}&password=${pref_password}&token=${pref_token}";
                            await http.get(Uri.parse(url));

                            await getSharedPrefsParentLogout();
                            fetchMenuItem();
                          },
                        );
                      }

                  }

                  return DynamicListTile(
                    type: snapshot.data[index-2]['type'],
                    url: snapshot.data[index-2]['networkURL'],
                  );

                },
              );
            },
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchAllData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
        } else {}
        return GridView.builder(

        itemCount: data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          String name = data[index]['title'].toString();
          var email = data[index]['title'];
          //print(getFacultyWiseView);
          print(pref_user_type);
              return MyMenu(
                  id: data[index]['id'],
                  title: data[index]['title'],
                  icon: data[index]['icon'],
                  warn: color,
                  type: data[index]['moduleType'],
                  checkFaluty: int.parse(getFacultyWiseView),
                  calendar: 1,
                  routine: 1,
                  url: data[index]['title'],
                  openIn: 1,
                  staticID: 1
              );

        },
      );
        },
      ),
      bottomNavigationBar: FutureBuilder(
        future: getAllDataFromApi.readSocialPageFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.phone),
                label: 'Phone',
                backgroundColor: Color(0xFF183967),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesome.globe),
                label: 'Website',
                backgroundColor: Color(0xFF183967),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Calendar',
                backgroundColor: Color(0xFF183967),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesome.facebook),
                label: 'Facebook',
                backgroundColor: Color(0xFF183967),
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesome.twitter),
                label: 'Twitter',
                backgroundColor: Color(0xFF183967),
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          );
        },
      ),

    );
  }

  Future<void> fetchAllData() async{
    //print("started");
    getFacultyWiseView = await getAllDataFromApi.getFacultyWiseView();
    //print("ended");
    //regenerateGrid();
  }

  _showLogin(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Password'),
            content: TextField(
              controller: customController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Login"),
                onPressed: () async {
                  String password = await getAllDataFromApi.getAppPassword();
                  if (customController.text == password) {
                    await _savePref();
                    Fluttertoast.showToast(msg: "Logged in");
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(msg: "Password do not match!!!");
                  }
                },
              )
            ],
          );
        });
  }

  Future<void> _savePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('AppLogin', true);
  }

}


class DynamicListTile extends StatelessWidget {
  DynamicListTile({required this.type, required this.url});

  final String type;
  final String url;
  late String menuIcon;
  late String title;
  static const bar_color = const Color(0xFF183967);
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case '1':
        menuIcon = "facebook";
        title = 'Facebook';

        break;
      case '2':
        menuIcon = "twitter";
        title = 'Twitter';
        break;
      case '3':
        menuIcon = "linkedin";
        title = 'Linkedin';
        break;
      case '4':
        menuIcon = "youtube";
        title = 'Youtube';
        break;
      case '5':
        menuIcon = "phone";
        title = 'Phone';
        break;
    }
    // TODO: implement build
    return ListTile(
      iconColor: bar_color,
      onTap: () async {
        String webURL = "";
        if(type == "5")
          {
            webURL = "tel:"+url;
          }
        else
          {
            webURL = "https://"+url;
          }

        //Fluttertoast.showToast(msg: webURL);

        if (await canLaunchUrl(Uri.parse(webURL))) {
        await launchUrl(Uri.parse(webURL));
        } else {
        throw 'Could not launch $webURL';
        }
      },
      leading: Icon(
        iconMapping[menuIcon],
      ),
      title: Text(title),
    );
  }
}


//Main Menu Class
class MyMenu extends StatelessWidget {
  MyMenu(
      {required this.id,
        required this.title,
        required this.icon,
        required this.warn,
        required this.type,
        required this.checkFaluty,
        required this.calendar,
        required this.routine,
        required this.url,
        required this.openIn,
        required this.staticID});
  final int id;
  final String title;
  final String type;
  final String icon;
  final Color warn;
  final int checkFaluty;
  final int calendar;
  final int routine;
  final String url;
  final int openIn;
  final int staticID;
  late final String menuIcon;
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  @override
  Widget build(BuildContext context) {
    switch (icon) {
      case '1.png':
        menuIcon = "users";
        break;
      case '2.png':
        menuIcon = "bell";
        break;
      case '3.png':
        menuIcon = "list-alt";
        break;
      case '4.png':
        menuIcon = "calendar";
        break;
      case '5.png':
        menuIcon = "chrome";
        break;
      case '6.png':
        menuIcon = "film";
        break;
      default:
        menuIcon = icon;
        break;
    }
    // TODO: implement build
    return Card(
        margin: EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            switch (type) {
              case "Contact":
                if (checkFaluty == 1) {
                  Route route =
                  MaterialPageRoute(builder: (context) => Faculty());
                  Navigator.push(context, route);
                } else {
                  String dept = "_all";
                  Route route =
                  MaterialPageRoute(builder: (context) => Department(dept));
                  Navigator.push(context, route);
                }
                break;
              case "Notice":
                Route route = MaterialPageRoute(builder: (context) => Notice());
                Navigator.push(context, route);
                break;

              case "Calendar":
                Route route = MaterialPageRoute(builder: (context) => Calendar());
                Navigator.push(context, route);
                break;
              case "Routine":
                Route route = MaterialPageRoute(builder: (context) => Routine());
                Navigator.push(context, route);
                break;
              case "Website":
                List websiteList = [];
                String fileContent =  await getAllDataFromApi.readWebsiteFile();
                websiteList = json.decode(fileContent);
                String webURL = "https://"+websiteList[0]["webURL"];
                //Fluttertoast.showToast(msg: webURL);

                  if (await canLaunchUrl(Uri.parse(webURL))) {
                    await launchUrl(Uri.parse(webURL));
                  } else {
                    throw 'Could not launch $webURL';
                  }

                break;
              case "Gallery":
                Route route = MaterialPageRoute(builder: (context) => Gallery());
                Navigator.push(context, route);
                break;
              case "Static":
                String staticTitle = "";
                String staticDetails = "";
                List staticList = [];
                String fileContent =  await getAllDataFromApi.readStaticFile();
                staticList = json.decode(fileContent);
                //String webURL = "https://"+staticList[0]["webURL"];
                staticTitle = staticList[id-1]['title'];
                staticDetails = staticList[id-1]['details'];
                Route route = MaterialPageRoute(builder: (context) => Statics(staticTitle, staticDetails));
                Navigator.push(context, route);

                break;
              default:
                List externalList = [];
                String fileContent =  await getAllDataFromApi.readExternalFile();
                externalList = json.decode(fileContent);
                //String webURL = "https://"+staticList[0]["webURL"];
                String webURL = "https://"+externalList[id-1]['externalURL'];
                if(externalList[id-1]['openin'] == 0)
                  {
                    Route route = MaterialPageRoute(builder: (context) => External(externalList[id-1]['title'], webURL));
                    Navigator.push(context, route);
                  }
                else
                  {
                    if (await canLaunchUrl(Uri.parse(webURL))) {
                      await launchUrl(Uri.parse(webURL));
                    } else {
                      throw "Could not launch $webURL";
                    }
                  }


            }
          },
          splashColor: Color(0xFF183967),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  iconMapping[menuIcon],
                  color: warn,
                  size: 55.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    title,
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}


Map<String, IconData> iconMapping = {
  'address-book-o': FontAwesome.address_book_o,
  'address-book': FontAwesome.address_book,
  'address-card-o': FontAwesome.address_card_o,
  'address-card': FontAwesome.address_card,
  'adjust': FontAwesome.adjust,
  'adn': FontAwesome.adn,
  'align-center': FontAwesome.align_center,
  'align-justify': FontAwesome.align_justify,
  'align-left': FontAwesome.align_left,
  'align-right': FontAwesome.align_right,
  'amazon': FontAwesome.amazon,
  'ambulance': FontAwesome.ambulance,
  'american-sign-language-interpreting':
  FontAwesome.american_sign_language_interpreting,
  'anchor': FontAwesome.anchor,
  'android': FontAwesome.android,
  'angellist': FontAwesome.angellist,
  'angle-double-down': FontAwesome.angle_double_down,
  'angle-double-left': FontAwesome.angle_double_left,
  'angle-double-right': FontAwesome.angle_double_right,
  'angle-double-up': FontAwesome.angle_double_up,
  'angle-down': FontAwesome.angle_down,
  'angle-left': FontAwesome.angle_left,
  'angle-right': FontAwesome.angle_right,
  'angle-up': FontAwesome.angle_up,
  'apple': FontAwesome.apple,
  'archive': FontAwesome.archive,
  'area-chart': FontAwesome.area_chart,
  'arrow-circle-down': FontAwesome.arrow_circle_down,
  'arrow-circle-left': FontAwesome.arrow_circle_left,
  'arrow-circle-o-down': FontAwesome.arrow_circle_o_down,
  'arrow-circle-o-left': FontAwesome.arrow_circle_o_left,
  'arrow-circle-o-right': FontAwesome.arrow_circle_o_right,
  'arrow-circle-o-up': FontAwesome.arrow_circle_o_up,
  'arrow-circle-right': FontAwesome.arrow_circle_right,
  'arrow-circle-up': FontAwesome.arrow_circle_up,
  'arrow-down': FontAwesome.arrow_down,
  'arrow-left': FontAwesome.arrow_left,
  'arrow-right': FontAwesome.arrow_right,
  'arrow-up': FontAwesome.arrow_up,
  'arrows-alt': FontAwesome.arrows_alt,
  'arrows-h': FontAwesome.arrows_h,
  'arrows-v': FontAwesome.arrows_v,
  'arrows': FontAwesome.arrows,
  'asl-interpreting': FontAwesome.asl_interpreting,
  'assistive-listening-systems': FontAwesome.assistive_listening_systems,
  'asterisk': FontAwesome.asterisk,
  'at': FontAwesome.at,
  'audio-description': FontAwesome.audio_description,
  'automobile': FontAwesome.automobile,
  'backward': FontAwesome.backward,
  'balance-scale': FontAwesome.balance_scale,
  'ban': FontAwesome.ban,
  'bandcamp': FontAwesome.bandcamp,
  'bank': FontAwesome.bank,
  'bar-chart-o': FontAwesome.bar_chart_o,
  'bar-chart': FontAwesome.bar_chart,
  'barcode': FontAwesome.barcode,
  'bars': FontAwesome.bars,
  'bath': FontAwesome.bath,
  'bathtub': FontAwesome.bathtub,
  'battery-0': FontAwesome.battery_0,
  'battery-1': FontAwesome.battery_1,
  'battery-2': FontAwesome.battery_2,
  'battery-3': FontAwesome.battery_3,
  'battery-4': FontAwesome.battery_4,
  'battery-empty': FontAwesome.battery_empty,
  'battery-full': FontAwesome.battery_full,
  'battery-half': FontAwesome.battery_half,
  'battery-quarter': FontAwesome.battery_quarter,
  'battery-three-quarters': FontAwesome.battery_three_quarters,
  'battery': FontAwesome.battery,
  'bed': FontAwesome.bed,
  'beer': FontAwesome.beer,
  'behance-square': FontAwesome.behance_square,
  'behance': FontAwesome.behance,
  'bell-o': FontAwesome.bell_o,
  'bell-slash-o': FontAwesome.bell_slash_o,
  'bell-slash': FontAwesome.bell_slash,
  'bell': FontAwesome.bell,
  'bicycle': FontAwesome.bicycle,
  'binoculars': FontAwesome.binoculars,
  'birthday-cake': FontAwesome.birthday_cake,
  'bitbucket-square': FontAwesome.bitbucket_square,
  'bitbucket': FontAwesome.bitbucket,
  'bitcoin': FontAwesome.bitcoin,
  'black-tie': FontAwesome.black_tie,
  'blind': FontAwesome.blind,
  'bluetooth-b': FontAwesome.bluetooth_b,
  'bluetooth': FontAwesome.bluetooth,
  'bold': FontAwesome.bold,
  'bolt': FontAwesome.bolt,
  'bomb': FontAwesome.bomb,
  'book': FontAwesome.book,
  'bookmark-o': FontAwesome.bookmark_o,
  'bookmark': FontAwesome.bookmark,
  'braille': FontAwesome.braille,
  'briefcase': FontAwesome.briefcase,
  'btc': FontAwesome.btc,
  'bug': FontAwesome.bug,
  'building-o': FontAwesome.building_o,
  'building': FontAwesome.building,
  'bullhorn': FontAwesome.bullhorn,
  'bullseye': FontAwesome.bullseye,
  'bus': FontAwesome.bus,
  'buysellads': FontAwesome.buysellads,
  'cab': FontAwesome.cab,
  'calculator': FontAwesome.calculator,
  'calendar-check-o': FontAwesome.calendar_check_o,
  'calendar-minus-o': FontAwesome.calendar_minus_o,
  'calendar-o': FontAwesome.calendar_o,
  'calendar-plus-o': FontAwesome.calendar_plus_o,
  'calendar-times-o': FontAwesome.calendar_times_o,
  'calendar': FontAwesome.calendar,
  'camera-retro': FontAwesome.camera_retro,
  'camera': FontAwesome.camera,
  'car': FontAwesome.car,
  'caret-down': FontAwesome.caret_down,
  'caret-left': FontAwesome.caret_left,
  'caret-right': FontAwesome.caret_right,
  'caret-square-o-down': FontAwesome.caret_square_o_down,
  'caret-square-o-left': FontAwesome.caret_square_o_left,
  'caret-square-o-right': FontAwesome.caret_square_o_right,
  'caret-square-o-up': FontAwesome.caret_square_o_up,
  'caret-up': FontAwesome.caret_up,
  'cart-arrow-down': FontAwesome.cart_arrow_down,
  'cart-plus': FontAwesome.cart_plus,
  'cc-amex': FontAwesome.cc_amex,
  'cc-diners-club': FontAwesome.cc_diners_club,
  'cc-discover': FontAwesome.cc_discover,
  'cc-jcb': FontAwesome.cc_jcb,
  'cc-mastercard': FontAwesome.cc_mastercard,
  'cc-paypal': FontAwesome.cc_paypal,
  'cc-stripe': FontAwesome.cc_stripe,
  'cc-visa': FontAwesome.cc_visa,
  'cc': FontAwesome.cc,
  'certificate': FontAwesome.certificate,
  'chain-broken': FontAwesome.chain_broken,
  'chain': FontAwesome.chain,
  'check-circle-o': FontAwesome.check_circle_o,
  'check-circle': FontAwesome.check_circle,
  'check-square-o': FontAwesome.check_square_o,
  'check-square': FontAwesome.check_square,
  'check': FontAwesome.check,
  'chevron-circle-down': FontAwesome.chevron_circle_down,
  'chevron-circle-left': FontAwesome.chevron_circle_left,
  'chevron-circle-right': FontAwesome.chevron_circle_right,
  'chevron-circle-up': FontAwesome.chevron_circle_up,
  'chevron-down': FontAwesome.chevron_down,
  'chevron-left': FontAwesome.chevron_left,
  'chevron-right': FontAwesome.chevron_right,
  'chevron-up': FontAwesome.chevron_up,
  'child': FontAwesome.child,
  'chrome': FontAwesome.chrome,
  'circle-o-notch': FontAwesome.circle_o_notch,
  'circle-o': FontAwesome.circle_o,
  'circle-thin': FontAwesome.circle_thin,
  'circle': FontAwesome.circle,
  'clipboard': FontAwesome.clipboard,
  'clock-o': FontAwesome.clock_o,
  'clone': FontAwesome.clone,
  'close': FontAwesome.close,
  'cloud-download': FontAwesome.cloud_download,
  'cloud-upload': FontAwesome.cloud_upload,
  'cloud': FontAwesome.cloud,
  'cny': FontAwesome.cny,
  'code-fork': FontAwesome.code_fork,
  'code': FontAwesome.code,
  'codepen': FontAwesome.codepen,
  'codiepie': FontAwesome.codiepie,
  'coffee': FontAwesome.coffee,
  'cog': FontAwesome.cog,
  'cogs': FontAwesome.cogs,
  'columns': FontAwesome.columns,
  'comment-o': FontAwesome.comment_o,
  'comment': FontAwesome.comment,
  'commenting-o': FontAwesome.commenting_o,
  'commenting': FontAwesome.commenting,
  'comments-o': FontAwesome.comments_o,
  'comments': FontAwesome.comments,
  'compass': FontAwesome.compass,
  'compress': FontAwesome.compress,
  'connectdevelop': FontAwesome.connectdevelop,
  'contao': FontAwesome.contao,
  'copy': FontAwesome.copy,
  'copyright': FontAwesome.copyright,
  'creative-commons': FontAwesome.creative_commons,
  'credit-card-alt': FontAwesome.credit_card_alt,
  'credit-card': FontAwesome.credit_card,
  'crop': FontAwesome.crop,
  'crosshairs': FontAwesome.crosshairs,
  'css3': FontAwesome.css3,
  'cube': FontAwesome.cube,
  'cubes': FontAwesome.cubes,
  'cut': FontAwesome.cut,
  'cutlery': FontAwesome.cutlery,
  'dashboard': FontAwesome.dashboard,
  'dashcube': FontAwesome.dashcube,
  'database': FontAwesome.database,
  'deaf': FontAwesome.deaf,
  'deafness': FontAwesome.deafness,
  'dedent': FontAwesome.dedent,
  'delicious': FontAwesome.delicious,
  'desktop': FontAwesome.desktop,
  'deviantart': FontAwesome.deviantart,
  'diamond': FontAwesome.diamond,
  'digg': FontAwesome.digg,
  'dollar': FontAwesome.dollar,
  'dot-circle-o': FontAwesome.dot_circle_o,
  'download': FontAwesome.download,
  'dribbble': FontAwesome.dribbble,
  'drivers-license-o': FontAwesome.drivers_license_o,
  'drivers-license': FontAwesome.drivers_license,
  'dropbox': FontAwesome.dropbox,
  'drupal': FontAwesome.drupal,
  'edge': FontAwesome.edge,
  'edit': FontAwesome.edit,
  'eercast': FontAwesome.eercast,
  'eject': FontAwesome.eject,
  'ellipsis-h': FontAwesome.ellipsis_h,
  'ellipsis-v': FontAwesome.ellipsis_v,
  'empire': FontAwesome.empire,
  'envelope-o': FontAwesome.envelope_o,
  'envelope-open-o': FontAwesome.envelope_open_o,
  'envelope-open': FontAwesome.envelope_open,
  'envelope-square': FontAwesome.envelope_square,
  'envelope': FontAwesome.envelope,
  'envira': FontAwesome.envira,
  'eraser': FontAwesome.eraser,
  'etsy': FontAwesome.etsy,
  'eur': FontAwesome.eur,
  'euro': FontAwesome.euro,
  'exchange': FontAwesome.exchange,
  'exclamation-circle': FontAwesome.exclamation_circle,
  'exclamation-triangle': FontAwesome.exclamation_triangle,
  'exclamation': FontAwesome.exclamation,
  'expand': FontAwesome.expand,
  'expeditedssl': FontAwesome.expeditedssl,
  'external-link-square': FontAwesome.external_link_square,
  'external-link': FontAwesome.external_link,
  'eye-slash': FontAwesome.eye_slash,
  'eye': FontAwesome.eye,
  'eyedropper': FontAwesome.eyedropper,
  'fa': FontAwesome.fa,
  'facebook-f': FontAwesome.facebook_f,
  'facebook-official': FontAwesome.facebook_official,
  'facebook-square': FontAwesome.facebook_square,
  'facebook': FontAwesome.facebook,
  'fast-backward': FontAwesome.fast_backward,
  'fast-forward': FontAwesome.fast_forward,
  'fax': FontAwesome.fax,
  'feed': FontAwesome.feed,
  'female': FontAwesome.female,
  'fighter-jet': FontAwesome.fighter_jet,
  'file-archive-o': FontAwesome.file_archive_o,
  'file-audio-o': FontAwesome.file_audio_o,
  'file-code-o': FontAwesome.file_code_o,
  'file-excel-o': FontAwesome.file_excel_o,
  'file-image-o': FontAwesome.file_image_o,
  'file-movie-o': FontAwesome.file_movie_o,
  'file-o': FontAwesome.file_o,
  'file-pdf-o': FontAwesome.file_pdf_o,
  'file-photo-o': FontAwesome.file_photo_o,
  'file-picture-o': FontAwesome.file_picture_o,
  'file-powerpoint-o': FontAwesome.file_powerpoint_o,
  'file-sound-o': FontAwesome.file_sound_o,
  'file-text-o': FontAwesome.file_text_o,
  'file-text': FontAwesome.file_text,
  'file-video-o': FontAwesome.file_video_o,
  'file-word-o': FontAwesome.file_word_o,
  'file-zip-o': FontAwesome.file_zip_o,
  'file': FontAwesome.file,
  'files-o': FontAwesome.files_o,
  'film': FontAwesome.film,
  'filter': FontAwesome.filter,
  'fire-extinguisher': FontAwesome.fire_extinguisher,
  'fire': FontAwesome.fire,
  'firefox': FontAwesome.firefox,
  'first-order': FontAwesome.first_order,
  'flag-checkered': FontAwesome.flag_checkered,
  'flag-o': FontAwesome.flag_o,
  'flag': FontAwesome.flag,
  'flash': FontAwesome.flash,
  'flask': FontAwesome.flask,
  'flickr': FontAwesome.flickr,
  'floppy-o': FontAwesome.floppy_o,
  'folder-o': FontAwesome.folder_o,
  'folder-open-o': FontAwesome.folder_open_o,
  'folder-open': FontAwesome.folder_open,
  'folder': FontAwesome.folder,
  'font-awesome': FontAwesome.font_awesome,
  'font': FontAwesome.font,
  'fonticons': FontAwesome.fonticons,
  'fort-awesome': FontAwesome.fort_awesome,
  'forumbee': FontAwesome.forumbee,
  'forward': FontAwesome.forward,
  'foursquare': FontAwesome.foursquare,
  'free-code-camp': FontAwesome.free_code_camp,
  'frown-o': FontAwesome.frown_o,
  'futbol-o': FontAwesome.futbol_o,
  'gamepad': FontAwesome.gamepad,
  'gavel': FontAwesome.gavel,
  'gbp': FontAwesome.gbp,
  'ge': FontAwesome.ge,
  'gear': FontAwesome.gear,
  'gears': FontAwesome.gears,
  'genderless': FontAwesome.genderless,
  'get-pocket': FontAwesome.get_pocket,
  'gg-circle': FontAwesome.gg_circle,
  'gg': FontAwesome.gg,
  'gift': FontAwesome.gift,
  'git-square': FontAwesome.git_square,
  'git': FontAwesome.git,
  'github-alt': FontAwesome.github_alt,
  'github-square': FontAwesome.github_square,
  'github': FontAwesome.github,
  'gitlab': FontAwesome.gitlab,
  'gittip': FontAwesome.gittip,
  'glass': FontAwesome.glass,
  'glide-g': FontAwesome.glide_g,
  'glide': FontAwesome.glide,
  'globe': FontAwesome.globe,
  'google-plus-circle': FontAwesome.google_plus_circle,
  'google-plus-official': FontAwesome.google_plus_official,
  'google-plus-square': FontAwesome.google_plus_square,
  'google-plus': FontAwesome.google_plus,
  'google-wallet': FontAwesome.google_wallet,
  'google': FontAwesome.google,
  'graduation-cap': FontAwesome.graduation_cap,
  'gratipay': FontAwesome.gratipay,
  'grav': FontAwesome.grav,
  'group': FontAwesome.group,
  'h-square': FontAwesome.h_square,
  'hacker-news': FontAwesome.hacker_news,
  'hand-grab-o': FontAwesome.hand_grab_o,
  'hand-lizard-o': FontAwesome.hand_lizard_o,
  'hand-o-down': FontAwesome.hand_o_down,
  'hand-o-left': FontAwesome.hand_o_left,
  'hand-o-right': FontAwesome.hand_o_right,
  'hand-o-up': FontAwesome.hand_o_up,
  'hand-paper-o': FontAwesome.hand_paper_o,
  'hand-peace-o': FontAwesome.hand_peace_o,
  'hand-pointer-o': FontAwesome.hand_pointer_o,
  'hand-rock-o': FontAwesome.hand_rock_o,
  'hand-scissors-o': FontAwesome.hand_scissors_o,
  'hand-spock-o': FontAwesome.hand_spock_o,
  'hand-stop-o': FontAwesome.hand_stop_o,
  'handshake-o': FontAwesome.handshake_o,
  'hard-of-hearing': FontAwesome.hard_of_hearing,
  'hashtag': FontAwesome.hashtag,
  'hdd-o': FontAwesome.hdd_o,
  'header': FontAwesome.header,
  'headphones': FontAwesome.headphones,
  'heart-o': FontAwesome.heart_o,
  'heart': FontAwesome.heart,
  'heartbeat': FontAwesome.heartbeat,
  'history': FontAwesome.history,
  'home': FontAwesome.home,
  'hospital-o': FontAwesome.hospital_o,
  'hotel': FontAwesome.hotel,
  'hourglass-1': FontAwesome.hourglass_1,
  'hourglass-2': FontAwesome.hourglass_2,
  'hourglass-3': FontAwesome.hourglass_3,
  'hourglass-end': FontAwesome.hourglass_end,
  'hourglass-half': FontAwesome.hourglass_half,
  'hourglass-o': FontAwesome.hourglass_o,
  'hourglass-start': FontAwesome.hourglass_start,
  'hourglass': FontAwesome.hourglass,
  'houzz': FontAwesome.houzz,
  'html5': FontAwesome.html5,
  'i-cursor': FontAwesome.i_cursor,
  'id-badge': FontAwesome.id_badge,
  'id-card-o': FontAwesome.id_card_o,
  'id-card': FontAwesome.id_card,
  'ils': FontAwesome.ils,
  'image': FontAwesome.image,
  'imdb': FontAwesome.imdb,
  'inbox': FontAwesome.inbox,
  'indent': FontAwesome.indent,
  'industry': FontAwesome.industry,
  'info-circle': FontAwesome.info_circle,
  'info': FontAwesome.info,
  'inr': FontAwesome.inr,
  'instagram': FontAwesome.instagram,
  'institution': FontAwesome.institution,
  'internet-explorer': FontAwesome.internet_explorer,
  'intersex': FontAwesome.intersex,
  'ioxhost': FontAwesome.ioxhost,
  'italic': FontAwesome.italic,
  'joomla': FontAwesome.joomla,
  'jpy': FontAwesome.jpy,
  'jsfiddle': FontAwesome.jsfiddle,
  'key': FontAwesome.key,
  'keyboard-o': FontAwesome.keyboard_o,
  'krw': FontAwesome.krw,
  'language': FontAwesome.language,
  'laptop': FontAwesome.laptop,
  'lastfm-square': FontAwesome.lastfm_square,
  'lastfm': FontAwesome.lastfm,
  'leaf': FontAwesome.leaf,
  'leanpub': FontAwesome.leanpub,
  'legal': FontAwesome.legal,
  'lemon-o': FontAwesome.lemon_o,
  'level-down': FontAwesome.level_down,
  'level-up': FontAwesome.level_up,
  'life-bouy': FontAwesome.life_bouy,
  'life-buoy': FontAwesome.life_buoy,
  'life-ring': FontAwesome.life_ring,
  'life-saver': FontAwesome.life_saver,
  'lightbulb-o': FontAwesome.lightbulb_o,
  'line-chart': FontAwesome.line_chart,
  'link': FontAwesome.link,
  'linkedin-square': FontAwesome.linkedin_square,
  'linkedin': FontAwesome.linkedin,
  'linode': FontAwesome.linode,
  'linux': FontAwesome.linux,
  'list-alt': FontAwesome.list_alt,
  'list-ol': FontAwesome.list_ol,
  'list-ul': FontAwesome.list_ul,
  'list': FontAwesome.list,
  'location-arrow': FontAwesome.location_arrow,
  'lock': FontAwesome.lock,
  'long-arrow-down': FontAwesome.long_arrow_down,
  'long-arrow-left': FontAwesome.long_arrow_left,
  'long-arrow-right': FontAwesome.long_arrow_right,
  'long-arrow-up': FontAwesome.long_arrow_up,
  'low-vision': FontAwesome.low_vision,
  'magic': FontAwesome.magic,
  'magnet': FontAwesome.magnet,
  'mail-forward': FontAwesome.mail_forward,
  'mail-reply-all': FontAwesome.mail_reply_all,
  'mail-reply': FontAwesome.mail_reply,
  'male': FontAwesome.male,
  'map-marker': FontAwesome.map_marker,
  'map-o': FontAwesome.map_o,
  'map-pin': FontAwesome.map_pin,
  'map-signs': FontAwesome.map_signs,
  'map': FontAwesome.map,
  'mars-double': FontAwesome.mars_double,
  'mars-stroke-h': FontAwesome.mars_stroke_h,
  'mars-stroke-v': FontAwesome.mars_stroke_v,
  'mars-stroke': FontAwesome.mars_stroke,
  'mars': FontAwesome.mars,
  'maxcdn': FontAwesome.maxcdn,
  'meanpath': FontAwesome.meanpath,
  'medium': FontAwesome.medium,
  'medkit': FontAwesome.medkit,
  'meetup': FontAwesome.meetup,
  'meh-o': FontAwesome.meh_o,
  'mercury': FontAwesome.mercury,
  'microchip': FontAwesome.microchip,
  'microphone-slash': FontAwesome.microphone_slash,
  'microphone': FontAwesome.microphone,
  'minus-circle': FontAwesome.minus_circle,
  'minus-square-o': FontAwesome.minus_square_o,
  'minus-square': FontAwesome.minus_square,
  'minus': FontAwesome.minus,
  'mixcloud': FontAwesome.mixcloud,
  'mobile-phone': FontAwesome.mobile_phone,
  'mobile': FontAwesome.mobile,
  'modx': FontAwesome.modx,
  'money': FontAwesome.money,
  'moon-o': FontAwesome.moon_o,
  'mortar-board': FontAwesome.mortar_board,
  'motorcycle': FontAwesome.motorcycle,
  'mouse-pointer': FontAwesome.mouse_pointer,
  'music': FontAwesome.music,
  'navicon': FontAwesome.navicon,
  'neuter': FontAwesome.neuter,
  'newspaper-o': FontAwesome.newspaper_o,
  'object-group': FontAwesome.object_group,
  'object-ungroup': FontAwesome.object_ungroup,
  'odnoklassniki-square': FontAwesome.odnoklassniki_square,
  'odnoklassniki': FontAwesome.odnoklassniki,
  'opencart': FontAwesome.opencart,
  'openid': FontAwesome.openid,
  'opera': FontAwesome.opera,
  'optin-monster': FontAwesome.optin_monster,
  'outdent': FontAwesome.outdent,
  'pagelines': FontAwesome.pagelines,
  'paint-brush': FontAwesome.paint_brush,
  'paper-plane-o': FontAwesome.paper_plane_o,
  'paper-plane': FontAwesome.paper_plane,
  'paperclip': FontAwesome.paperclip,
  'paragraph': FontAwesome.paragraph,
  'paste': FontAwesome.paste,
  'pause-circle-o': FontAwesome.pause_circle_o,
  'pause-circle': FontAwesome.pause_circle,
  'pause': FontAwesome.pause,
  'paw': FontAwesome.paw,
  'paypal': FontAwesome.paypal,
  'pencil-square-o': FontAwesome.pencil_square_o,
  'pencil-square': FontAwesome.pencil_square,
  'pencil': FontAwesome.pencil,
  'percent': FontAwesome.percent,
  'phone-square': FontAwesome.phone_square,
  'phone': FontAwesome.phone,
  'photo': FontAwesome.photo,
  'picture-o': FontAwesome.picture_o,
  'pie-chart': FontAwesome.pie_chart,
  'pied-piper-alt': FontAwesome.pied_piper_alt,
  'pied-piper-pp': FontAwesome.pied_piper_pp,
  'pied-piper': FontAwesome.pied_piper,
  'pinterest-p': FontAwesome.pinterest_p,
  'pinterest-square': FontAwesome.pinterest_square,
  'pinterest': FontAwesome.pinterest,
  'plane': FontAwesome.plane,
  'play-circle-o': FontAwesome.play_circle_o,
  'play-circle': FontAwesome.play_circle,
  'play': FontAwesome.play,
  'plug': FontAwesome.plug,
  'plus-circle': FontAwesome.plus_circle,
  'plus-square-o': FontAwesome.plus_square_o,
  'plus-square': FontAwesome.plus_square,
  'plus': FontAwesome.plus,
  'podcast': FontAwesome.podcast,
  'power-off': FontAwesome.power_off,
  'print': FontAwesome.print,
  'product-hunt': FontAwesome.product_hunt,
  'puzzle-piece': FontAwesome.puzzle_piece,
  'qq': FontAwesome.qq,
  'qrcode': FontAwesome.qrcode,
  'question-circle-o': FontAwesome.question_circle_o,
  'question-circle': FontAwesome.question_circle,
  'question': FontAwesome.question,
  'quora': FontAwesome.quora,
  'quote-left': FontAwesome.quote_left,
  'quote-right': FontAwesome.quote_right,
  'ra': FontAwesome.ra,
  'random': FontAwesome.random,
  'ravelry': FontAwesome.ravelry,
  'rebel': FontAwesome.rebel,
  'recycle': FontAwesome.recycle,
  'reddit-alien': FontAwesome.reddit_alien,
  'reddit-square': FontAwesome.reddit_square,
  'reddit': FontAwesome.reddit,
  'refresh': FontAwesome.refresh,
  'registered': FontAwesome.registered,
  'remove': FontAwesome.remove,
  'renren': FontAwesome.renren,
  'reorder': FontAwesome.reorder,
  'repeat': FontAwesome.repeat,
  'reply-all': FontAwesome.reply_all,
  'reply': FontAwesome.reply,
  'resistance': FontAwesome.resistance,
  'retweet': FontAwesome.retweet,
  'rmb': FontAwesome.rmb,
  'road': FontAwesome.road,
  'rocket': FontAwesome.rocket,
  'rotate-left': FontAwesome.rotate_left,
  'rotate-right': FontAwesome.rotate_right,
  'rouble': FontAwesome.rouble,
  'rss-square': FontAwesome.rss_square,
  'rss': FontAwesome.rss,
  'rub': FontAwesome.rub,
  'ruble': FontAwesome.ruble,
  'rupee': FontAwesome.rupee,
  's15': FontAwesome.s15,
  'safari': FontAwesome.safari,
  'save': FontAwesome.save,
  'scissors': FontAwesome.scissors,
  'scribd': FontAwesome.scribd,
  'search-minus': FontAwesome.search_minus,
  'search-plus': FontAwesome.search_plus,
  'search': FontAwesome.search,
  'sellsy': FontAwesome.sellsy,
  'send-o': FontAwesome.send_o,
  'send': FontAwesome.send,
  'server': FontAwesome.server,
  'share-alt-square': FontAwesome.share_alt_square,
  'share-alt': FontAwesome.share_alt,
  'share-square-o': FontAwesome.share_square_o,
  'share-square': FontAwesome.share_square,
  'share': FontAwesome.share,
  'shekel': FontAwesome.shekel,
  'sheqel': FontAwesome.sheqel,
  'shield': FontAwesome.shield,
  'ship': FontAwesome.ship,
  'shirtsinbulk': FontAwesome.shirtsinbulk,
  'shopping-bag': FontAwesome.shopping_bag,
  'shopping-basket': FontAwesome.shopping_basket,
  'shopping-cart': FontAwesome.shopping_cart,
  'shower': FontAwesome.shower,
  'sign-in': FontAwesome.sign_in,
  'sign-language': FontAwesome.sign_language,
  'sign-out': FontAwesome.sign_out,
  'signal': FontAwesome.signal,
  'signing': FontAwesome.signing,
  'simplybuilt': FontAwesome.simplybuilt,
  'sitemap': FontAwesome.sitemap,
  'skyatlas': FontAwesome.skyatlas,
  'skype': FontAwesome.skype,
  'slack': FontAwesome.slack,
  'sliders': FontAwesome.sliders,
  'slideshare': FontAwesome.slideshare,
  'smile-o': FontAwesome.smile_o,
  'snapchat-ghost': FontAwesome.snapchat_ghost,
  'snapchat-square': FontAwesome.snapchat_square,
  'snapchat': FontAwesome.snapchat,
  'snowflake-o': FontAwesome.snowflake_o,
  'soccer-ball-o': FontAwesome.soccer_ball_o,
  'sort-alpha-asc': FontAwesome.sort_alpha_asc,
  'sort-alpha-desc': FontAwesome.sort_alpha_desc,
  'sort-amount-asc': FontAwesome.sort_amount_asc,
  'sort-amount-desc': FontAwesome.sort_amount_desc,
  'sort-asc': FontAwesome.sort_asc,
  'sort-desc': FontAwesome.sort_desc,
  'sort-down': FontAwesome.sort_down,
  'sort-numeric-asc': FontAwesome.sort_numeric_asc,
  'sort-numeric-desc': FontAwesome.sort_numeric_desc,
  'sort-up': FontAwesome.sort_up,
  'sort': FontAwesome.sort,
  'soundcloud': FontAwesome.soundcloud,
  'space-shuttle': FontAwesome.space_shuttle,
  'spinner': FontAwesome.spinner,
  'spoon': FontAwesome.spoon,
  'spotify': FontAwesome.spotify,
  'square-o': FontAwesome.square_o,
  'square': FontAwesome.square,
  'stack-exchange': FontAwesome.stack_exchange,
  'stack-overflow': FontAwesome.stack_overflow,
  'star-half-empty': FontAwesome.star_half_empty,
  'star-half-full': FontAwesome.star_half_full,
  'star-half-o': FontAwesome.star_half_o,
  'star-half': FontAwesome.star_half,
  'star-o': FontAwesome.star_o,
  'star': FontAwesome.star,
  'steam-square': FontAwesome.steam_square,
  'steam': FontAwesome.steam,
  'step-backward': FontAwesome.step_backward,
  'step-forward': FontAwesome.step_forward,
  'stethoscope': FontAwesome.stethoscope,
  'sticky-note-o': FontAwesome.sticky_note_o,
  'sticky-note': FontAwesome.sticky_note,
  'stop-circle-o': FontAwesome.stop_circle_o,
  'stop-circle': FontAwesome.stop_circle,
  'stop': FontAwesome.stop,
  'street-view': FontAwesome.street_view,
  'strikethrough': FontAwesome.strikethrough,
  'stumbleupon-circle': FontAwesome.stumbleupon_circle,
  'stumbleupon': FontAwesome.stumbleupon,
  'subscript': FontAwesome.subscript,
  'subway': FontAwesome.subway,
  'suitcase': FontAwesome.suitcase,
  'sun-o': FontAwesome.sun_o,
  'superpowers': FontAwesome.superpowers,
  'superscript': FontAwesome.superscript,
  'support': FontAwesome.support,
  'table': FontAwesome.table,
  'tablet': FontAwesome.tablet,
  'tachometer': FontAwesome.tachometer,
  'tag': FontAwesome.tag,
  'tags': FontAwesome.tags,
  'tasks': FontAwesome.tasks,
  'taxi': FontAwesome.taxi,
  'telegram': FontAwesome.telegram,
  'television': FontAwesome.television,
  'tencent-weibo': FontAwesome.tencent_weibo,
  'terminal': FontAwesome.terminal,
  'text-height': FontAwesome.text_height,
  'text-width': FontAwesome.text_width,
  'th-large': FontAwesome.th_large,
  'th-list': FontAwesome.th_list,
  'th': FontAwesome.th,
  'themeisle': FontAwesome.themeisle,
  'thermometer-0': FontAwesome.thermometer_0,
  'thermometer-1': FontAwesome.thermometer_1,
  'thermometer-2': FontAwesome.thermometer_2,
  'thermometer-3': FontAwesome.thermometer_3,
  'thermometer-4': FontAwesome.thermometer_4,
  'thermometer-empty': FontAwesome.thermometer_empty,
  'thermometer-full': FontAwesome.thermometer_full,
  'thermometer-half': FontAwesome.thermometer_half,
  'thermometer-quarter': FontAwesome.thermometer_quarter,
  'thermometer-three-quarters': FontAwesome.thermometer_three_quarters,
  'thermometer': FontAwesome.thermometer,
  'thumb-tack': FontAwesome.thumb_tack,
  'thumbs-down': FontAwesome.thumbs_down,
  'thumbs-o-down': FontAwesome.thumbs_o_down,
  'thumbs-o-up': FontAwesome.thumbs_o_up,
  'thumbs-up': FontAwesome.thumbs_up,
  'ticket': FontAwesome.ticket,
  'times-circle-o': FontAwesome.times_circle_o,
  'times-circle': FontAwesome.times_circle,
  'times-rectangle-o': FontAwesome.times_rectangle_o,
  'times-rectangle': FontAwesome.times_rectangle,
  'times': FontAwesome.times,
  'tint': FontAwesome.tint,
  'toggle-down': FontAwesome.toggle_down,
  'toggle-left': FontAwesome.toggle_left,
  'toggle-off': FontAwesome.toggle_off,
  'toggle-on': FontAwesome.toggle_on,
  'toggle-right': FontAwesome.toggle_right,
  'toggle-up': FontAwesome.toggle_up,
  'trademark': FontAwesome.trademark,
  'train': FontAwesome.train,
  'transgender-alt': FontAwesome.transgender_alt,
  'transgender': FontAwesome.transgender,
  'trash-o': FontAwesome.trash_o,
  'trash': FontAwesome.trash,
  'tree': FontAwesome.tree,
  'trello': FontAwesome.trello,
  'tripadvisor': FontAwesome.tripadvisor,
  'trophy': FontAwesome.trophy,
  'truck': FontAwesome.truck,
  'try': FontAwesome.try_,
  'tty': FontAwesome.tty,
  'tumblr-square': FontAwesome.tumblr_square,
  'tumblr': FontAwesome.tumblr,
  'turkish-lira': FontAwesome.turkish_lira,
  'tv': FontAwesome.tv,
  'twitch': FontAwesome.twitch,
  'twitter-square': FontAwesome.twitter_square,
  'twitter': FontAwesome.twitter,
  'umbrella': FontAwesome.umbrella,
  'underline': FontAwesome.underline,
  'undo': FontAwesome.undo,
  'universal-access': FontAwesome.universal_access,
  'university': FontAwesome.university,
  'unlink': FontAwesome.unlink,
  'unlock-alt': FontAwesome.unlock_alt,
  'unlock': FontAwesome.unlock,
  'unsorted': FontAwesome.unsorted,
  'upload': FontAwesome.upload,
  'usb': FontAwesome.usb,
  'usd': FontAwesome.usd,
  'user-circle-o': FontAwesome.user_circle_o,
  'user-circle': FontAwesome.user_circle,
  'user-md': FontAwesome.user_md,
  'user-o': FontAwesome.user_o,
  'user-plus': FontAwesome.user_plus,
  'user-secret': FontAwesome.user_secret,
  'user-times': FontAwesome.user_times,
  'user': FontAwesome.user,
  'users': FontAwesome.users,
  'vcard-o': FontAwesome.vcard_o,
  'vcard': FontAwesome.vcard,
  'venus-double': FontAwesome.venus_double,
  'venus-mars': FontAwesome.venus_mars,
  'venus': FontAwesome.venus,
  'viacoin': FontAwesome.viacoin,
  'viadeo-square': FontAwesome.viadeo_square,
  'viadeo': FontAwesome.viadeo,
  'video-camera': FontAwesome.video_camera,
  'vimeo-square': FontAwesome.vimeo_square,
  'vimeo': FontAwesome.vimeo,
  'vine': FontAwesome.vine,
  'vk': FontAwesome.vk,
  'volume-control-phone': FontAwesome.volume_control_phone,
  'volume-down': FontAwesome.volume_down,
  'volume-off': FontAwesome.volume_off,
  'volume-up': FontAwesome.volume_up,
  'warning': FontAwesome.warning,
  'wechat': FontAwesome.wechat,
  'weibo': FontAwesome.weibo,
  'weixin': FontAwesome.weixin,
  'whatsapp': FontAwesome.whatsapp,
  'wheelchair-alt': FontAwesome.wheelchair_alt,
  'wheelchair': FontAwesome.wheelchair,
  'wifi': FontAwesome.wifi,
  'wikipedia-w': FontAwesome.wikipedia_w,
  'window-close-o': FontAwesome.window_close_o,
  'window-close': FontAwesome.window_close,
  'window-maximize': FontAwesome.window_maximize,
  'window-minimize': FontAwesome.window_minimize,
  'window-restore': FontAwesome.window_restore,
  'windows': FontAwesome.windows,
  'won': FontAwesome.won,
  'wordpress': FontAwesome.wordpress,
  'wpbeginner': FontAwesome.wpbeginner,
  'wpexplorer': FontAwesome.wpexplorer,
  'wpforms': FontAwesome.wpforms,
  'wrench': FontAwesome.wrench,
  'xing-square': FontAwesome.xing_square,
  'xing': FontAwesome.xing,
  'y-combinator-square': FontAwesome.y_combinator_square,
  'y-combinator': FontAwesome.y_combinator,
  'yahoo': FontAwesome.yahoo,
  'yc-square': FontAwesome.yc_square,
  'yc': FontAwesome.yc,
  'yelp': FontAwesome.yelp,
  'yen': FontAwesome.yen,
  'yoast': FontAwesome.yoast,
  'youtube-play': FontAwesome.youtube_play,
  'youtube-square': FontAwesome.youtube_square,
  'youtube': FontAwesome.youtube
};
