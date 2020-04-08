

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';

import '../common/config.dart';
import '../common/constants.dart';

class Ads with ChangeNotifier {

  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;

  void adInit() {

    Ads.facebookAdInit();
    switch (kAdConfig['type']) {
      case kAdType.googleBanner:

//      case kAdType.facebookBanner:
//        {
//          isFBBannerShown = true;
//          notifyListeners();
//          break;
//        }
//      case kAdType.facebookNative:
//        {
//          isFBNativeAdShown = true;
//          notifyListeners();
//          break;
//        }
//      case kAdType.facebookNativeBanner:
//        {
//          isFBNativeBannerAdShown = true;
//          notifyListeners();
//          break;
//        }
      case kAdType.facebookInterstitial:
        {
          Ads.showFacebookInterstitialAd();
          break;
        }
    }
  }


  static facebookAdInit() {
    FacebookAudienceNetwork.init(
      testingId: kAdConfig['hasdedIdTestingDevice'],
    );
  }













  static void showFacebookInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: kAdConfig['interstitialPlacementId'],
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          FacebookInterstitialAd.showInterstitialAd(delay: 5000);
        }
      },
    );
  }

  Widget facebookBanner() {
    return FacebookBannerAd(
      placementId: kAdConfig['bannerPlacementId'],
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {
        switch (result) {
          case BannerAdResult.ERROR:
            print("Error: $value");
            break;
          case BannerAdResult.LOADED:
            print("Loaded: $value");
            break;
          case BannerAdResult.CLICKED:
            print("Clicked: $value");
            break;
          case BannerAdResult.LOGGING_IMPRESSION:
            print("Logging Impression: $value");
            break;
        }
      },
    );
  }

  Widget facebookNative() {
    return FacebookNativeAd(
      placementId: kAdConfig['nativePlacementId'],
      adType: NativeAdType.NATIVE_AD,
      width: double.infinity,
      height: 300,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        print("Native Ad: $result --> $value");
      },
    );
  }

  Widget facebookBannerNative() {
    return FacebookNativeAd(
      placementId: kAdConfig["nativeBannerPlacementId"],
      adType: NativeAdType.NATIVE_BANNER_AD,
      bannerAdSize: NativeBannerAdSize.HEIGHT_100,
      width: double.infinity,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        print("Native Ad: $result --> $value");
      },
    );
  }
}
