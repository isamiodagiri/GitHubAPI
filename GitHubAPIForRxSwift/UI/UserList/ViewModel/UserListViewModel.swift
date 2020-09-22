//
//  UserListViewModel.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum MultipleContents {
    case item(userDetail: UserDetail)
    case footer
    
    var userName: String? {
        switch self {
        case let .item(userDetail):
            return userDetail.userName
        case .footer:
            return nil
        }
    }
}

struct SectionOfUserList {
    var header: String
    var items: [Item]
}

extension SectionOfUserList: SectionModelType {

    typealias Item = MultipleContents

    init(original: SectionOfUserList, items: [SectionOfUserList.Item]) {
        self = original
        self.items = items
    }
}

class UserListViewModel {

    private let disposeBag = DisposeBag()

    let items = BehaviorSubject<[SectionOfUserList]>(value: [])
    let error = PublishSubject<Error>()
    let selected = PublishSubject<String?>()
    
    init() {
        self.fetchItem()
    }
    
    func fetchItem(at text: String = "", number: Int = 1) {
        let keyword = text.isEmpty ? "swift" : text
        
        let request = ApiRequestUserList.get(keyword: keyword, pageNumber: number)
        ApiCliant.call(request, disposeBag, onSuccess: { [weak self] response in
            guard let self = self,
                let totalCount = response.totalCount,
                let userDetail = response.userDetail else { return }
            
            print("Response：\(response)")
            
            var items = userDetail
                .map { MultipleContents.item(userDetail: $0)}
            
            if totalCount > userDetail.count {
                items.append(MultipleContents.footer)
            }
            let section = SectionOfUserList(header: "検索ワード(言語)：\(keyword)",
                                            items: items)
            self.items.onNext([section])
        }) { [weak self] error in
            print("Error：\(error)")
            self?.error.onNext(error)
        }
    }
    
    func getUserName(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.onNext(items[indexPath.row].userName)
    }
}
