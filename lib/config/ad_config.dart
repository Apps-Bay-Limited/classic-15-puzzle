import 'package:flutter/services.dart';

class AdConfig {
  static const MethodChannel _channel = MethodChannel('com.appsbay.classic_15_puzzle/ad_config');

  static Future<String?> get bannerAdUnitId async {
    try {
      final String? id = await _channel.invokeMethod('getAdBannerUnitId');
      return id;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> get openAdUnitId async {
    try {
      final String? id = await _channel.invokeMethod('getAdOpenUnitId');
      return id;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> get interstitialAdUnitId async {
    try {
      final String? id = await _channel.invokeMethod('getAdInterstitialUnitId');
      return id;
    } catch (e) {
      return null;
    }
  }
}
