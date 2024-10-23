///
/// Copyright (c) 2022 Inomera Research.
///

package com.netmera.flutterexample

import android.content.Context
import android.content.SharedPreferences
import com.netmera.netmera_flutter_sdk.FNetmera
import com.netmera.netmera_flutter_sdk.FNetmeraConfiguration
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {
    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate() {
        super.onCreate()

        sharedPreferences = applicationContext.getSharedPreferences("Preferences", Context.MODE_PRIVATE)

        //Netmera Configuration
        val fNetmeraConfiguration = FNetmeraConfiguration.Builder()
            .huaweiSenderId(BuildConfig.HMS_SENDER_ID) // Your HMS sender ID
            .firebaseSenderId(BuildConfig.GCM_SENDER_ID) // Your GCM sender ID
            .apiKey(sharedPreferences.getString("apiKey", BuildConfig.NETMERA_UAT_API_KEY)) // Your Netmera api key
            .baseUrl(sharedPreferences.getString("baseUrl", BuildConfig.NETMERA_UAT_BASE_URL)) // Netmera base url
            .logging(true) // This is for enabling Netmera logs.
            .build(this)

        FNetmera.initNetmera(fNetmeraConfiguration)
    }
}
