///
/// Copyright (c) 2022 Inomera Research.
///

package com.netmera.flutterexample

import com.netmera.netmera_flutter_sdk.FNetmera
import com.netmera.netmera_flutter_sdk.FNetmeraConfiguration
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()

        //Netmera Configuration
        val fNetmeraConfiguration = FNetmeraConfiguration.Builder()
            .huaweiSenderId(BuildConfig.HMS_SENDER_ID) // Your HMS sender ID
            .firebaseSenderId(BuildConfig.GCM_SENDER_ID) // Your GCM sender ID
            .apiKey(BuildConfig.NETMERA_API_KEY) // Your Netmera api key
            .logging(true) // This is for enabling Netmera logs.
            .build(this)
        FNetmera.initNetmera(fNetmeraConfiguration)
    }
}
