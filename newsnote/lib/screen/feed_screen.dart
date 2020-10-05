import 'package:flutter/material.dart';
import 'package:newsnote/model/written.dart';
import 'package:newsnote/widget/web_view_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//map, json 코드
//https://flutter-ko.dev/docs/development/data-and-backend/json
//정리
//https://juyeonglee.tistory.com/14
//https://fkkmemi.github.io/ff/ff-011/
// 리스트 형식
//https://devmemory.tistory.com/14

/* 
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
          Written writtenToAdd =
              Written(written["title"], written["url"], written["description"]);

          setState(() {
            _data.add(writtenToAdd);
          });
        }
        print(jsonString);
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
      padding: const EdgeInsets.fromLTRB(0.5, 0.0, 1.0, 0.5),
      itemCount: _data.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text('피드',
                        style: TextStyle(fontSize: 30.0, color: Colors.black))),
              ],
            ),
          );
        } else {
          Written written = _data[index];

          return ListTile(
            onTap: () {},
            title: Text(written.title),
            subtitle: Text(written.url), //Text(written.description),
            trailing: Image.network(
                //'https://picsum.photos/id/${written.id}/100/100'),
                'https://picsum.photos/id/1/100/100'),
          );

          /* Card(
              child: Column(
            children: <Widget>[
              Text(written.title),
              Image.network('https://picsum.photos/id/${written.title}/300/300')
            ],
          ));
          */
        }
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );

    /*
    return ListView(
      
        padding: const EdgeInsets.fromLTRB(5.0, 35.0, 5.0, 5.0),
        children: <Widget>[
          ListTile(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: Text('피드',
                        style: TextStyle(fontSize: 30.0, color: Colors.black))),
                IconButton(
                  tooltip: '새 글 알림설정',
                  icon: Padding(
                      padding: EdgeInsets.only(left: 4, right: 4, top: 0),
                      child: alarm_pressed == true
                          ? Icon(Icons.notifications)
                          : Icon(Icons.notifications_off)),
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
            ),
          ),
          ListTile(
            //backgroundImage: NetworkImage(imageUrl),
            title: Text('One-line with trailing widget'),
            subtitle: Text(
                'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
            trailing: FlutterLogo(),
            onTap: () {
              final url = 'http://www.naver.com';
              _handleURLButtonPress(context, url);
              // do something
            },
          ),
          ListTile(
            //backgroundImage: NetworkImage(imageUrl),
            title: Text('One-line with trailing widget'),
            subtitle: Text(
                'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
            trailing: FlutterLogo(),
            onTap: () {
              final url = 'http://www.naver.com';
              _handleURLButtonPress(context, url);
              // do something
            },
          ),
          ListTile(
            //backgroundImage: NetworkImage(imageUrl),
            title: Text('One-line with trailing widget'),
            subtitle: Text(
                'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
            trailing: FlutterLogo(),
            onTap: () {
              final url = 'http://www.naver.com';
              _handleURLButtonPress(context, url);
              // do something
            },
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(),
              title: Text('One-line with trailing widget'),
              subtitle: Text(
                  'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
              trailing: Icon(Icons.keyboard_arrow_right),
              isThreeLine: true,
              onTap: () {
                final url = 'http://www.naver.com';
                _handleURLButtonPress(context, url);
                // do something
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(),
              title: Text('One-line with trailing widget'),
              subtitle: Text(
                  'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
              trailing: Icon(Icons.keyboard_arrow_right),
              isThreeLine: true,
              onTap: () {
                final url = 'http://www.naver.com';
                _handleURLButtonPress(context, url);
                // do something
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: FlutterLogo(),
              title: Text('One-line with trailing widget'),
              subtitle: Text(
                  'Here is a second line aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
              trailing: Icon(Icons.keyboard_arrow_right),
              isThreeLine: true,
              onTap: () {
                final url = 'http://www.naver.com';
                _handleURLButtonPress(context, url);
                // do something
              },
            ),
          ),
        ]);
        */
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
