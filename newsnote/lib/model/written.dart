import 'package:flutter/material.dart';

class Written {
  int id;
  String title;
  String url;
  String description;
  String image;
  int likes;

  Written(
      this.id, this.title, this.url, this.description, this.image, this.likes);
}

class WrittenTile extends StatelessWidget {
  final Written _written;
  WrittenTile(this._written);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_written.title),
      subtitle: Text(_written.description),
      trailing: Text(_written.url),
    );
  }
}
