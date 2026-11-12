///
/// Copyright (c) 2026 Netmera Research.
///

import Foundation

enum NetmeraConfigProvider {

    static func registerSettingsBundleDefaults() {
        let settingsName = "Settings"
        let settingsExtension = "bundle"
        let settingsRootPlist = "Root.plist"
        let preferenceSpecifiers = "PreferenceSpecifiers"
        let keyKey = "Key"
        let defaultValueKey = "DefaultValue"
        guard let settingsURL = Bundle.main.url(forResource: settingsName, withExtension: settingsExtension),
              let data = try? Data(contentsOf: settingsURL.appendingPathComponent(settingsRootPlist)),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let prefs = plist[preferenceSpecifiers] as? [[String: Any]] else { return }
        var defaults: [String: Any] = [:]
        for pref in prefs {
            if let key = pref[keyKey] as? String {
                defaults[key] = pref[defaultValueKey]
            }
        }
        UserDefaults.standard.register(defaults: defaults)
    }

    static func configFromSettings() -> (apiKey: String, baseUrl: String) {
        #if DEBUG
        if let testBaseUrl = dartDefine("NETMERA_TEST_BASE_URL"), !testBaseUrl.isEmpty {
            return ("flutter-ui-test-api-key", testBaseUrl)
        }
        #endif
        let ud = UserDefaults.standard
        let envValue = ud.string(forKey: NetmeraSettingsKeys.environment)
        let environment = envValue.flatMap { NetmeraEnvironment(rawValue: $0) }
        let baseUrl: String
        let apiKey: String
        if environment == .custom {
            baseUrl = ud.string(forKey: NetmeraSettingsKeys.baseURL) ?? NetmeraEnvironment.prod.url
            apiKey = ud.string(forKey: NetmeraSettingsKeys.APIKey) ?? NetmeraEnvironment.prod.defaultApiKey
        } else if let env = environment, !env.url.isEmpty {
            baseUrl = env.url
            apiKey = env.defaultApiKey
        } else {
            baseUrl = ud.string(forKey: NetmeraSettingsKeys.baseURL) ?? NetmeraEnvironment.prod.url
            apiKey = ud.string(forKey: NetmeraSettingsKeys.APIKey) ?? NetmeraEnvironment.prod.defaultApiKey
        }
        return (apiKey, baseUrl)
    }

    /// Reads a `--dart-define` value; Flutter exposes them to Xcode as base64 encoded `KEY=value` pairs.
    private static func dartDefine(_ key: String) -> String? {
        guard let encoded = Bundle.main.object(forInfoDictionaryKey: "NetmeraDartDefines") as? String else { return nil }
        for entry in encoded.split(separator: ",") {
            guard let data = Data(base64Encoded: String(entry)),
                  let pair = String(data: data, encoding: .utf8) else { continue }
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2, parts[0] == key { return String(parts[1]) }
        }
        return nil
    }
}
