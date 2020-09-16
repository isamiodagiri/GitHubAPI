//
//  UserRepositoryViewController.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserRepositoryViewController: UIViewController {

    static func instance() -> UserRepositoryViewController {
        let vc = UserRepositoryViewController()
        return vc
    }
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: UserRepositoryViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
