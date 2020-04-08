import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class StaticSite extends StatefulWidget {
  final String data;
  StaticSite({this.data});

  @override
  _StateStaticSite createState() => _StateStaticSite();
}

class _StateStaticSite extends State<StaticSite> {
  String document;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/html/${widget.data}.html').then((value) => setState((){
      document = value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (document == null) return Text('Loading');
    return Scaffold(
      body: WebView(
        onWebViewCreated: (controller) async {
          final String contentBase64 = base64Encode(const Utf8Encoder().convert(document));
          await controller.loadUrl('data:text/html;base64,$contentBase64');
        },
      ),
    );
  }
}
