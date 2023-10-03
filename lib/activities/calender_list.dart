import 'dart:convert';
import 'dart:io';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  static const color = const Color(0xFFF5F5F5);
  static const app_color = const Color(0xFF183967);
  Map<String, List<dynamic>> mySelectedEvents = {};
  late List<dynamic> jsonArray;
  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDate = _focusedDay;
    loadPreviousEvents();
    getUpdateCalendar();

  }

  Future<void> getUpdateCalendar() async {
    if(await getAllDataFromApi.checkConnection())
    {
      String fileName = "mycalendar.json";
      String dir = (await getApplicationDocumentsDirectory()).path;
      String savePath = '$dir/$fileName';
      if(await File(savePath).exists())
      {

        String url = "${getAllDataFromApi.serverURL}/json-data?data=mysettings";
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final body = response.body;
          final jsonData = json.decode(body);
          String calendar = jsonData[0]['calendar'];
          String appSettings = await getAllDataFromApi.readSettingsFile();
          List settings = json.decode(appSettings);
          //print("App: "+module);
          //print("Web: "+settings[0][module]);
          if(settings[0]["calendar"] != calendar)
          {

            await getCalendarData();
          }
        } else {
          Fluttertoast.showToast(msg: "Server Error");
        }
      }
      else
      {
        await getCalendarData();
      }
    }
    else
    {
      Fluttertoast.showToast(msg: "You are in offline mode");
    }
  }

  Future<void> getCalendarData() async{
    showDialog(context: context, builder: (context){
      return const SpinKitCubeGrid(
        color: color,
        size: 100,
      );
    });

    await getAllDataFromApi.forceCalendarUpdate();
    await getAllDataFromApi.forceSettingsUpdate();
    readCalendarFile();
    loadPreviousEvents();
    Navigator.of(context).pop();
  }

  Future<void> readCalendarFile() async {
    await getAllDataFromApi.fetchCalenderItem();
    String fileContent =  await getAllDataFromApi.readCalenderFile();

    //print('File Content: $fileContent');
    setState(() => jsonArray = json.decode(fileContent));
  }

  Map<String, List<dynamic>> convertJsonToListMap(String jsonString) {
    jsonArray = json.decode(jsonString);
    Map<String, List<dynamic>> resultMap = {};

    for (var item in jsonArray) {
      String eventDate = item['event_date'];

      if (!resultMap.containsKey(eventDate)) {
        resultMap[eventDate] = [];
      }

      Map<String, dynamic> eventMap = {
        'eventDescp': item['details'],
        'eventTitle': item['title'],
      };

      resultMap[eventDate]?.add(eventMap);
    }

    return resultMap;
  }

  loadPreviousEvents() async {
    String jsonString = await getAllDataFromApi.readCalenderFile();

    mySelectedEvents = convertJsonToListMap(jsonString);
    //print("Hello : {$mySelectedEvents}");
    setState(() {});

  }
  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calendar'),
        backgroundColor: app_color,
      ),
      body: Column(
        children: [
        TableCalendar(
          firstDay: DateTime(_focusedDay.year, _focusedDay.month - 3, _focusedDay.day),
          lastDay: DateTime(_focusedDay.year, _focusedDay.month + 3, _focusedDay.day),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDate, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDate, day);
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              // Call `setState()` when updating calendar format
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
          eventLoader: _listOfDayEvents,
        ),
          ..._listOfDayEvents(_selectedDate!).map(
                (myEvents) => Card(
                  child: ListTile(

                    leading: const Icon(
                      Icons.access_time_filled_sharp,
                      color: app_color,
                    ),
                    contentPadding: EdgeInsets.only(left: 15.0, right: 15.0),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('${myEvents['eventTitle']}'),
                    ),
                    subtitle: Text('${myEvents['eventDescp']}'),
                  ),
                ),
          ),
        ],

      ),
    );
  }


}