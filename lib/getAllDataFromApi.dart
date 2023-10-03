import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class GetAllDataFromApi {
  String appName = "INFOSCHOOL";
  String serverURL = "https://myapp.startnext.tech/";
  String packageName = 'com.sahbd.eduapp';
  String pref_user_type = 'public';

  bool _checkConnection = true;
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

  //#################################### Notices ##################################

  List datamynotice = [];
  Future<void> forceNoticeUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mynotice'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveNoticeFile(body.toString());
      }

    }
  }


  Future<void> fetchNoticeItem() async {
    String fileName = "mynotice.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readNoticeFile();
      datamynotice = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mynotice'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveNoticeFile(body.toString());
        }

      }
      else
      {

      }

    }

  }

  Future<String> getNoticeFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mynotice.json'; // 3

    return filePath;
  }

  void saveNoticeFile(String jsonText) async {
    File file = File(await getNoticeFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readNoticeFile() async {
    File file = File(await getNoticeFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

  //#################################### Notifications ##################################

  List datamynotification = [];
  Future<void> forceNotificationUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mynotification'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveNotificationFile(body.toString());
      }

    }
  }


  Future<void> fetchNotificationItem() async {
    String fileName = "mynotification.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readNotificationFile();
      datamynotification = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mynotification'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveNotificationFile(body.toString());
        }

      }
      else
      {

      }

    }

  }

  Future<String> getNotificationFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mynotification.json'; // 3

    return filePath;
  }

  void saveNotificationFile(String jsonText) async {
    File file = File(await getNotificationFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readNotificationFile() async {
    File file = File(await getNotificationFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

//#################################### ROUTINE ##################################


  List datamyroutine = [];

  Future<void> forceRoutineUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=myroutine'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveRoutineFile(body.toString());
      }

    }
  }

  Future<void> fetchRoutineItem() async {
    String fileName = "myroutine.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readRoutineFile();
      datamyroutine = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=myroutine'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveRoutineFile(body.toString());
        }

      }
      else
      {

      }

    }

  }

  Future<String> getRoutineFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/myroutine.json'; // 3

    return filePath;
  }

  void saveRoutineFile(String jsonText) async {
    File file = File(await getRoutineFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readRoutineFile() async {


    File file = File(await getRoutineFilePath()); // 1
    String temp_fileContent = await file.readAsString(); // 2
    List temp_data = [];
    temp_data = await json.decode(temp_fileContent);

    String fileContent = json.encode(temp_data);
    print('File Content: $fileContent');
    return fileContent;
  }
//#################################### CALENDAR ##################################

  List datamycalendar = [];

  Future<void> forceCalendarUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mycalendar'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveCalenderFile(body.toString());
      }

    }
  }


  Future<void> fetchCalenderItem() async {
    String fileName = "mycalendar.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readCalenderFile();
      datamycalendar = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mycalendar'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveCalenderFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getCalenderFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mycalendar.json'; // 3

    return filePath;
  }

  void saveCalenderFile(String jsonText) async {
    File file = File(await getCalenderFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readCalenderFile() async {
    File file = File(await getCalenderFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }


//#################################### Website ##################################

  List datamywebsite = [];

  Future<void> forceWebsiteUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mywebsite'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveWebsiteFile(body.toString());
      }

    }
  }


  Future<void> fetchWebsiteItem() async {
    String fileName = "mywebsite.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readWebsiteFile();
      datamywebsite = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mywebsite'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveWebsiteFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getWebsiteFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mywebsite.json'; // 3

    return filePath;
  }

  void saveWebsiteFile(String jsonText) async {
    File file = File(await getWebsiteFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readWebsiteFile() async {
    File file = File(await getWebsiteFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }


//#################################### STATIC ##################################


  List datamystatic = [];

  Future<void> forceStaticUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mystatic'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveStaticFile(body.toString());
      }

    }
  }

  Future<void> fetchStaticItem() async {
    String fileName = "mystatic.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readStaticFile();
      datamystatic = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mystatic'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveStaticFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getStaticFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mystatic.json'; // 3

    return filePath;
  }

  void saveStaticFile(String jsonText) async {
    File file = File(await getStaticFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readStaticFile() async {
    File file = File(await getStaticFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }
  Future<List<dynamic>> readStaticJsonData() async {
    File file = File(await getStaticFilePath()); // 1
    String jsonString = await file.readAsString(); // 2
    // String jsonString = await rootBundle.loadString('assets/mycontact.json');
    List<dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  }


  Future<dynamic> getStaticItemBy(int id) async {
    List<dynamic> jsonData = await readStaticJsonData();
    dynamic item;

    for (dynamic jsonItem in jsonData) {
      if (jsonItem['id'] == id) {
        item = jsonItem;
        break;
      }
    }

    return item;
  }

//#################################### EXTERNAL ##################################


  List datamyexternal = [];

  Future<void> forceExternalUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=myexternal'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveExternalFile(body.toString());
      }

    }
  }


  Future<void> fetchExternalItem() async {
    String fileName = "myexternal.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readExternalFile();
      datamyexternal = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=myexternal'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveExternalFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getExternalFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/myexternal.json'; // 3

    return filePath;
  }

  void saveExternalFile(String jsonText) async {
    File file = File(await getExternalFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readExternalFile() async {
    File file = File(await getExternalFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

//#################################### SOCIALPAGES ##################################


  List datamysocialpage = [];
  Future<void> forceSocialPageUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mysocialpage'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveSocialPageFile(body.toString());
      }

    }
  }

  Future<void> fetchSocialPageItem() async {
    String fileName = "mysocialpage.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readSocialPageFile();
      datamysocialpage = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mysocialpage'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveSocialPageFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getSocialPageFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mysocialpage.json'; // 3

    return filePath;
  }

  void saveSocialPageFile(String jsonText) async {
    File file = File(await getSocialPageFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readSocialPageFile() async {
    File file = File(await getSocialPageFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

  Future<List> getSocialPageList() async {

    var jsonText = await readSocialPageFile();
    var dataList  = json.decode(jsonText);

    return dataList;
  }



  Future<List<dynamic>> readSocialJsonData() async {
    File file = File(await getSocialPageFilePath()); // 1
    String jsonString = await file.readAsString(); // 2
    // String jsonString = await rootBundle.loadString('assets/mycontact.json');
    List<dynamic> jsonData = json.decode(jsonString);
    print(jsonData);
    return jsonData;
  }

  Future<String> getAppPhone(String type) async {
    List<dynamic> jsonData = await getSocialPageList();
    dynamic item;

    for (dynamic jsonItem in jsonData) {
      if (jsonItem['type'] == type) {
        item = jsonItem['networkURL'];
        break;
      }
    }

    return item;
  }

  Future<String> getAppFB(String type) async {
    List<dynamic> jsonData = await getSocialPageList();
    dynamic item;

    for (dynamic jsonItem in jsonData) {
      if (jsonItem['type'] == type) {
        item = jsonItem['networkURL'];
        break;
      }
    }

    return item;
  }

  Future<String> getAppTW(String type) async {
    List<dynamic> jsonData = await getSocialPageList();
    dynamic item;

    for (dynamic jsonItem in jsonData) {
      if (jsonItem['type'] == type) {
        item = jsonItem['networkURL'];
        break;
      }
    }

    return item;
  }

//#################################### APPSETTINGS ##################################


  List datamysettings = [];

  Future<void> forceSettingsUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mysettings'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveSettingsFile(body.toString());
      }

    }
  }

  Future<void> fetchSettingsItem() async {
    String fileName = "mysettings.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readSettingsFile();
      datamysettings = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mysettings'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveSettingsFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getSettingsFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mysettings.json'; // 3

    return filePath;
  }

  void saveSettingsFile(String jsonText) async {
    File file = File(await getSettingsFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readSettingsFile() async {
    File file = File(await getSettingsFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

  Future<String> getFacultyWiseView() async {
    // Parse the JSON data
    var jsonData = await readSettingsFile() as String;
    List dataList = json.decode(jsonData);
    //print("Data: "+dataList[0]['facultywiseView']);
    return dataList[0]['facultywiseView'].toString();
  }

  Future<String> getAppPassword() async {
    // Parse the JSON data
    var jsonData = await readSettingsFile() as String;
    List dataList = json.decode(jsonData);
    //print("Data: "+dataList[0]['facultywiseView']);
    return dataList[0]['password'].toString();
  }

//#################################### CONTACT ##################################

  List datamycontact = [];


  Future<void> forceContactUpdate() async {
    if(await checkConnection())
    {

      final response = await http
          .get(Uri.parse('${serverURL}/json-data?data=mycontact'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final body = response.body;
        print(body);
        saveContactFile(body.toString());
      }

    }
  }


  Future<List<dynamic>> readJsonData() async {
    File file = File(await getContactFilePath()); // 1
    String jsonString = await file.readAsString(); // 2
   // String jsonString = await rootBundle.loadString('assets/mycontact.json');
    List<dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  }

  Future<dynamic> getItemById(int id) async {
    List<dynamic> jsonData = await readJsonData();
    dynamic item;

    for (dynamic jsonItem in jsonData) {
      if (jsonItem['id'] == id) {
        item = jsonItem;
        break;
      }
    }

    return item;
  }



  Future<void> fetchContactItem() async {
    String fileName = "mycontact.json";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';
    if(await File(savePath).exists())
    {
      var jsonText = await readContactFile();
      datamycontact = json.decode(jsonText);
    }
    else
    {
      if(await checkConnection())
      {

        final response = await http
            .get(Uri.parse('${serverURL}/json-data?data=mycontact'));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          final body = response.body;
          print(body);
          saveContactFile(body.toString());

        }

      }
      else
      {

      }

    }

  }

  Future<String> getContactFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/mycontact.json'; // 3

    return filePath;
  }

  void saveContactFile(String jsonText) async {
    File file = File(await getContactFilePath()); // 1
    file.writeAsString(jsonText); // 2
  }

  Future<String> readContactFile() async {
    File file = File(await getContactFilePath()); // 1
    String fileContent = await file.readAsString(); // 2

    print('File Content: $fileContent');
    return fileContent;
  }

  Future<List> getFacultyList() async {

    var jsonText = await readContactFile();
    List<dynamic> data = json.decode(jsonText);
    List distinctFacultyNames = data.map((item) => item['facultyName']).toSet().toList();
    return distinctFacultyNames;
  }

  Future<List<String>> getDepartmentList(String faculty) async {

    var jsonText = await readContactFile();
    List<dynamic> data = json.decode(jsonText);
    Set<String> distinctDepartments;
    String desiredFacultyName = faculty;
    if(faculty == "_all")
      {
        distinctDepartments = Set.from(data
            .map((data) => data['departmentName']));
      }
    else
      {
        distinctDepartments = Set.from(data
            .where((data) => data['facultyName'] == desiredFacultyName)
            .map((data) => data['departmentName']));
      }
// Filter the data and get distinct departmentName values


// Convert the Set to a List if needed
    return distinctDepartments.toList();
  }

  Future<List> getContactList(String department) async {

    var jsonText = await readContactFile();
    List<dynamic> dataList  = json.decode(jsonText);
    List filteredData = dataList.where((data) => data['departmentName'] == department).toList();

    return filteredData;
  }


}