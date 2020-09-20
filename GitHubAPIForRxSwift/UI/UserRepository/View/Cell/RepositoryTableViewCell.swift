//
//  RepositoryTableViewCell.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/15.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    @IBOutlet weak private var repositoryNameLabel: UILabel!
    @IBOutlet weak private var discriptionLabel: UILabel!
    @IBOutlet weak private var starCountLabel: UILabel!
    @IBOutlet weak private var languageIconView: UIView! {
        didSet {
            languageIconView.layer.cornerRadius = languageIconView.frame.height / 2
        }
    }
    @IBOutlet weak private var languageLabel: UILabel!
    
    func setup(repositoryName: String?, discription: String?,
               starCount: Int?, language: String?) {
        
        repositoryNameLabel.text = repositoryName
        discriptionLabel.isHidden = discription == nil
        discriptionLabel.text = discription
        starCountLabel.text = starCount?.description
        languageLabel.text = language
        languageIconView.isHidden = language == nil
    }
    
}
