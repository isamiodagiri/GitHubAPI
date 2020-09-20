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
    }
    
    private func setupViewModel() {
        viewModel = UserListViewModel()
        
        viewModel?.fetchItem(at: "swift")
        
        viewModel?.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel?.selected
            .subscribe(onNext: { [unowned self] text in
                self.transitionUserRepositoryView(name: text)
            })
            .disposed(by: disposeBag)
    }
    
    private func transitionUserRepositoryView(name userName: String?) {
        let vc = UserRepositoryViewController.instance(at: userName)
        self.navigationController?.pushViewController(vc, animated: true)
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

            if let text = self.searchBar.text, !text.isEmpty {
                self.viewModel?.fetchItem(at: self.searchBar.text ?? "")
            }
        })
        .disposed(by: disposeBag)
        
    }
}

extension UserListViewController: UITableViewDelegate {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfUserList> {
        return RxTableViewSectionedReloadDataSource(
            configureCell: { dataSource, tableView, indexPath, userDetail -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                         for: indexPath)
                if let cell = cell as? UserListTableViewCell {
                    cell.setup(imageUrl: userDetail.avatarUrl, name: userDetail.userName)
                }
                return cell
                
        },
            titleForHeaderInSection: { dataSource, index -> String? in
            return dataSource.sectionModels[index].header
            
        })
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        
        tableView.delaysContentTouches = false
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.viewModel?.getUserName(at: indexPath)
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
