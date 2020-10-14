import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsnote/screen/feed_screen.dart';
import 'package:newsnote/screen/home_screen.dart';
import 'package:newsnote/screen/like_screen.dart';
import 'package:newsnote/screen/setting_screen.dart';
import 'package:newsnote/widget/bottom_bar.dart';
import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String get_uuid;
  String get_token;
  bool reg_success;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  print('main()');
  /*
  앱 시작전 초기화 작업 진행
  setDeiveInfo : uuid 가져오기
  _setFirebaseMsg : fcm token 가져오기
  _deviceReg : device등록API 호출
  */
  get_uuid = await _setDeiveInfo();
  get_token = await _setFirebaseMsg(_firebaseMessaging);
  reg_success = await _deviceReg(get_uuid, get_token);

  runApp(MyApp(get_uuid, get_token));
}

Future<bool> _deviceReg(String uuid, String token) async {
  print('_deviceReg() START');
  Map<String, String> deviceRegHeader = {"X-DEVICE-UUID": ""};
  Map<String, String> requestBody = {"fcm_token": ""};
  print('param1 : $uuid , param2 : $token');

  deviceRegHeader['X-DEVICE-UUID'] = uuid;
  requestBody['fcm_token'] = token;
  final response = await http.post(
      'http://dofta11.synology.me:8888/api/v1/device_infos',
      headers: deviceRegHeader,
      body: requestBody);

  if (response.statusCode == 201) {
    String jsonString = utf8.decode(response.bodyBytes);
    Map<String, dynamic> resMap = jsonDecode(jsonString);
    print(resMap['message']);
    print('_deviceReg() END');
  } else {
    print('_deviceReg() : ${response.statusCode} Error!');
  }
}

Future<String> _setDeiveInfo() async {
  print('_setDeiveInfo() START');
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
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
    print('_setDeiveInfo() END');
    return get_uuid;
  } on PlatformException {
    print('Failed to get platform version');
  }
}

Future<String> _setFirebaseMsg(FirebaseMessaging _firebaseMessaging) async {
  print('_firebaseMessaging getToken() START');
  String token;
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
  await _firebaseMessaging.getToken().then((String getToken) async {
    assert(getToken != null);
    print('token : $getToken');
    token = getToken;
    print('_firebaseMessaging getToken() END');
  });
  return token;
}

class MyApp extends StatefulWidget {
  String uuid;
  String token;
  MyApp(this.uuid, this.token);
  _MyAppState createState() => _MyAppState(uuid, token);
}

class _MyAppState extends State<MyApp> {
  String log = '';
  String token;
  String uuid;
  _MyAppState(this.uuid, this.token);

  TabController controller;
  bool alarm_pressed = false;
  bool isDisposed = false;
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    print('initState()');
    //_saveMem('UUID', uuid);
  }

/* sharedmemory 저장 , 로드 기능
  _saveMem(String kind, String saveStr) async {
    print('_saveMem');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kind, saveStr);
    print('[MAIN.DART] SAVED "${kind}" : $saveStr ');
  }

  _loadMem(String kind) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getStr = await prefs.getString(kind);
    print('[MAIN.DART] LOAD "${kind}" : $getStr ');
  }
*/
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
                FeedScreen(uuid),
                LikeScreen(uuid),
                Container(
                  child: Text('4'),
                ),
                //HomePage(),
              ],
            ),
            bottomNavigationBar: Bottom(),
          ),
        ),
      ),
    );
  }
}
