//
//  Bundle+Extensions.swift
//  Go
//
//  Created by Kevin Johnson on 1/18/26.
//  Copyright © 2026 Kevin Johnson. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    var buildVersionNumber: String? { infoDictionary?["CFBundleVersion"] as? String }
    var versionNumberString: String { "\(releaseVersionNumber ?? "") (\(buildVersionNumber ?? ""))" }
}
