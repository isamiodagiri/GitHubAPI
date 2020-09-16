//
//  GitHubAPIForRxSwiftTests.swift
//  GitHubAPIForRxSwiftTests
//
//  Created by Isami Odagiri on 2020/09/12.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import XCTest
import RxSwift
@testable import GitHubAPIForRxSwift

class GitHubAPIForRxSwiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
//    func testUserListViewModel() {
//        let disposeBag = DisposeBag()
//        
//        var rx_searchBarText: Observable<String> {
//            return BehaviorSubject(value: "")
//        }
//        userListViewModel.rx_repositories.drive(onNext: { response in
//            print(response)
//        }, onCompleted: {
//            print("Completed")
//        }) {
//            print("onDisposed")
//        }.disposed(by: disposeBag)
//    }
    
     func testCallForApiUserList() {
        let disposeBag = DisposeBag()

        let request = ApiRequestUserList.get(keyword: "swift")
        ApiCliant.call(request, disposeBag, onNext: { print("サクセス：\($0)")}) { print("エラー：\($0)")}
    }
}
