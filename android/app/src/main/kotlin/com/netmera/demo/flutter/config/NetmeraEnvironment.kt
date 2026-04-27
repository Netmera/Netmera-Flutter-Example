///
/// Copyright (c) 2026 Netmera Research.
///

package com.netmera.demo.flutter.config

enum class NetmeraEnvironment(
    val key: String,
    val url: String,
    val defaultApiKey: String
) {
    TEST(
        "test",
        "https://sdk-cloud-test.sdpaas.com",
        "gFtyH_nz5WCdXraTsOOgL25er1sBpuQd2XKJi23QV17ebnzYFWCHb1x6Q7ILiK_bwlZ-FPtUSzU"
    ),
    PREPROD(
        "preprod",
        "https://sdk-cloud-uat.sdpaas.com",
        "gFtyH_nz5WCdXraTsOOgL25er1sBpuQdFa8bAMVGhv9Xo5voVRPFY2gFcVkuTQeZIgoa3gN1rww"
    ),
    PROD(
        "prod",
        "https://sdkapi.netmera.com",
        "gFtyH_nz5WCdXraTsOOgL25er1sBpuQdYkuURoDYBA5tcjTUZqlWw0M4LNxpP9V9rH0FOnONCGM"
    ),
    CUSTOM("custom", "", "");

    val displayName: String
        get() = when (this) {
            TEST -> "Test"
            PREPROD -> "Pre-prod"
            PROD -> "Prod"
            CUSTOM -> "Custom"
        }

    companion object {
        fun fromKey(key: String?): NetmeraEnvironment =
            entries.find { it.key == key } ?: PREPROD
    }
}

