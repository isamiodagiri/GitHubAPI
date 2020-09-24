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
import RxOptional
import PKHUD

class UserRepositoryViewController: UIViewController {

    static func instance(at userName: String?) -> UserRepositoryViewController {
        let vc = UserRepositoryViewController()
        vc.userName = userName
        return vc
    }
    
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak private var userFullNameLabel: UILabel!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var userIconImageView: UIImageView!
    @IBOutlet weak private var followersCountLabel: UILabel!
    @IBOutlet weak private var followingCountLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var noRepositoryView: UIView!
    
    private let disposeBag = DisposeBag()

    private var viewModel: UserRepositoryViewModel?
    
    private var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.systemActivity)
        setupTableView()
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel = UserRepositoryViewModel(userName: userName)

        viewModel?.driverUserData
            .drive(onNext: { [unowned self] in
                self.userView.isHidden = false
                self.userFullNameLabel.text = $0.userFullName
                self.userNameLabel.text = $0.userName
                self.userIconImageView.ex.loadUrl(imageUrl: $0.avatarUrl,
                                                  processorOption: .resizeCircle)
                self.followersCountLabel.text = $0.followersCount?.description
                self.followingCountLabel.text = $0.followingCount?.description
            })
            .disposed(by: disposeBag)
        
        viewModel?.items
            .bind(to: tableView.rx.items(dataSource: dataSource()))
            .disposed(by: disposeBag)
        
        viewModel?.driverSelected
            .drive(onNext: { [unowned self] in
                self.transitionWebView(url: $0)
            })
            .disposed(by: disposeBag)

        viewModel?.driverIsRepository
            .drive(onNext: { [unowned self] in
                self.tableView.isHidden = $0
                self.noRepositoryView.isHidden = !$0
            })
            .disposed(by: disposeBag)
        
        viewModel?.driverError
            .drive(onNext: { [unowned self] in
                self.showErrorDialog(state: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel?.driverIsLoadEnd
            .drive(onNext: { _ in
                HUD.hide()
            })
            .disposed(by: disposeBag)
    }
    
    private func transitionWebView(url acceseUrl: String?) {
        let vc = RepositoryWebViewController.instance(at: acceseUrl)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showErrorDialog(state: FechedDataState) {
        let alert: UIAlertController = UIAlertController(title: Localize.communicationErrorTitle,
                                                         message: Localize.communicationErrorMessage,
                                                         preferredStyle: .alert)
        
        let communicationAction = UIAlertAction(title: Localize.communicationErrorAction,
                                                style: .default,
                                                handler: { [weak self] _ in
                                                    switch state {
                                                    case.unfinished:
                                                        self?.viewModel?.fetchUserData()
                                                        self?.viewModel?.fetchUserRepository()
                                                    case.userData:
                                                        self?.viewModel?.fetchUserData()
                                                    case.repository:
                                                        self?.viewModel?.fetchUserRepository()
                                                    }
        })
        
        let backViewAction = UIAlertAction(title: Localize.backViewAction,
                                           style: .cancel,
                                           handler: { [weak self] _ in
                                            HUD.hide()
                                            self?.navigationController?.popViewController(animated: true)
        })

        alert.addAction(communicationAction)
        alert.addAction(backViewAction)
        present(alert, animated: true, completion: nil)
    }
}

extension UserRepositoryViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfRepository> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, tableView, indexPath, contents -> UITableViewCell in
                switch contents {
                case let .item(repository):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                             for: indexPath)
                    
                    if let cell = cell as? RepositoryTableViewCell {
                        cell.setup(repositoryName: repository.repositoryName,
                                   discription: repository.description,
                                   starCount: repository.stargazersCount,
                                   language: repository.language)
                    }
                    
                    return cell
                }
        },
            titleForHeaderInSection: { dataSource, index -> String? in
            return dataSource.sectionModels[index].header
        })
    }
}

extension UserRepositoryViewController: UITableViewDelegate {
    private func setupTableView() {
        tableView.register(UINib(nibName: "RepositoryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .subscribe(onNext: { [unowned self] indexPath in
            self.viewModel?.getRepositoryUrl(at: indexPath)
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
        .disposed(by: disposeBag)
    }
}
