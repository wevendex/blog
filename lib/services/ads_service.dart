import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  Future<InitializationStatus> initialize() async {
    // NOTE: Replace with your AdMob app id in AndroidManifest & Info.plist.
    return MobileAds.instance.initialize();
  }

  BannerAd? _bannerAd;

  BannerAd getBannerAd() {
    _bannerAd ??= BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerUnitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: ${error.message}');
        },
      ),
      request: const AdRequest(),
    )..load();
    return _bannerAd!;
  }

  String get _bannerUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111'; // Test id
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    throw UnsupportedError('Unsupported platform');
  }
}