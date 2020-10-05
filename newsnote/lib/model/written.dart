import 'package:flutter/material.dart';

class Written {
  String title;
  String url;
  String description;

  Written(this.title, this.url, this.description);
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
