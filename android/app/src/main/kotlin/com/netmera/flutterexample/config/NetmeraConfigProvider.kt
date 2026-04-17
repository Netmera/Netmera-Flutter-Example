///
/// Copyright (c) 2026 Netmera Research.
///

package com.netmera.flutterexample.config

import android.content.Context
import android.content.SharedPreferences

object NetmeraConfigProvider {

    private const val PREFS_NAME = "Preferences"
    private const val KEY_ENVIRONMENT = "environment"
    private const val KEY_BASE_URL = "baseUrl"
    private const val KEY_API_KEY = "apiKey"

    fun configFromPreferences(context: Context): Pair<String, String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val envKey = prefs.getString(KEY_ENVIRONMENT, NetmeraEnvironment.PROD.key)
        val env = NetmeraEnvironment.fromKey(envKey)

        return if (env == NetmeraEnvironment.CUSTOM) {
            Pair(
                prefs.getString(KEY_API_KEY, NetmeraEnvironment.PROD.defaultApiKey) ?: NetmeraEnvironment.PROD.defaultApiKey,
                prefs.getString(KEY_BASE_URL, NetmeraEnvironment.PROD.url) ?: NetmeraEnvironment.PROD.url
            )
        } else {
            Pair(env.defaultApiKey, env.url)
        }
    }

    fun getPreferences(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun saveConfig(prefs: SharedPreferences, environment: NetmeraEnvironment, baseUrl: String, apiKey: String) {
        prefs.edit()
            .putString(KEY_ENVIRONMENT, environment.key)
            .putString(KEY_BASE_URL, baseUrl)
            .putString(KEY_API_KEY, apiKey)
            .apply()
    }
}
