//
//  ApiRequestUserList.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/16.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire
import ObjectMapper

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
        case let .get(keyword):
            return [
                "q": "language:\(keyword)"
            ]
        }
    }
}
