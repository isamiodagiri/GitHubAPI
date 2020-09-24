//
//  UIColorExtension.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/24.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

extension UIColor: TargetedExtensionCompatible {}

extension TargetedExtension where Base: UIColor {

    static func languageColor(at name: String?) -> UIColor? {
        switch name {
        case let (target) where target?.caseInsensitiveCompare("swift") == ComparisonResult.orderedSame:
            return UIColor(named: "originalYellow")
        case let (target) where target?.caseInsensitiveCompare("java") == ComparisonResult.orderedSame:
            return UIColor(named: "originalRed")
        case let (target) where target?.caseInsensitiveCompare("javascript") == ComparisonResult.orderedSame:
            return UIColor(named: "originalBlue")
        case let (target) where target?.caseInsensitiveCompare("ruby") == ComparisonResult.orderedSame:
            return UIColor(named: "originalGreen")
        case let (target) where target?.caseInsensitiveCompare("c") == ComparisonResult.orderedSame:
            return UIColor(named: "originalMagenta")
        case let (target) where target?.caseInsensitiveCompare("python") == ComparisonResult.orderedSame:
            return UIColor(named: "originalOrange")
        case let (target) where target?.caseInsensitiveCompare("kotlin") == ComparisonResult.orderedSame:
            return UIColor(named: "originalPurple")
        default:
            return .brown
        }
    }
}
