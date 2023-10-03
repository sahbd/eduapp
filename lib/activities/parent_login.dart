import 'dart:convert';
import 'package:eduapp/getAllDataFromApi.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../notification_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  GetAllDataFromApi getAllDataFromApi = GetAllDataFromApi();
  static const bar_color = const Color(0xFF183967);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bar_color,
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: bar_color),
              child: Text('Login'),
              onPressed: () async {
                // Perform login logic here
                String email = _emailController.text;
                String password = _passwordController.text;
                String token = "";
                await notificationServices.getDeviceToken().then((value) {
                  //print("device token");
                  token = value;
                  //print(value);
                });
                // Add your authentiString url = 'https://example.com/api/register_device';
                String url = "${getAllDataFromApi.serverURL}/deviceLogin?email=${email}&password=${password}&token=${token}";
                final response = await http.get(Uri.parse(url));
                //Fluttertoast.showToast(msg: email);
                //Fluttertoast.showToast(msg: password);
                //Fluttertoast.showToast(msg: token);
                //print("Devide Token:"+token);
                print(token);
                if (response.statusCode == 200) {
                  final body = response.body;
                  final jsonData = json.decode(body);
                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  //print('Success response:');
                  print('Status: ${jsonData[0]['user_type']}');
                  if(jsonData[0]['status'] == 'success')
                    {
                      await prefs.setString('isParentLoggedIn', 'true');
                      await prefs.setString('user_type',jsonData[0]['user_type']);
                      await prefs.setInt('user_id',jsonData[0]['user_id']);
                      await prefs.setString('pref_email',email);
                      await prefs.setString('pref_password', password);
                      await prefs.setString('pref_token', token);
                      Fluttertoast.showToast(msg: "Logged in successfully as a ${jsonData[0]['user_type']}",toastLength: Toast.LENGTH_LONG,);

                    }
                  else
                    {
                      Fluttertoast.showToast(msg: "Credential doesn't matched");
                    }
                  //print('Message: ${jsonData['message']}');
                  //print('Data: ${jsonData['data']}');

                  Navigator.pop(context);

                } else {
                  Fluttertoast.showToast(msg: "Network Error");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
