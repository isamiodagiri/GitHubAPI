//
//  UserListViewController.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import PKHUD

class UserListViewController: UIViewController {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!

    private let disposeBag = DisposeBag()
    
    private var viewModel: UserListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        setupViewModel()
        setupGesture()
    }
    
    private func setupViewModel() {
        viewModel = UserListViewModel()
        
        viewModel?.driverIsLoadStart
            .drive(onNext: { _ in
                HUD.show(.systemActivity)
            })
            .disposed(by: disposeBag)
        
        viewModel?.driverIsLoadEnd
            .drive(onNext: { _ in
                HUD.hide()
            })
            .disposed(by: disposeBag)
                
        viewModel?.items
            .bind(to: tableView.rx.items(dataSource: dataSource()))
            .disposed(by: disposeBag)
        
        viewModel?.driverSelected
            .drive(onNext: { [unowned self] in
                self.transitionUserRepositoryView(name: $0)
            })
            .disposed(by: disposeBag)
        
        viewModel?.driverError
            .drive(onNext: { [unowned self] in
                self.showErrorDialog($0.title,
                                     $0.message,
                                     $0.isFound)
            })
            .disposed(by: disposeBag)
    }
    
    private func transitionUserRepositoryView(name userName: String?) {
        let vc = UserRepositoryViewController.instance(at: userName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showErrorDialog(_ title: String, _ message: String, _ isFound: Bool) {
        let alert: UIAlertController = UIAlertController(title: title,
                                                         message: message,
                                                         preferredStyle:  .alert)
        
        let communicationAction = UIAlertAction(title: Localize.communicationErrorAction,
                                                style: .default,
                                                handler: { [weak self] _ in
                                                    self?.viewModel?.reloadInputWord(at: self?.searchBar.text)
        })
        
        let closeAction = UIAlertAction(title: Localize.closeAction,
                                        style: .cancel,
                                        handler: {  _ in
                                            HUD.hide()
        })
        
        if isFound {
            alert.addAction(closeAction)
        } else {
            alert.addAction(communicationAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setupGesture() {
        view.rx.panGesture()
            .when(.began)
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { _ in
                if self.searchBar.searchTextField.isEditing {
                    self.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
        
        navigationController?.navigationBar.rx.tapGesture()
            .when(.recognized)
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(onNext: { _ in
                if self.searchBar.searchTextField.isEditing {
                    self.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension UserListViewController: UISearchBarDelegate {
    
    private func setupSearchBar() {
        searchBar.delegate = self
        
        searchBar.rx
        .searchButtonClicked
        .asDriver()
        .drive(onNext: { [unowned self] _ in
            self.searchBar.resignFirstResponder()
            self.viewModel?.setInputWord(at: self.searchBar.text)
        })
        .disposed(by: disposeBag)
        
    }
}

extension UserListViewController: UITableViewDelegate {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfUserList> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, tableView, indexPath, contents -> UITableViewCell in
                switch contents {
                case let .item(userDetail):
                    let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell().ex.className,
                                                             for: indexPath)
                    if let cell = cell as? UserListTableViewCell {
                        cell.setup(imageUrl: userDetail.avatarUrl, name: userDetail.userName)
                    }
                    return cell
                }
        },
            titleForHeaderInSection: { dataSource, index -> String? in
            return dataSource.sectionModels[index].header
        })
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: UserListTableViewCell().ex.className)
                
        tableView.delaysContentTouches = false
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.viewModel?.getUserName(at: indexPath)
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
