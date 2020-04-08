import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/user.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String firstName, lastName, username, password;
  final TextEditingController _usernameController = TextEditingController();
  bool isChecked = false;

  void _welcomeDiaLog(User user) {
    var email = user.email;
    _snackBar('Welcome $email!');
    Navigator.of(context).pop();
  }

  void _failMess(message) {
    _snackBar(message);
  }

  void _snackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    _submitRegister(firstName, lastName, username, password) {
      if (firstName == null ||
          lastName == null ||
          username == null ||
          password == null) {
        _snackBar('Please input fill in all fields');
      } else if (isChecked == false) {
        _snackBar('Please agree with our terms');
      } else {
        Provider.of<UserModel>(context, listen: false).createUser(
          username: username,
          password: password,
          firstName: firstName,
          lastName: lastName,
          success: _welcomeDiaLog,
          fail: _failMess,
        );
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushNamed('/home');
            }
          },
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: InkWell(
          onTap: () => Utils.hideKeyboard(context),
          child: ListenableProvider.value(
            value: Provider.of<UserModel>(context),
            child: Consumer<UserModel>(
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 70.0,
                        ),
                        Container(
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: MediaQuery.of(context).size.width / 2,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextField(
                          onChanged: (value) => firstName = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).firstName,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextField(
                          onChanged: (value) => lastName = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).lastName,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextField(
                          controller: _usernameController,
                          onChanged: (value) => username = value,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: S.of(context).enterYourEmail),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextField(
                          obscureText: true,
                          onChanged: (value) => password = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).enterYourPassword,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                //print(value);
                                isChecked = !isChecked;
                                setState(() {});
                              },
                            ),
                            Text(
                              S.of(context).iwantToCreateAccount,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                //print(value);
                                isChecked = !isChecked;
                                setState(() {});
                              },
                            ),

                            SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PrivacyScreen()),
                                );
                              },
                              child: Text(
                                S.of(context).agreeWithPrivacy,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            elevation: 0,
                            child: MaterialButton(
                              onPressed: () async {
                                try {
                                  await _auth.createUserWithEmailAndPassword(
                                      email: username, password: password);
                                } catch (e) {
                                  printLog("[Resistration] ${e.toString()}");
                                }
                                _submitRegister(
                                    firstName, lastName, username, password);
                              },
                              minWidth: 200.0,
                              elevation: 0.0,
                              height: 42.0,
                              child: Text(
                                value.loading == true
                                    ? S.of(context).loading
                                    : S.of(context).createAnAccount,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).or + ' ',
                                style: TextStyle(color: Colors.black45),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  S.of(context).loginToYourAccount,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).agreeWithPrivacy,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('''
              FruitPlus is the first private agricultural processor in Dubai that aims to improve, 
    improve and optimize all components of the agricultural supply chain. 
    The most advanced method of managing agricultural supply chains in the world today is Contract Farming, 
    which ensures maximum elimination of intermediaries, enhancing farmers
    ' livelihoods, direct supply of "from home to home" agricultural products and 
    strict application of health and quality standards. On food production.
     Therefore, FruitPlus considers its main concern to promote this method in Dubai 
     and by the end of 2019, it will provide users with at least 25% of all products 
     offered in its online store in a conventional agricultural manner.
   ''',
              style: TextStyle(fontSize: 16.0, height: 1.4),
              textAlign: TextAlign.justify),
        ),
      ),
    );
  }
}
