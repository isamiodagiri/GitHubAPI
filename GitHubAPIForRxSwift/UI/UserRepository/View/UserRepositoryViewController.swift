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
import RxDataSources

class UserRepositoryViewController: UIViewController {

    static func instance() -> UserRepositoryViewController {
        let vc = UserRepositoryViewController()
        vc.detailUrl = ""
        vc.repositoryUrl = ""
        return vc
    }
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource = UserListViewController.dataSource()

    private let disposeBag = DisposeBag()

    private var viewModel: UserRepositoryViewModel?
    
    private var detailUrl: String?
    private var repositoryUrl: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setup()
    }
    
    func setup() {
        self.viewModel = UserRepositoryViewModel()
        
        self.viewModel?.fetchItem(at: "swift")
        
        self.viewModel?.items
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)

    }
}

extension UserRepositoryViewController: UITableViewDelegate {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfRepository> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, tableView, indexPath, repositoryData -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                         for: indexPath)
               
                if let cell = cell as? RepositoryTableViewCell {
                    cell.setup(repositoryName: repositoryData.repositoryName,
                               discription: repositoryData.description,
                               starCount: repositoryData.stargazersCount,
                               language: repositoryData.language)
                }
                return cell
                
        },
            titleForHeaderInSection: { dataSource, index -> String? in
            return dataSource.sectionModels[index].header
            
        })
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}
