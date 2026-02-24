///
/// Copyright (c) 2026 Netmera Research.
///

import Foundation

enum NetmeraSettingsKeys {
    static let environment = "environment"
    static let baseURL = "baseURL"
    static let APIKey = "APIKey"
}

enum NetmeraEnvironment: String {
    case test
    case preprod
    case prod
    case custom

    var url: String {
        switch self {
        case .test: return "https://sdk-cloud-test.sdpaas.com"
        case .preprod: return "https://sdk-cloud-uat.sdpaas.com"
        case .prod: return "https://sdkapi.netmera.com"
        case .custom: return ""
        }
    }

    var defaultApiKey: String {
        switch self {
        case .test: return "gFtyH_nz5WCdXraTsOOgL25er1sBpuQd2XKJi23QV17ebnzYFWCHb1x6Q7ILiK_bwlZ-FPtUSzU"
        case .preprod: return "gFtyH_nz5WCdXraTsOOgL25er1sBpuQdFa8bAMVGhv9Xo5voVRPFY2gFcVkuTQeZIgoa3gN1rww"
        case .prod: return "gFtyH_nz5WCdXraTsOOgL25er1sBpuQdYkuURoDYBA5tcjTUZqlWw0M4LNxpP9V9rH0FOnONCGM"
        case .custom: return ""
        }
    }
}
