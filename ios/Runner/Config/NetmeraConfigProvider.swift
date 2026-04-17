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
}
