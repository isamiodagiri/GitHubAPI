//
//  ApiRequestUserList.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/16.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire
import ObjectMapper

// MARK: - Request
enum ApiRequestUserList: BaseRequestProtocol {
    
    typealias ResponseType = UserList

    case get(keyword: String)

    var method: HTTPMethod {
        switch self {
        case .get: return .get
        }
    }

    var path: String {
        return "search/users"
    }

    var parameters: Parameters? {
        switch self {
        case .get(let keyword):
            return [
                "q": "language:\(keyword)",
                "page": 1,
                "per_page": 50
            ]
        }
    }

}
