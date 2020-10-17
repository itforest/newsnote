import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        height: 50,
        child: TabBar(
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          //onTap: _onItemTappedForTabBar,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.home,
                size: 18,
              ),
              child: Text(
                '홈',
                style: TextStyle(fontSize: 9),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.format_align_justify,
                size: 18,
              ),
              child: Text(
                '피드',
                style: TextStyle(fontSize: 9),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.bookmark_border,
                size: 18,
              ),
              child: Text(
                '저장한 콘텐츠',
                style: TextStyle(fontSize: 9),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.list,
                size: 18,
              ),
              child: Text(
                '더보기',
                style: TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
