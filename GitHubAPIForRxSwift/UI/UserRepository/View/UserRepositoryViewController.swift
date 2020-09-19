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

    static func instance(at userName: String?) -> UserRepositoryViewController {
        let vc = UserRepositoryViewController()
        vc.userName = userName
        return vc
    }
    
    @IBOutlet weak private var userFullNameLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var userIconImageView: UIImageView!
    @IBOutlet weak private var followersCountLabel: UILabel!
    @IBOutlet weak private var followingCountLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private lazy var dataSource = UserRepositoryViewController.dataSource()

    private let disposeBag = DisposeBag()

    private var viewModel: UserRepositoryViewModel?
    
    private var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel = UserRepositoryViewModel(userName: userName)
        
        viewModel?.fetchUserData()
        viewModel?.fetchUserRepository()
        
        viewModel?.userData
            .subscribe(onNext: { [unowned self] response in
                self.setupUserAcountView(at: response.userFullName,
                                         at: response.userName,
                                         at: response.avatarUrl,
                                         at: response.followersCount?.description,
                                         at: response.followingCount?.description)
            })
            .disposed(by: disposeBag)
        
        viewModel?.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel?.selected
            .subscribe(onNext: {[unowned self] response in
                self.transitionWebView(url: response)
            })
            .disposed(by: disposeBag)
    }
    
    private func transitionWebView(url acceseUrl: String?) {
        let vc = RepositoryWebViewController.instance(at: acceseUrl)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUserAcountView(at fullName: String?,
                             at name: String?,
                             at iconUrl: String?,
                             at followersCount: String?,
                             at followingCount: String?) {
        userFullNameLabel.text = fullName
        userNameLabel.text = name
        userIconImageView.ex.loadUrl(imageUrl: iconUrl,
                                     processorOption: .resizeCircle)
        followersCountLabel.text = followersCount
        followingCountLabel.text = followingCount
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
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .subscribe(onNext: { [unowned self] indexPath in
            self.viewModel?.getRepositoryUrl(at: indexPath)
        })
        .disposed(by: disposeBag)
    }
}
