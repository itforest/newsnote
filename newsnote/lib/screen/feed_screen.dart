import 'package:flutter/material.dart';
import 'package:newsnote/model/written.dart';
import 'package:newsnote/widget/web_view_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
*/
class FeedScreen extends StatefulWidget {
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List _data = [];

  _fetchData() {
    http.get('http://49.50.163.204/api/v1/posts').then((response) {
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
          );

          setState(() {
            _data.add(writtenToAdd);
          });
        }
        //print(jsonString);
      } else {
        print('ERROR!!');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0.1, 0.0, 1.0, 0.1),
      itemCount: _data.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text('피드',
                        style: TextStyle(fontSize: 27.0, color: Colors.black))),
              ],
            ),
          );
        } else {
          Written written = _data[index];
          String imageurl = written.image;
          print(imageurl);

          if (imageurl == "") {
            imageurl = 'https://picsum.photos/70/70.jpg'; //image url이 없을때
          }

          return ListTile(
            onTap: () {
              final url = written.url;
              _handleURLButtonPress(context, url);
            },
            title: Text(
              //'${written.id}. ${written.title}',
              '${written.title}',
              style: TextStyle(height: 1.1, fontSize: 17.5),
            ),
            subtitle: Text(
              written.description,
              style: TextStyle(height: 1.3, fontSize: 12),
            ),
            trailing: Image.network('${imageurl}', width: 70, height: 70),
            isThreeLine: true,
          );
        }
      },
      separatorBuilder: (context, index) {
        if (index > 0) {
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
                Text('10   ', style: TextStyle(fontSize: 10)),
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

  void _handleURLButtonPress(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
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
