import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:custom_splash/custom_splash.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:upgrader/upgrader.dart'; // upgrade version of app

import 'common/config.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'models/advertisement.dart';
import 'models/app.dart';
import 'models/blog.dart';
import 'models/cart.dart';
import 'models/category.dart';
import 'models/filter_attribute.dart';
import 'models/notification.dart';
import 'models/order.dart';
import 'models/payment_method.dart';
import 'models/product.dart';
import 'models/recent_product.dart';
import 'models/search.dart';
import 'models/shipping_method.dart';
import 'models/user.dart';
import 'models/wishlist.dart';
import 'route.dart';
import 'screens/login.dart';
import 'screens/onboard_screen.dart';
import 'services/index.dart';
import 'tabbar.dart';
import 'widgets/animated_splash.dart';
import 'widgets/dialogs.dart';
import 'widgets/firebase/firebase_analytics_wapper.dart';
import 'widgets/firebase/firebase_cloud_messaging_wapper.dart';
import 'widgets/firebase/one_signal_wapper.dart';
import 'widgets/internet_connectivity.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    printLog("[App] splash screen");

    if (kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: MyApp(),
        ),
      );
    }

    /// For Flare Image
    if (kSplashScreen.lastIndexOf('flr') > 0) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen.navigate(
          name: kSplashScreen,
          startAnimation: 'fruitplus',
          backgroundColor: Colors.white,
          next: (object) => MyApp(),
          until: () => Future.delayed(Duration(seconds: 2)),
        ),
      );
    }

    if (kSplashScreen.lastIndexOf('png') > 0) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplash(
          imagePath: kSplashScreen,
          home: MyApp(),
          duration: 2500,
          type: AnimatedSplashType.StaticDuration,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomSplash(
        imagePath: kLogoImage,
        backGroundColor: Colors.white,
        animationEffect: 'fade-in',
        logoSize: 50,
        home: MyApp(),
        duration: 2500,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<MyApp>
    with AfterLayoutMixin
    implements FirebaseCloudMessagingDelegate {
  final _app = AppModel();
  final _product = ProductModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _advertisementModel = Ads();
  final _order = OrderModel();
  final _search = SearchModel();
  final _recent = RecentModel();
  final _blog = BlogModel();
  final _user = UserModel();
  bool isFirstSeen = false;
  bool isChecking = true;
  bool isLoggedIn = false;

  FirebaseAnalyticsAbs firebaseAnalyticsAbs;

  @override
  void initState() {
    printLog("[AppState] initState");

    if (kIsWeb) {
      printLog("[AppState] init WEB");
      firebaseAnalyticsAbs = FirebaseAnalyticsWeb();
    } else {
      firebaseAnalyticsAbs = FirebaseAnalyticsWapper()..init();

      Future.delayed(
        Duration(seconds: 1),
        () {
          printLog("[AppState] init mobile modules ..");

          MyConnectivity.instance.initialise();
          MyConnectivity.instance.myStream.listen((onData) {
            printLog("[App] internet issue change: $onData");

            if (MyConnectivity.instance.isIssue(onData)) {
              if (MyConnectivity.instance.isShow == false) {
                MyConnectivity.instance.isShow = true;
                showDialogNotInternet(context).then((onValue) {
                  MyConnectivity.instance.isShow = false;
                  printLog("[showDialogNotInternet] dialog closed $onValue");
                });
              }
            } else {
              if (MyConnectivity.instance.isShow == true) {
                Navigator.of(context).pop();
                MyConnectivity.instance.isShow = false;
              }
            }
          });

          FirebaseCloudMessagagingWapper()
            ..init()
            ..delegate = this;

          OneSignalWapper()..init();
          printLog("[AppState] register modules .. DONE");
        },
      );
    }
    super.initState();
  }

  _saveMessage(message) {
    FStoreNotification a = FStoreNotification.fromJsonFirebase(message);
    a.saveToLocal(
      message['notification'] != null
          ? message['notification']['tag']
          : message['data']['google.message_id'],
    );
  }

  @override
  onLaunch(Map<String, dynamic> message) {
    _saveMessage(message);
  }

  @override
  onMessage(Map<String, dynamic> message) {
    _saveMessage(message);
  }

  @override
  onResume(Map<String, dynamic> message) {
    _saveMessage(message);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    printLog("[AppState] afterFirstLayout");

    Services().setAppConfig(serverConfig);
    //WordPress().setAppConfig(serverConfig);
    await _app.loadAppConfig();

    isFirstSeen = await checkFirstSeen();
    isLoggedIn = await checkLogin();
    setState(() {
      isChecking = false;
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      return false;
    } else {
      await prefs.setBool('seen', true);
      return true;
    }
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  Widget renderFirstScreen() {
    if (isFirstSeen && !kIsWeb) return OnBoardScreen();
    if (kAdvanceConfig['IsRequiredLogin'] && !isLoggedIn) return LoginScreen();
    return MainTabs();
  }

  void checkNewVersion() {
//    Enable this code for checking the version, require to install the upgrader library
//    final cfg = AppcastConfiguration(
//      url: upgradeURL,
//      supportedOS: ['android'],
//    ); // edit it to apply for ios
//
//    if (isChecking) {
//      //check version of app
//      return MaterialApp(
//        debugShowCheckedModeBanner: true,
//        home: Scaffold(
//          body: Center(
//            child: Center(
//              child: Container(
//                  margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
//                  child: UpgradeCard(appcastConfig: cfg)),
//            ),
//          ),
//        ),
//      );
//    }
  }

  @override
  Widget build(BuildContext context) {
    printLog("[AppState] build");
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    kLayoutWeb = kIsWeb || isTablet;

    checkNewVersion();

    return ChangeNotifierProvider<AppModel>.value(
      value: _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Container(
              color: Colors.white,
            );
          }
          return MultiProvider(
            providers: [
              Provider<ProductModel>.value(value: _product),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<ShippingMethodModel>.value(value: _shippingMethod),
              Provider<PaymentMethodModel>.value(value: _paymentMethod),
              Provider<OrderModel>.value(value: _order),
              Provider<SearchModel>.value(value: _search),
              Provider<RecentModel>.value(value: _recent),
              Provider<UserModel>.value(value: _user),
              ChangeNotifierProvider(create: (_) => CartModel()),
              ChangeNotifierProvider(create: (_) => CategoryModel()),
              ChangeNotifierProvider(create: (_) => FilterAttributeModel()),
              ChangeNotifierProvider(create: (_) => _blog),
              ChangeNotifierProvider(create: (_) => _advertisementModel),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(Provider.of<AppModel>(context).locale, ""),
              navigatorObservers: [
                MyRouteObserver(),
                ...firebaseAnalyticsAbs.getMNavigatorObservers()
              ],
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,

              ],
              supportedLocales: S.delegate.supportedLocales,

              home: Scaffold(body: renderFirstScreen()),
              routes: kRouteApp,
              theme: Provider.of<AppModel>(context).darkTheme
                  ? buildDarkTheme(Provider.of<AppModel>(context).locale)
                      .copyWith(
                      primaryColor: HexColor(
                        _app.appConfig["Setting"]["MainColor"],
                      ),
                    )
                  : buildLightTheme(Provider.of<AppModel>(context).locale)
                      .copyWith(
                      primaryColor: HexColor(
                        _app.appConfig["Setting"]["MainColor"],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
