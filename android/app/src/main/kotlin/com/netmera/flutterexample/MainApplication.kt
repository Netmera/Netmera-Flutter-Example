///
/// Copyright (c) 2026 Netmera Research.
///

package com.netmera.flutterexample

import android.app.Application
import com.netmera.flutterexample.config.NetmeraConfigProvider
import com.netmera.netmera_flutter_sdk.FNetmera
import com.netmera.netmera_flutter_sdk.FNetmeraConfiguration

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        val (apiKey, baseUrl) = NetmeraConfigProvider.configFromPreferences(this)

        val fNetmeraConfiguration = FNetmeraConfiguration.Builder()
            .huaweiSenderId(BuildConfig.HMS_SENDER_ID)
            .firebaseSenderId(BuildConfig.GCM_SENDER_ID)
            .apiKey(apiKey)
            .baseUrl(baseUrl)
            .logging(true)
            .build(this)

        FNetmera.initNetmera(fNetmeraConfiguration)
    }
}
