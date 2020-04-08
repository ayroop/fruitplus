import 'package:flutter/material.dart';

import 'tabbar.dart';
import 'screens/blogs.dart';
import 'screens/categories/index.dart';
import 'screens/checkout/index.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/notification.dart';
import 'screens/orders.dart';
import 'screens/products.dart';
import 'screens/registration.dart';
import 'screens/search/search.dart';
import 'screens/settings.dart';
import 'screens/wishlist.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class RouteAwareWidget extends StatefulWidget {
  final String name;
  final Widget child;

  RouteAwareWidget(this.name, {@required this.child});

  @override
  State<RouteAwareWidget> createState() => RouteAwareWidgetState();
}

class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  // Called when the current route has been pushed.
  void didPush() {
    print('didPush ${widget.name}');
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    print('didPopNext ${widget.name}');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    var screenName = route.settings.name;
    print('screenName $screenName');
    // do something with it, ie. send it to your analytics service collector
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}

var kRouteApp = <String, WidgetBuilder>{
  "/home-screen": (context) => HomeScreen(),
  "/home":        (context) => MainTabs(),
  "/login":       (context) => LoginScreen(),
  "/register":    (context) => RegistrationScreen(),
  '/products':    (context) => ProductsPage(),
  '/wishlist':    (context) => WishList(),
  '/checkout':    (context) => Checkout(),
  '/orders':      (context) => MyOrders(),
  '/blogs':       (context) => BlogScreen(),
  '/notify':      (context) => Notifications(),
  '/category':    (context) => CategoriesScreen(),
  '/search':      (context) => SearchScreen(),
  '/setting':     (context) => SettingScreen()
};
