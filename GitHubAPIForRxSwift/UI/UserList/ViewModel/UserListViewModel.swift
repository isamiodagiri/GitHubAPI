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

    private var inputWord = PublishRelay<String?>()
    private let error = PublishRelay<(title: String, message: String, isFound: Bool)>()
    private let selected = PublishRelay<String?>()
    private let isLoadStart = PublishRelay<Bool>()
    private let isLoadEnd = PublishRelay<Bool>()

    lazy var driverError: Driver<(title: String, message: String, isFound: Bool)> = self.error.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverSelected: Driver<String?> = self.selected.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverIsLoadStart: Driver<Bool> = self.isLoadStart.asDriver(onErrorDriveWith: Driver.empty())
    lazy var driverIsLoadEnd: Driver<Bool> = self.isLoadEnd.asDriver(onErrorDriveWith: Driver.empty())
    
    init() {
        setup()
        reloadInputWord()
    }
    
    func setup() {
        inputWord
            .filterNil()
            .filterEmpty()
            .subscribe(onNext: { [unowned self] response in
                self.isLoadStart.accept(true)
                self.fetchItem(at: response)
            })
            .disposed(by: disposeBag)
    }
    
    func setInputWord(at text: String?) {
        inputWord.accept(text)
    }
    
    func reloadInputWord(at text: String? = nil) {
        let text: String = {
            if let text = text, !text.isEmpty {
                return text
            }
            return "swift"
        }()
        inputWord.accept(text)
    }
    
    func getUserName(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.accept(items[indexPath.row].userName)
    }
    
    private func fetchItem(at keyword: String) {
        let request = ApiRequestUserList.get(keyword: keyword)

        ApiCliant.call(request, disposeBag, onSuccess: { [weak self] response in
            print("Response：\(response)")

            guard let _ = response.totalCount,
                let userDetail = response.userDetail else {
                    self?.error.accept((Localize.searchedNotResponseTitle,
                                        Localize.searchedNotResponseMessage,
                                        true))
                    return
            }
            
            let items = userDetail.map { MultipleContents.item(userDetail: $0)}
            let section = SectionOfUserList(header: "現在の検索ワード(言語)：\(keyword)",
                                            items: items)
            self?.items.onNext([section])
            self?.isLoadEnd.accept(true)
        }) { [weak self] error in
            print("Error：\(error)")
            self?.error.accept((Localize.communicationErrorTitle,
                                Localize.communicationErrorMessage,
                                false))
        }
    }
}
