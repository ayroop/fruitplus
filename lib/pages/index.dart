import 'package:flutter/material.dart';
import 'page1.dart';
import 'page2.dart';

class StaticPage extends StatefulWidget {
  final type;
  final data;
  StaticPage({this.type, this.data});

  @override
  _StateStaticPage createState() => _StateStaticPage();
}

class _StateStaticPage extends State<StaticPage> {

  Widget _renderLayout() {
    var data = widget.data ?? {};
    switch(widget.type) {
      case 'page1':
        return Page1(
          data: data,
        );
      case 'page2':
        return Page2(
          data: data,
        );
      default:
        return Page1(
          data: data,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _renderLayout(),
    );
  }
}