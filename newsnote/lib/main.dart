import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsnote/screen/feed_screen.dart';
import 'package:newsnote/widget/bottom_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  TabController controller;
  bool alarm_pressed = false;
  String uuid;
  final String TableName = 'Dog';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDeiveInfo();
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  _saveMem(String kind, String saveStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kind, saveStr);
    print('SAVED "${kind}" : $saveStr ');
  }

  _loadMem(String kind) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getStr = await prefs.getString(kind);
    print('LOAD "${kind}" : $getStr ');
  }

  _getDeiveInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    String get_uuid;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

        get_uuid = androidInfo.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        get_uuid = iosInfo.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    setState(() {
      print('UUID info!!! ${get_uuid}');
      _saveMem('uuid', get_uuid); // shared_prefer 에 uuid 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'newsnote',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.search, color: Colors.black54),
                    onPressed: () {
                      _saveMem('uuid', uuid);
                      //_fetchData();
                    }),
                IconButton(
                  tooltip: '새 글 알림설정',
                  icon: Padding(
                      padding: EdgeInsets.only(left: 4, right: 4, top: 0),
                      child: alarm_pressed == true
                          ? Icon(
                              Icons.notifications,
                              color: Colors.black54,
                            )
                          : Icon(
                              Icons.notifications_off,
                              color: Colors.black54,
                            )),
                  onPressed: () {
                    setState(() {
                      if (alarm_pressed) {
                        alarm_pressed = false;
                      } else {
                        alarm_pressed = true;
                      }
                    });
                  },
                ),
              ],
            )
          ],
        ),
        body: DefaultTabController(
          length: 4,
          child: Scaffold(
            body: TabBarView(
              physics:
                  NeverScrollableScrollPhysics(), //옆으로 스크롤해도 넘어가지 않도록(바텀탭으로만 이동하게 하려고함)
              children: <Widget>[
                FeedScreen(),
                Container(child: Text('2')),
                Container(child: Text('3')),
                Container(child: Text('4')),
              ],
            ),
            bottomNavigationBar: Bottom(),
          ),
        ),
      ),
    );
  }
}
