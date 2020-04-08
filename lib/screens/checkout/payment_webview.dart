import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import '../../common/constants.dart';
import '../../common/config.dart';
import '../../common/styles.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PaymentWebview extends StatefulWidget {
  final Map<String, dynamic> params;
  final Function onFinish;

  PaymentWebview({this.params, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaymentWebviewState();
  }
}

class PaymentWebviewState extends State<PaymentWebview> {
  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("URL: " + url);
      if (url.contains("/checkout/order-received/")) {
        final items = url.split("/checkout/order-received/");
        if (items.length > 1) {
          final number = items[1].split("/")[0];
          widget.onFinish(number);
          Navigator.of(context).pop();
        }
      }
      if (url.contains("checkout/success")) {
        widget.onFinish("0");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var checkoutUrl = "";
    var str = convert.jsonEncode(widget.params);
    var bytes = convert.utf8.encode(str);
    var base64Str = convert.base64.encode(bytes);

    var headers = Map<String, String>();
    if (serverConfig["type"] == "woo") {
      //checkoutUrl = serverConfig['url'] + "/mstore-checkout/?order=$base64Str";
    }

    return WebviewScaffold(
      withJavascript: true,
      appCacheEnabled: true,
      url: serverConfig["type"] == "opencart"
          ? checkoutUrl
          : Uri.dataFromString(
              _loadHTML(serverConfig['url'] + "/mstore-checkout", base64Str),
              mimeType: 'text/html',
            ).toString(),
      headers: headers,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );
//    return Scaffold(
//      appBar: AppBar(
//        leading: IconButton(
//            icon: Icon(Icons.arrow_back),
//            onPressed: () {
//              Navigator.of(context).pop();
//            }),
//        backgroundColor: kGrey200,
//        elevation: 0.0,
//      ),
//      body: WebView(
//          javascriptMode: JavascriptMode.unrestricted,
//          initialUrl: checkoutUrl,
//          onPageFinished: (String url) {
//            if(url.contains("/checkout/order-received/")){
//              final items = url.split("/checkout/order-received/");
//              if(items.length > 1){
//                final number = items[1].split("/")[0];
//                onFinish(number);
//                Navigator.of(context).pop();
//              }
//            }
//          }),
//    );
  }

  String _loadHTML(url, params) {
    return r'''
      <html>
        <body onload="document.f.submit();">
          <form id="f" name="f" method="post" action='''
        "$url"
        '''>
            <input type="hidden" name="order" value="$params" />
          </form>
        </body>
      </html>
    ''';
  }
}
