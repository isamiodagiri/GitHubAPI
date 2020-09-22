//
//  UITableViewCellExtension.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/22.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

extension UITableViewCell {
    var className: String {
        return String(describing: type(of: self))
    }
}
