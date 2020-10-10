import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsnote/screen/feed_screen.dart';
import 'package:newsnote/screen/home_screen.dart';
import 'package:newsnote/screen/like_screen.dart';
import 'package:newsnote/widget/bottom_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String log = '';
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Map<String, String> deviceRegHeader = {"X-DEVICE-UUID": ""};
  Map<String, String> requestBody = {"fcm_token": ""};
  TabController controller;
  bool alarm_pressed = false;
  bool isDisposed = false;
  String uuid;
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _setFirebaseMsg(_firebaseMessaging);
    _setDeiveInfo();
  }

  _setFirebaseMsg(FirebaseMessaging _firebaseMessaging) {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print('token : $token');
      requestBody['fcm_token'] = token;
      log = log + 'getToken : ' + token;
    });
  }

  _deviceReg() {
    print('_deviceReg()');
    print('$deviceRegHeader');
    print('$requestBody');
    http
        .post('http://dofta11.synology.me:8888/api/v1/device_infos',
            headers: deviceRegHeader, body: requestBody)
        .then((response) {
      log = log + '[deviceReg]statusCode = ${response.statusCode}';
      if (response.statusCode == 201) {
        String jsonString = utf8.decode(response.bodyBytes);
        Map<String, dynamic> resMap = jsonDecode(jsonString);
        log = log + '[deviceReg]statusCode = ${response.statusCode}';
        print(resMap['message']);
      } else {
        print('_deviceReg() : ${response.statusCode} Error!');
      }
    });
  }

  _saveMem(String kind, String saveStr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kind, saveStr);
    print('[MAIN.DART] SAVED "${kind}" : $saveStr ');
    _deviceReg();
  }

  _loadMem(String kind) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getStr = await prefs.getString(kind);
    print('[MAIN.DART] LOAD "${kind}" : $getStr ');
  }

  _setDeiveInfo() async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    String get_uuid;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

        get_uuid = androidInfo.androidId; //UUID for Android
        uuid = get_uuid;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        get_uuid = iosInfo.identifierForVendor; //UUID for iOS
        uuid = get_uuid;
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    if (!isDisposed) {
      setState(() {
        print('[MAIN.DART] UUID info!!! ${get_uuid}');
        deviceRegHeader['X-DEVICE-UUID'] = uuid;
        _saveMem('uuid', get_uuid); // shared_prefer 에 uuid 저장
      });
    }
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
                    onPressed: () {}),
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
                HomeScreen(uuid),
                FeedScreen(),
                LikeScreen(uuid),
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
