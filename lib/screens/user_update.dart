import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fstore/common/config.dart';
import 'package:provider/provider.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/user.dart';
import '../services/index.dart';

class UserUpdate extends StatefulWidget {
  @override
  _StateUserUpdate createState() => _StateUserUpdate();
}

class _StateUserUpdate extends State<UserUpdate> with AfterLayoutMixin {
  TextEditingController userEmail;
  TextEditingController userPassword;
  TextEditingController userDisplayName;
  TextEditingController userNiceName;
  TextEditingController userUrl;
  TextEditingController userPhone;
  TextEditingController currentPassword;

  String avatar;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    setState(() {
      userEmail = TextEditingController(text: user.email);
      userPassword = TextEditingController(text: user.password);
      currentPassword = TextEditingController(text: user.password);
      userDisplayName = TextEditingController(text: user.name);
      userNiceName = TextEditingController(text: user.nicename);
      userUrl = TextEditingController(text: user.userUrl);
      if (alphanumeric.hasMatch(user.firstName)) {
        userPhone = TextEditingController(text: user.firstName);
      }
      avatar = user.picture;
    });
  }

  void updateUserInfo() {
    final user = Provider.of<UserModel>(context, listen: false).user;
    setState(() {
      isLoading = true;
    });
    if (currentPassword.text.isEmpty && serverConfig["type"] == "magento") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Please enter current password')));
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (userPassword.text.isEmpty && serverConfig["type"] != "magento") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Please enter your password')));
      setState(() {
        isLoading = false;
      });
      return;
    }
    var params = {
      "user_id": user.id,
      "user_pass": userPassword.text,
      "display_name": userDisplayName.text,
      "user_email": userEmail.text,
      "user_nicename": userNiceName.text,
      "user_url": userUrl.text,
      "current_pass": currentPassword.text
    };
    if (userEmail.text == user.email && serverConfig["type"] == "magento") {
      params["user_email"] = "";
    }
    Services().updateUserInfo(params, user.cookie).then((value) {
      var param = value['data'] ?? value;
      param['password'] = userPassword.text;
      Provider.of<UserModel>(context, listen: false).updateUser(param);
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
//      _scaffoldKey.currentState.showSnackBar(
//          new SnackBar(content: new Text(S.of(context).enterYourPassword)));
    }).catchError((e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onTap: () {
          Utils.hideKeyboard(context);
        },
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(100, 10),
                        ),
                        boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 8)]),
                    child: avatar != null
                        ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                    )
                        : Container(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150), color: Theme.of(context).primaryColorLight),
                      child: avatar != null
                          ? Image.network(
                        avatar,
                        width: 150,
                        height: 150,
                      )
                          : Icon(
                        Icons.person,
                        size: 120,
                      ),
                    ),
                  ),
//                  Align(
//                    alignment: Alignment.bottomCenter,
//                    child: GestureDetector(
//                      onTap: () => Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => Scaffold(
//                            appBar: AppBar(),
//                            body: WebView(
//                              javascriptMode: JavascriptMode.unrestricted,
//                              initialUrl: 'https://en.gravatar.com/',
//                            ),
//                          ),
//                        ),
//                      ),
//                      child: Container(
//                        margin: EdgeInsets.only(left: 80),
//                        padding: const EdgeInsets.all(7),
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(100),
//                            color: Colors.grey.withOpacity(0.4)),
//                        child: Icon(
//                          Icons.mode_edit,
//                          size: 20,
//                        ),
//                      ),
//                    ),
//                  ),
                  SafeArea(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(S.of(context).displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                            child: TextField(
                              decoration: InputDecoration(border: InputBorder.none),
                              controller: userDisplayName,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(S.of(context).email,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                            child: TextField(
                              decoration: InputDecoration(border: InputBorder.none),
                              controller: userEmail,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(S.of(context).niceName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                            child: TextField(
                              decoration: InputDecoration(border: InputBorder.none),
                              controller: userNiceName,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text('Url',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                            child: TextField(
                              decoration: InputDecoration(border: InputBorder.none),
                              controller: userUrl,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          if (serverConfig["type"] == "magento")
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(border: InputBorder.none),
                                    controller: currentPassword,
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),

                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Theme.of(context).primaryColorLight, width: 1.5)),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(border: InputBorder.none),
                              controller: userPassword,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: updateUserInfo,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Container(
                                    height: 20,
                                    width: 100,
                                    child: isLoading
                                        ? SpinKitCircle(
                                      color: Colors.white,
                                      size: 20.0,
                                    )
                                        : Center(
                                      child: Text(
                                        S.of(context).update,
                                        style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
