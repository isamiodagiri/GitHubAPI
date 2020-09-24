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
import RxOptional

enum RepositoryContentsRepository {
    case item(repository: Repository)
    
    var repositoryUrl: String? {
        switch self {
        case let .item(repository):
            return repository.repositoryUrl
        }
    }
}

enum FechedDataState {
    case userData
    case repository
    case unfinished
}

struct SectionOfRepository {
    var header: String
    var items: [Item]
}

extension SectionOfRepository: SectionModelType {

    typealias Item = RepositoryContentsRepository

    init(original: SectionOfRepository, items: [SectionOfRepository.Item]) {
        self = original
        self.items = items
    }
}

class UserRepositoryViewModel {

    private let disposeBag = DisposeBag()

    private let error = PublishSubject<FechedDataState>()
    private let userData = PublishSubject<User>()
    private let selected = PublishSubject<String?>()
    private let isRepository = PublishSubject<Bool>()
    private let isLoadEnd = PublishSubject<Bool>()

    lazy var driverError: Driver<FechedDataState> = self.error.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverUserData: Driver<User> = self.userData.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverSelected: Driver<String?> = self.selected.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverIsRepository: Driver<Bool> = self.isRepository.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverIsLoadEnd: Driver<Bool> = self.isLoadEnd.asDriver(onErrorDriveWith: Driver.empty())

    private var userName: String?
    private var isFetchedUserData = Bool()
    private var isFetchedRepository = Bool()

    let items = BehaviorSubject<[SectionOfRepository]>(value: [])

    init(userName: String?) {
        self.userName = userName
        fetchUserData()
        fetchUserRepository()
    }

    func fetchUserData() {
        let request = ApiRequestUserData.path(userName: self.userName ?? "")
        ApiCliant.call(request, disposeBag, onSuccess: { [weak self] response in
            print("Response：\(response)")
            self?.isFetchedUserData = true
            self?.userData.onNext(response)
            if (self?.isFetchedRepository ?? false) {
                self?.isLoadEnd.onNext(true)
            }
        }) { [weak self] error in
            print("Error：\(error)")
            if !(self?.isFetchedRepository ?? false) {
                self?.error.onNext(.unfinished)
            } else {
                self?.error.onNext(.userData)
            }
        }
    }
    
    func fetchUserRepository() {
        let request = ApiRequestUserRepository.path(userName: self.userName ?? "")
        ApiCliant.callToArray(request, disposeBag, onSuccess: { [weak self] response in
            print("Response：\(response)")
            self?.isFetchedRepository = true
            self?.isRepository.onNext(response.isEmpty)
            let items = response.map { RepositoryContentsRepository.item(repository: $0) }
            let section = SectionOfRepository(header: "Repository",
                                              items: items)
            self?.items.onNext([section])
            if (self?.isFetchedUserData ?? false) {
                self?.isLoadEnd.onNext(true)
            }
        }) { [weak self] error in
            print("Error：\(error)")
            if !(self?.isFetchedUserData ?? false) {
                self?.error.onNext(.unfinished)
            } else {
                self?.error.onNext(.repository)
            }
        }
    }
    
    func getRepositoryUrl(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.onNext(items[indexPath.row].repositoryUrl)
    }
}
