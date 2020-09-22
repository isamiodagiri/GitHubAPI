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

    let minFetchCellCount = 1
    let maxFetchCellCount = 50
    
    let items = BehaviorSubject<[SectionOfUserList]>(value: [])
    let error = PublishRelay<Error>()
    let selected = PublishRelay<String?>()
    var inputWord = PublishRelay<String?>()
    
    var searchedWord = String()
    var searchedCellCount = Int()
    
    init() {
        setup()
    }
    
    func setup() {
        inputWord
            .filterNil()
            .subscribe(onNext: { [unowned self] response in
                if !self.searchedWord.contains(response) {
                    self.searchedWord = response
                    self.searchedCellCount = self.maxFetchCellCount
                    
                    self.fetchItem(at: self.searchedWord,
                                   startNumber: self.minFetchCellCount,
                                   endNumber: self.searchedCellCount)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func checkAddFetchItem(number: Int) {
        if number == searchedCellCount {
            searchedCellCount += number
            let start = number + minFetchCellCount
            fetchItem(at: searchedWord, startNumber: start, endNumber: searchedCellCount)
        }
    }
    
    private func fetchItem(at keyword: String, startNumber: Int, endNumber: Int) {
        let request = ApiRequestUserList.get(keyword: keyword,
                                             startNumber: startNumber,
                                             endNumber: endNumber)

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
            guard let value = try? self?.items.value(), var list = value.first else { return }

            print("Error：\(error)")
            let count = list.items.count - 1
            list.items.remove(at: count)
            self?.items.onNext([list])
          
            self?.error.accept(error)
        }
    }
    
    func getUserName(at indexPath: IndexPath) {
        guard let list = try? items.value() else { return }
        
        let items = list[indexPath.section].items

        selected.accept(items[indexPath.row].userName)
    }
}
