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

class UserListViewController: UIViewController {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var tableView: UITableView!

    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = UserListViewController.dataSource()
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
                
        viewModel?.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel?.selected
            .subscribe(onNext: { [unowned self] text in
                self.transitionUserRepositoryView(name: text)
            })
            .disposed(by: disposeBag)
        
        viewModel?.error
            .subscribe(onNext: { [unowned self] _ in
                self.showErrorDialog()
            })
            .disposed(by: disposeBag)
    }
    
    private func transitionUserRepositoryView(name userName: String?) {
        let vc = UserRepositoryViewController.instance(at: userName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showErrorDialog() {
        let alert: UIAlertController = UIAlertController(title: Localize.communicationErrorTitle,
                                                         message: Localize.communicationErrorMessege,
                                                         preferredStyle:  .alert)
        
        let communicationAction = UIAlertAction(title: Localize.communicationErrorAction,
                                                style: .default,
                                                handler: { [weak self] _ in
                                                    self?.viewModel?.inputWord.accept(self?.searchBar.text)
        })
        alert.addAction(communicationAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupGesture() {
        view.rx.panGesture()
            .when(.began)
            .subscribe(onNext: { _ in
                if self.searchBar.searchTextField.isEditing {
                    self.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
        
        navigationController?.navigationBar.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
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
            self.viewModel?.inputWord.accept(self.searchBar.text)
        })
        .disposed(by: disposeBag)
        
    }
}

extension UserListViewController: UITableViewDelegate {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfUserList> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, tableView, indexPath, contents -> UITableViewCell in
                switch contents {
                case let .item(userDetail):
                    let cell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell().className,
                                                             for: indexPath)
                    if let cell = cell as? UserListTableViewCell {
                        cell.setup(imageUrl: userDetail.avatarUrl, name: userDetail.userName)
                    }
                    return cell

                case .footer:
                    return tableView.dequeueReusableCell(withIdentifier: FooterTableViewCell().className,
                                                         for: indexPath)
                }
        },
            titleForHeaderInSection: { dataSource, index -> String? in
            return dataSource.sectionModels[index].header
        })
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: UserListTableViewCell().className)
        
        tableView.register(UINib(nibName: "FooterTableViewCell", bundle: nil),
                           forCellReuseIdentifier: FooterTableViewCell().className)
        
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
        
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { [unowned self] _, indexPath in
                self.viewModel?.checkAddFetchItem(number: indexPath.row)
            })
            .disposed(by: disposeBag)
    }
}
