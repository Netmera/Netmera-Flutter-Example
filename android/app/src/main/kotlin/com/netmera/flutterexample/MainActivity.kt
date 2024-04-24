///
/// Copyright (c) 2022 Inomera Research.
///

package com.netmera.flutterexample

import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "nm_flutter_example_channel"
    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sharedPreferences = context.getSharedPreferences("Preferences", Context.MODE_PRIVATE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                Methods.SET_API_KEY.methodName -> {
                    val apiKey = call.argument<String>("apiKey")
                    setApiKey(apiKey)
                    result.success(null)
                }

                Methods.SET_BASE_URL.methodName -> {
                    val url = call.argument<String>("baseUrl")
                    setBaseUrl(url)
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun setApiKey(apiKey: String?) {
        val editor = sharedPreferences.edit()
        editor.putString("apiKey", apiKey)
        editor.apply()
    }

    private fun setBaseUrl(url: String?) {
        val editor = sharedPreferences.edit()
        editor.putString("baseUrl", url)
        editor.apply()
    }
}

private enum class Methods(val methodName: String) {
    SET_API_KEY("setApiKey"),
    SET_BASE_URL("setBaseUrl"),
}
