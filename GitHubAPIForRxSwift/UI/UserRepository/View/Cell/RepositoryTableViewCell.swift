//
//  RepositoryTableViewCell.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/15.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var languageIconView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    
    func setup(repositoryName: String?, discription: String?,
               starCount: String?, language: String?) {
        
        repositoryNameLabel.text = repositoryName
        discriptionLabel.text = discription
        starCountLabel.text = starCount
        languageLabel.text = language
        languageIconView.isHidden = language == nil
    }
    
}
