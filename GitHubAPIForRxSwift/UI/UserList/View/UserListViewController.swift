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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = UserListViewController.dataSource()
    private var viewModel: UserListViewModel?

    var rx_searchBarText: Observable<String> {
        return searchBar.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .filter { $0.count > 0 }
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance) //0.5秒のバッファを持たせる
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setup()
    }
    
    func setup() {
        self.viewModel = UserListViewModel()
        
        self.viewModel?.fetchItem(at: "swift")
        
        self.viewModel?.items
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)

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
    
    func setupTableView() {
        tableView.register(UINib(nibName: "UserListTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "cell")
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}
