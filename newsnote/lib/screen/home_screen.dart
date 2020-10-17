import 'package:flutter/material.dart';
import 'package:newsnote/model/written.dart';
import 'package:newsnote/widget/web_view_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  String uuid;
  HomeScreen(this.uuid);
  _HomeScreenState createState() => _HomeScreenState(this.uuid);
}

class _HomeScreenState extends State<HomeScreen> {
  String _uuid;
  bool isDisposed = false;
  int _page = 1;
  _HomeScreenState(this._uuid);
  List _data = [];
  Map<String, String> postsHeader = {"X-DEVICE-UUID": ""};
  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  _fetchlikeWrittenList() async {
    print('_fetchWrittenList START');
    postsHeader['X-DEVICE-UUID'] = _uuid;
    print('postHeader : $_uuid , page : $_page');

    http
        .get(
            'http://dofta11.synology.me:8888/api/v1/posts?page=$_page&category=top10',
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
            written["like_yn"],
            written["created_at"],
          );
          if (!isDisposed) {
            setState(() {
              _data.add(writtenToAdd);
            });
          }
        }
        print(jsonString);
      } else {
        print('_fetchData() ERROR!! RESPONSE CODE : [${response.statusCode}]');
      }
      print('_fetchWrittenList END');
    });
  }

  @override
  void initState() {
    _fetchlikeWrittenList();
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
                    child: Text('인기글 Top 10',
                        style: TextStyle(fontSize: 25.0, color: Colors.black))),
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
          if (written.description == null) {
            written.description = '';
          }

          return Card(
            child: ListTile(
              onTap: () {
                final url = written.url;
                _handleURLButtonPress(
                    context, url, written.id, _uuid, written.like_yn);
              },
              title: Text(
                //'${written.id}. ${written.title}',
                '${index + 1}. ${written.title}',
                style: TextStyle(height: 1.1, fontSize: 17.5),
              ),
              subtitle: Text(
                '${written.description}',
                style: TextStyle(height: 1.3, fontSize: 12),
              ),
              trailing: Image.network('${imageurl}', width: 100, height: 100),
              isThreeLine: true,
            ),
          );
        }
      },
      separatorBuilder: (context, index) {
        if (index > 0) {
          index = index - 1;
          Written written = _data[index];
          return Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${written.created_at}', style: TextStyle(fontSize: 10)),
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
      BuildContext context, String url, int id, String uuid, bool like_yn) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewContainer(url, id, uuid, like_yn)));
  }
}
