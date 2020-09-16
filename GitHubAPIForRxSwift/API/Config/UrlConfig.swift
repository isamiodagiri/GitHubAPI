//
//  UrlConfig.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/16.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire

enum UrlConfig {
    case userList

    // MARK: Public Variables
    var path: String {
        switch self {
        case .userList: return "search/users"
        }
    }


    // MARK: Public Static Variables
    static var baseURL = "https://api.github.com/"

    static var header: HTTPHeaders? {
        return []
    }
}
