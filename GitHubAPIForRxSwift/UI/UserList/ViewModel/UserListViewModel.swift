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


struct SectionOfUserList {
    var header: String
    var items: [Item]
}

extension SectionOfUserList: SectionModelType {

    typealias Item = UserDetail

    init(original: SectionOfUserList, items: [SectionOfUserList.Item]) {
        self = original
        self.items = items
    }
}

class UserListViewModel {

    let disposeBag = DisposeBag()
    let items = BehaviorRelay<[SectionOfUserList]>(value: [])

    func fetchItem(at text: String) {
        let request = ApiRequestUserList.get(keyword: text)
        ApiCliant.call(request, disposeBag, onNext: { [weak self] response in
            guard let totalCount = response.totalCount,
                let userDetail = response.userDetail else { return }
            
            let section = SectionOfUserList(header: "\(totalCount)件",
                                            items: userDetail)
            self?.items.accept([section])
        }) { error in
            print("エラー：\(error)")
        }
    }
}
