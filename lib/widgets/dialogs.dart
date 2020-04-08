import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showDialogNotInternet(BuildContext context) {
  return showDialog(
    context: context,
    child: CupertinoAlertDialog(
      title: Center(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.warning,
            ),
            Text("  Internet issue"),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          "Please checking internet connection!"
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            AppSettings.openWIFISettings();
          },
          child: Text("Setting")
        )
      ],
    )
  );
}