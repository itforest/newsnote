import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebViewContainer extends StatefulWidget {
  final url;
  int id;
  String uuid;
  WebViewContainer(this.url, this.id, this.uuid);
  @override
  createState() => _WebViewContainerState(this.url, this.id, this.uuid);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  var _id;
  var _uuid;
  bool pressed = false;
  final _key = UniqueKey();
  _WebViewContainerState(this._url, this._id, this._uuid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(children: [
          Text('BOOK MARK',
              style: TextStyle(fontSize: 15, color: Colors.black54)),
          IconButton(
            icon: Padding(
                padding: EdgeInsets.all(0),
                child: pressed == true
                    ? Icon(Icons.favorite_border, color: Colors.grey)
                    : Icon(Icons.favorite, color: Colors.grey)),
            onPressed: () => setState(() {
              pressed = !pressed;
              _likeIncrements(this._uuid, this._id);
            }),
          )
        ])),
        body: Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('여기다 광고를 붙여볼까나'),
                ),
              ],

              //color: Colors.grey,
            ),
          ],
        ));
  }

  _likeIncrements(String uuid, int id) {
    print('[WEB_VIEW~.DART]_likeIncrements() START');
    Map<String, String> likeHeader = {
      "X-DEVICE-UUID": "${uuid}",
      "id": "${id}"
    };
    http
        .put('http://dofta11.synology.me:8888/api/v1/posts/1/like',
            headers: likeHeader)
        .then((response) {
      String jsonString = utf8.decode(response.bodyBytes);
      Map<String, dynamic> resMap = jsonDecode(jsonString);
      if (response.statusCode == 200) {
        print(resMap["success"]);
        print(resMap["message"]);
      } else {
        print(
            '_likeIncrements() UUID :  ${uuid}, ID : ${id} , statusCode : ${response.statusCode} Error!');
      }
    });
    print('[WEB_VIEW~.DART]_likeIncrements() END');
  }
}
