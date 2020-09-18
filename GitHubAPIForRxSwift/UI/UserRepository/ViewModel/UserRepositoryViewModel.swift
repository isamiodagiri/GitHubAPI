//
//  UserRepositoryViewModel.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


struct SectionOfRepository {
    var header: String
    var items: [Item]
}

extension SectionOfRepository: SectionModelType {

    typealias Item = Repository

    init(original: SectionOfRepository, items: [SectionOfRepository.Item]) {
        self = original
        self.items = items
    }
}

class UserRepositoryViewModel {

    let disposeBag = DisposeBag()
    let items = BehaviorRelay<[SectionOfUserList]>(value: [])
    
    var userData = PublishRelay<User>()
    
    var userName: String?

    init(userName: String?) {
        self.userName = userName
    }

    func fetchUserData() {
        
        let request = ApiRequestUserRepository.path(userName: self.userName ?? "")//ApiRequestUserData.path(userName: self.userName ?? "")
        ApiCliant.call(request, disposeBag, onNext: { [weak self] response in
            print(response)
//            self?.userData.accept(response)
        }) { error in
            print("エラー：\(error)")
        }
    }
}
