import 'package:flutter/material.dart';
import 'package:newsnote/model/written.dart';
import 'package:newsnote/widget/web_view_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// 1. 로고 이미지 변경
// /andorid/app/src/main/res/drawable/launch_backgroud.xml 파일에 로고 이미지 설정
// /ios/runner/assests.xcassets/lauchimage.imageset
// 2. map, json 코드
//https://flutter-ko.dev/docs/development/data-and-backend/json
// 3. 리스트 형식
//https://devmemory.tistory.com/14
// 9. 정리
//https://juyeonglee.tistory.com/14
//https://fkkmemi.github.io/ff/ff-011/

// 10. 디바이스 정보 가져오기
//https://pub.dev/packages/device_info/example
/* 
// 11. 아이콘 이미지
//https://api.flutter.dev/flutter/material/Icons-class.html
[
    {
        "id": "0",
        "author": "Alejandro Escamilla",
        "width": 5616,
        "height": 3744,
        "url": "https://unsplash.com/...",
        "download_url": "https://picsum.photos/..."
    }
]

// 12. 페이징 처리!!

https://pub.dev/packages/flutter_paginator/example
*/
class FeedScreen extends StatefulWidget {
  String uuid;
  FeedScreen(this.uuid);
  _FeedScreenState createState() => _FeedScreenState(this.uuid);
}

class _FeedScreenState extends State<FeedScreen> {
  String _uuid;
  _FeedScreenState(this._uuid);
  List _data = [];
  Map<String, String> postsHeader = {"X-DEVICE-UUID": ""};

  String log = '';
  bool isDisposed = false;

  /*
  _loadMem(String kind) async {
    log = log + '_loadMem START | ';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String getStr = await prefs.getString(kind);
    print('LOAD "${kind}" : ${getStr} ');
    postsHeader['X-DEVICE-UUID'] = getStr;
    log = log + ('_loadMem END | ');
    _fetchWrittenList();
  }
  */

  _fetchWrittenList() {
    log = log + '_fetchWrittenList START | ';
    print('_fetchWrittenList()');
    postsHeader['X-DEVICE-UUID'] = _uuid;
    print(postsHeader);
    http
        .get('http://dofta11.synology.me:8888/api/v1/posts?page=1',
            headers: postsHeader)
        .then((response) {
      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);

        List writtens = jsonDecode(jsonString);

        for (int i = 0; i < writtens.length; i++) {
          var written = writtens[i];
          Written writtenToAdd = Written(
            written["id"],
            written["title"],
            written["url"],
            written["description"],
            written["image"],
            written["likes"],
            written["created_at"],
          );
          if (!isDisposed) {
            setState(() {
              _data.add(writtenToAdd);
            });
          }
        }
      } else {
        print('_fetchData() ERROR!!');
      }
      log = log + '_fetchWrittenList END | ';
    });
  }

  @override
  void initState() {
    _fetchWrittenList();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0.1, 0.0, 1.0, 0.1),
      itemCount: _data.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text('피드',
                        style: TextStyle(fontSize: 27.0, color: Colors.black))),
                Expanded(
                    child: IconButton(
                  icon: Icon(Icons.ac_unit),
                  onPressed: () {
                    showAlertDialog(context, log);
                  },
                ))
              ],
            ),
          );
        } else {
          index = index - 1;
          Written written = _data[index];
          String imageurl = written.image;
          print(imageurl);

          if (imageurl == null) {
            imageurl = 'https://picsum.photos/70/70.jpg'; //image url이 없을때
          }
          log = log + written.title;

          return ListTile(
            onTap: () {
              final url = written.url;
              _handleURLButtonPress(
                  context, url, written.id, postsHeader['X-DEVICE-UUID']);
            },
            title: Text(
              //'${written.id}. ${written.title}',
              '${written.title}',
              style: TextStyle(height: 1.1, fontSize: 17.5),
            ),
            subtitle: Text(
              '${written.description}',
              style: TextStyle(height: 1.3, fontSize: 12),
            ),
            trailing: Image.network('${imageurl}', width: 70, height: 70),
            isThreeLine: true,
          );
        }
      },
      separatorBuilder: (context, index) {
        if (index > 0) {
          index = index - 1;
          Written written = _data[index];
          return Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('     '),
                Icon(
                  Icons.favorite_border,
                  color: Colors.black,
                  size: 10.0,
                ),
                Text('${written.likes}    ', style: TextStyle(fontSize: 10)),
                Icon(
                  Icons.remove_red_eye,
                  color: Colors.black,
                  size: 10.0,
                ),
                Text(' 1024', style: TextStyle(fontSize: 10)),
              ],
            ),
            Divider(
              height: 18,
            ),
          ]);
        } else {
          return Divider(
            height: 18,
            color: Colors.grey,
          );
        }
      },
    );
  }

  void _handleURLButtonPress(
      BuildContext context, String url, int id, String uuid) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(url, id, uuid)));
  }
}

class HeaderTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('피드'),
    );
  }
}

void showAlertDialog(BuildContext context, String log) async {
  String result = await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('AlertDialog Demo'),
        content: Text(log),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, "OK");
            },
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, "Cancel");
            },
          ),
        ],
      );
    },
  );
}
