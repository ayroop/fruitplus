import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel with ChangeNotifier {
  UserModel() {
    getUser();
  }

  Services _service = Services();
  User user;
  bool loggedIn = false;
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();

  void updateUser(Map<String, dynamic> json) {
    user.name = json['display_name'];
    user.email = json['user_email'];
    user.password = json['password'];
    user.userUrl = json['user_url'];
    user.nicename = json['user_nicename'];
    notifyListeners();
  }

  /// Login by apple
  Future<void> loginApple({Function success, Function fail}) async {
    try {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            final userId = result.credential.user.replaceAll(".", "");
            if (result.credential.email != null) {
              final fullName = result.credential.fullName.givenName +
                  " " +
                  result.credential.fullName.familyName;
              user = await _service.loginApple(
                  email: result.credential.email, fullName: fullName);
              await _database.child(userId).set(
                  {"email": result.credential.email, "fullName": fullName});
            } else {
              DataSnapshot snapshot = await _database.child(userId).once();
              Map item = snapshot.value;
              user = await _service.loginApple(
                  email: item["email"], fullName: item["fullName"]);
            }
            loggedIn = true;
            await saveUser(user);
            success(user);

            notifyListeners();
          }
          break;

        case AuthorizationStatus.error:
        case AuthorizationStatus.cancelled:
          fail(result.error.toString());
      }
    } catch (err) {
      fail("Error");
    }
  }

  /// Login by Firebase phone
  Future<void> loginFirebaseSMS({
    String phoneNumber,
    Function success,
    Function fail,
  }) async {
    try {
      user = await _service.loginSMS(token: phoneNumber);
      loggedIn = true;
      await saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail();
    }
  }

  /// Login by Facebook
  Future<void> loginFB({Function success, Function fail}) async {
    try {
      final FacebookLoginResult result =
          await FacebookLogin().logIn(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: accessToken.token);
          await _auth.signInWithCredential(credential);
          user = await _service.loginFacebook(token: accessToken.token);

          loggedIn = true;

          await saveUser(user);

          success(user);
          break;
        case FacebookLoginStatus.cancelledByUser:
          fail('The login is cancel');
          break;
        case FacebookLoginStatus.error:
          fail('Error: ${result.errorMessage}');
          break;
      }

      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  Future<void> loginGoogle({Function success, Function fail}) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      GoogleSignInAccount res = await _googleSignIn.signIn();
      GoogleSignInAuthentication auth = await res.authentication;
      user = await _service.loginGoogle(token: auth.accessToken);
      loggedIn = true;
      await saveUser(user);
      success(user);
      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  Future<void> saveUser(User user) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      // save to Preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);

      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["userInfo"], user);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getUser() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        if (json != null) {
          user = User.fromLocalJson(json);
          loggedIn = true;
          notifyListeners();
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> createUser({
    username,
    password,
    firstName,
    lastName,
    Function success,
    Function fail,
  }) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
      );
      loggedIn = true;
      await saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      fail(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    loggedIn = false;
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["userInfo"]);
        await storage.deleteItem(kLocalKey["shippingAddress"]);
        await storage.deleteItem(kLocalKey["recentSearches"]);
        await storage.deleteItem(kLocalKey["wishlist"]);
        await storage.deleteItem(kLocalKey["opencart_cookie"]);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', false);
      }
    } catch (err) {
      print(err);
    }
    notifyListeners();
  }

  Future<void> login({username, password, Function success, Function fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.login(
        username: username,
        password: password,
      );

      loggedIn = true;
      await saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail(err.toString());
//      print('login err $err');
      notifyListeners();
    }
  }

  Future<bool> isLogin() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        return json != null;
      }
      return false;
    } catch (err) {
      return false;
    }
  }
}

class User {
  int id;
  bool loggedIn;
  String name;
  String firstName;
  String lastName;
  String username;
  String email;
  String password;
  String nicename;
  String userUrl;
  String picture;
  String cookie;
  Shipping shipping;
  Billing billing;

  User.fromWoJson(Map<String, dynamic> json) {
    print(json);
    try {
      id = json['id'];
      username = json['username'];
      firstName = json['first_name'];
      lastName = json['last_name'];
      email = json['email'];
      shipping = Shipping.fromJson(json['shipping']);
      billing = Billing.fromJson(json['billing']);
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonFB(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = user['name'];
      username = user['user_login'];
      cookie = json['cookie'];
      firstName = user["first_name"];
      lastName = user["last_name"];
      email = user["email"];
      picture = user["picture"]['data']['url'] ?? '';
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonSMS(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'];
      name = json['user_login'];
      cookie = json['cookie'];
      username = user['id'];
      firstName = json['user_login'];
      lastName = '';
      email = user['email'] ?? user['id'];
    } catch (e) {
      print(e.toString());
    }
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "loggedIn": loggedIn,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "password": password,
      "picture": picture,
      "cookie": cookie,
      "nicename": nicename,
      "url": userUrl
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'];
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      password = json['password'];
      picture = json['picture'];
      nicename = json['nicename'];
      userUrl = json['url'];
    } catch (e) {
      print(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String _cookie) {
    try {
      cookie = _cookie;
      id = json['id'];
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      password = json['password'];
      picture = json['avatar'];
      nicename = json['nicename'];
      userUrl = json['url'];
      loggedIn = true;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'User { username: $id $name $email}';
}

class UserPoints {
  int points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];
    for (var event in json['events']) {
      events.add(UserEvent.fromJson(event));
    }
  }
}

class UserEvent {
  String id;
  String userId;
  String orderId;
  String date;
  String description;
  String points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}

class Billing {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;
  String email;
  String phone;

  Billing.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
      email = json['email'];
      phone = json['phone'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Shipping {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postCode;
  String country;
  String state;

  Shipping.fromJson(Map<String, dynamic> json) {
    try {
      firstName = json['first_name'];
      lastName = json['last_name'];
      company = json['company'];
      address1 = json['address_1'];
      address2 = json['address_2'];
      city = json['city'];
      postCode = json['postcode'];
      country = json['country'];
      state = json['state'];
    } catch (e) {
      print(e.toString());
    }
  }
}
