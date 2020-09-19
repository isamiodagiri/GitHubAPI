//
//  UserListTableViewCell.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/15.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var iconImageView: CircleImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    
    func setup(imageUrl: String?, name: String?) {
        iconImageView.ex.loadUrl(imageUrl: imageUrl,
                                 processorOption: .resizeCircle)
        nameLabel.text = name
    }
}
