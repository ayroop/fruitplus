import 'package:flutter/material.dart';

class CustomPageScreen extends StatefulWidget {
  final String url;
  final String title;
  final String background;

  CustomPageScreen({this.url, this.background, this.title});

  @override
  State<StatefulWidget> createState() {
    return CustomPageScreenState();
  }
}

class CustomPageScreenState extends State<CustomPageScreen> {
//  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {

    return Container();
  }
}
