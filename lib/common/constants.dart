import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_bus/event_bus.dart';

const kAppConfig = 'lib/config/config_en.json';

const kDefaultImage =
    "https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg";
const kLogoImage = 'assets/images/logo.png';

const kProfileBackground =
    "https://fruitplus.ae/wp-content/uploads/2020/03/set-large.jpg";

const welcomeGift =
    '#';

//const kSplashScreen = "assets/images/splashscreen.flr";
const kSplashScreen = "assets/images/splashscreen.png";

///Google fonts: https://fonts.google.com/
TextTheme kTextTheme(theme, String language) {
  switch (language) {
    case 'vi':
      return GoogleFonts.montserratTextTheme(theme);
    case 'ar':
      return GoogleFonts.ralewayTextTheme(theme);
    default:
      return GoogleFonts.ralewayTextTheme(theme);
  }
}

TextTheme kHeadlineTheme(theme, [language = 'en']) {
  switch (language) {
    case 'vi':
      return GoogleFonts.montserratTextTheme(theme);
    case 'ar':
      return GoogleFonts.ralewayTextTheme(theme);
    default:
      return GoogleFonts.ralewayTextTheme(theme);
  }
}

const debugNetworkProxy = false;

enum kCategoriesLayout {
  card,
  sideMenu,
  column,
  subCategories,
  animation,
  grid
}

const kEmptyColor = 0XFFF2F2F2;

const kColorNameToHex = {
  "red": "#ec3636",
  "black": "#000000",
  "white": "#ffffff",
  "green": "#36ec58",
  "grey": "#919191",
  "yellow": "#f6e46a",
  "blue": "#3b35f3"
};

/// Filter value
const kSliderActiveColor = 0xFF2c3e50;
const kSliderInactiveColor = 0x992c3e50;
const kMaxPriceFilter = 1000.0;
const kFilterDivision = 10;

const kOrderStatusColor = {
  "processing": "#bcd5bc",
  "refunded": "#e5e5e5",
  "cancelled": "#e5e5e5",
  "completed": "#b9c5ce",
  "failed": "#eba4a4",
  "pendding": "#e5e5e5",
  "on-hold": "#f7deaa"
};

const kLocalKey = {
  "userInfo": "userInfo",
  "shippingAddress": "shippingAddress",
  "recentSearches": "recentSearches",
  "wishlist": "wishlist",
  "home": "home",
  "cart": "cart"
};

const kGridIconsCategories = [
  {"name": "home"},
  {"name": "about"},
  {"name": "add2"},
  {"name": "addressBook"},
  {"name": "advertising"},
  {"name": "airplay"},
  {"name": "alarmClock"},
  {"name": "alarmoff"},
  {"name": "album"},
  {"name": "archive2"},
  {"name": "automotive"},
  {"name": "biohazard"},
  {"name": "bookmark2"}
];

Widget kLoadingWidget(context) => Center(
      child: SpinKitFadingCube(
        color: Theme.of(context).primaryColor,
        size: 30.0,
      ),
    );

enum kBlogLayout {
  simpleType,
  fullSizeImageType,
  halfSizeImageType,
  oneQuarterImageType
}

const kProductListLayout = [
  {"layout": "list", "image": "assets/icons/tabs/icon-list.png"},
  {"layout": "columns", "image": "assets/icons/tabs/icon-columns.png"},
  {"layout": "card", "image": "assets/icons/tabs/icon-card.png"},
  {"layout": "horizontal", "image": "assets/icons/tabs/icon-horizon.png"}
];

enum kAdType {
  googleBanner,
  googleInterstitial,
  googleReward,
  facebookBanner,
  facebookInterstitial,
  facebookNative,
  facebookNativeBanner,
}

const kLOG_TAG = "[Fluxstore]";
const kLOG_ENABLE = true;

printLog(dynamic data) {
  if (kLOG_ENABLE) {
    print("$kLOG_TAG${data.toString()}");
  }
}

// check if the environment is web
const bool kIsWeb = identical(0, 0.0);

// use eventbus for fluxbuilder
EventBus eventBus = EventBus();

class ImageConstants{
  static const String logo = 'assets/images/logo.png';
}