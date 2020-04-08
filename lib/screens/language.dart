import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/app.dart';

class Language extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final GlobalKey<ScaffoldState> _scaffordKey = GlobalKey<ScaffoldState>();

  void _showLoading(String language) {
    final snackBar = SnackBar(
      content: Text(
        S.of(context).languageSuccess,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
        label: language,
        onPressed: () {
          print('press OK');
        },
      ),
    );
    _scaffordKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffordKey,
      appBar: AppBar(
        title: Text(
          S.of(context).language,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/gb.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).english),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('en', context);
                _showLoading('English');
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/vn.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).vietnamese),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('vi', context);
                _showLoading('Vietnam');
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/ja.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).japanese),
              onTap: () async {
                await Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('ja', context);
                _showLoading('Japanese');
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/zh.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).chinese),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('Chinese', context);
                _showLoading('Chinese');
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/es.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).spanish),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('es', context);
                _showLoading('Spanish');
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/ar.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).arabic),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('ar', context);
                _showLoading('Arabic');
              },
            ),
          ),
        ],
      ),
    );
  }
}
