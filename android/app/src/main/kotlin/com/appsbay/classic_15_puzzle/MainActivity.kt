package com.appsbay.classic_15_puzzle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.appsbay.classic_15_puzzle/ad_config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAdBannerUnitId" -> result.success(BuildConfig.AD_BANNER_UNIT_ID)
                "getAdOpenUnitId" -> result.success(BuildConfig.AD_OPEN_UNIT_ID)
                else -> result.notImplemented()
            }
        }
    }
}
