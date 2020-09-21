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

    private let disposeBag = DisposeBag()

    let items = BehaviorSubject<[SectionOfRepository]>(value: [])
    let error = PublishSubject<Bool>()
    let userData = PublishSubject<User>()
    let selected = PublishSubject<String?>()

    private var userName: String?

    init(userName: String?) {
        self.userName = userName
    }

    func fetchUserData() {
        let request = ApiRequestUserData.path(userName: self.userName ?? "")
        ApiCliant.call(request, disposeBag, onSuccess: { [weak self] response in
            print("Response：\(response)")
            
            self?.userData.onNext(response)
        }) { [weak self] error in
            print("Error：\(error)")
            self?.error.onNext(true)
        }
    }
    
    func fetchUserRepository() {
        let request = ApiRequestUserRepository.path(userName: self.userName ?? "")
        ApiCliant.callToArray(request, disposeBag, onSuccess: { [weak self] response in
            print("Response：\(response)")
            
            let section = SectionOfRepository(header: "Repository",
                                              items: response)
            self?.items.onNext([section])
        }) { [weak self] error in
            print("Error：\(error)")
            self?.error.onNext(false)
        }
    }
    
    func getRepositoryUrl(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.onNext(items[indexPath.row].repositoryUrl)
    }
}
