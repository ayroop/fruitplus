import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../common/constants.dart';

/// Server config
const serverConfig = {
  "type": "woo",
  "url": "https://fruitplus.ae",
  "consumerKey": "ck_63417d4deae61d772fa80438d505542ad451cd4b",
  "consumerSecret": "cs_159dbfaac2423bc332a10258a8048f22c27d4ca1",
  "forgetPassword": "https://fruitplus.ae/my-account/lost-password/"
};
const afterShip = {
  "api": "ck_1866a49a592b78eed2925e0cdabdf2da",
  "tracking_url": "https://fruitplus.aftership.com"
};

const Payments = {
  "paypal": "assets/icons/payment/paypal.png",
  "stripe": "assets/icons/payment/stripe.png",
  "razorpay": "assets/icons/payment/razorpay.png",
};

/// The product variant config
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "height": "option",
};

/// This option is determine hide some components for web
var kLayoutWeb = true;

const kAdvanceConfig = {
  "DefaultLanguage": "en",
  "DefaultCurrency": {
    "symbol": "\ Dhs",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": false,
    "currency": "AED"
  },
  "IsRequiredLogin": false,
  "GuestCheckout": false,
  "EnableShipping": true,
  "EnableAddress": true,
  "EnableReview": true,
  "GridCount": 3,
  "DetailedBlogLayout": kBlogLayout.halfSizeImageType,
  "EnablePointReward": true,
  "DefaultPhoneISOCode": "+97",
  "DefaultCountryISOCode": "AE",
  "EnableRating": true,
  "EnableSmartChat": false,
  "hideOutOfStock": true,
  'allowSearchingAddress': true,
  "isCaching": false,
  "OnBoardOnlyShowFirstTime": true,
  "EnableConfigurableProduct": false, //for magento
  "EnableAttributesConfigurableProduct": ["color", "size"], //for magento
  "EnableAttributesLabelConfigurableProduct": ["color", "size"], //for magento,
  "EnableAdvertisement": false,
  "Currencies": [
    {
      "symbol": "\$",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true,
      "currency": "USD"
    },
    {
      "symbol": "\ Dhs",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": false,
      "currency": "AED"
    }
  ],
  "MinFreeShippingCost": 200
};

/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  "android": "your-google-api-key",
  "ios": "your-google-api-key",
  "web": "your-google-api-key"
};

const kOneSignalKey = {
  'appID': "400b8bee-74c6-45dc-a7bf-287e5d410b62",
};

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
const kProductDetail = {
  "height": 0.5,
  "marginTop": 0,
  "isHero": false,
  "safeArea": false,
  "showVideo": false,
  "showThumbnailAtLeast": 3,
  "layout": "simpleType",
  "maxAllowQuantity": 100,  // the maximum quantity items user could purchase
};

/// config for the chat app
const smartChat = [
  {
    'app': 'whatsapp://send?phone=989128588126',
    'iconData': FontAwesomeIcons.whatsapp
  },
  {'app': 'tel:989128588126', 'iconData': FontAwesomeIcons.phone},
  {'app': 'sms://989128588126', 'iconData': FontAwesomeIcons.sms}
];
const String adminEmail = "admin@fruitplus.ae";


/// the welcome screen data
List onBoardingData = [
  {
    "title": "Welcome to Fruit Pluse",
    "image": "assets/images/fogg-delivery-1.png",
    //  "desc": "Fruitplus is on the way to serve you. "
  },

];

const PaypalConfig = {
  "clientId":
      "#",
  "secret":
      "#",
  "production": false,
  "paymentMethodId": "paypal",
  "enabled": false,
  "returnUrl": "http://return.example.com",
  "cancelUrl": "http://cancel.example.com",
};

const RazorpayConfig = {
  "keyId": "#",
  "paymentMethodId": "razorpay",
  "enabled": false
};

const TapConfig = {
  "SecretKey": "sk_test_XKokBfNWv6FIYuTMg5sLPjhJ",
  "RedirectUrl": "http://your_website.com/redirect_url",
  "paymentMethodId": "",
  "enabled": false
};

// Limit the country list from Billing Address
const List DefaultCountry = [
  {
    "name": "Dubai",
    "iosCode": "AE",
    "icon": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_the_United_Arab_Emirates.svg/800px-Flag_of_the_United_Arab_Emirates.svg.png"
  },

];
//const List DefaultCountry = [
//  {
//    "name": "India",
//    "iosCode": "IN",
//    "icon":
//        "https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/1200px-Flag_of_India.svg.png"
//  },
//  {"name": "Austria", "iosCode": "AT", "icon": ""},
//];

const kAdConfig = {
  "enable": false,
  "type": kAdType.facebookNative,
  /// ----------------- Facebook Ads  -------------- ///
  "hasdedIdTestingDevice": "#",
  "bannerPlacementId": "#",
  "interstitialPlacementId": "#",
  "nativePlacementId": "#",
  "nativeBannerPlacementId": "#",

  /// ------------------ Google Admob  -------------- ///
  "androidAppId": "#",
  "androidUnitBanner": "#",
  "androidUnitInterstitial": "#",
  "androidUnitReward": "#",
  "iosAppId": "#",
  "iosUnitBanner": "#",
  "iosUnitInterstitial": "#",
  "iosUnitReward": "#",
  "waitingTimeToDisplayInterstitial": 10,
  "waitingTimeToDisplayReward": 10,
};


/// user for upgrader version of app, remove the comment from lib/app.dart to enable this feature
/// https://tppr.me/5PLpD
const kUpgradeURLConfig = {
  "android" :"https://play.google.com/store/apps/details?id=com.ayrop.fruitplus",
  "ios" : "https://apps.apple.com/us/app/ayrop-flutter/id1469772800"
};

/// use for rate app on store feature
const kStoreIdentifier = {
  "android": ""
      "",
  "ios": ""
};
