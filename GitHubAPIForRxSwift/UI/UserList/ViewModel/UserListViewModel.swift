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
import RxOptional

enum MultipleContents {
    case item(userDetail: UserDetail)
    
    var userName: String? {
        switch self {
        case let .item(userDetail):
            return userDetail.userName
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
    let error = PublishRelay<Error>()
    let selected = PublishRelay<String?>()
    var inputWord = PublishRelay<String?>()
        
    init() {
        setup()
    }
    
    func setup() {
        inputWord
            .filterNil()
            .subscribe(onNext: { [unowned self] response in
                self.fetchItem(at: response)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchItem(at keyword: String) {
        let request = ApiRequestUserList.get(keyword: keyword)

        ApiCliant.call(request, disposeBag, onSuccess: { [weak self] response in
            guard let self = self,
                let _ = response.totalCount,
                let userDetail = response.userDetail else { return }
            
            print("Response：\(response)")
            
            let items = userDetail
                .map { MultipleContents.item(userDetail: $0)}
            
            let section = SectionOfUserList(header: "検索ワード(言語)：\(keyword)",
                                            items: items)
            self.items.onNext([section])
        }) { [weak self] error in
            print("Error：\(error)")
            self?.error.accept(error)
        }
    }
    
    func getUserName(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.accept(items[indexPath.row].userName)
    }
}
