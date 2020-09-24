//
//  ApiRequestUserData.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/17.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire
import ObjectMapper

enum ApiRequestUserData: BaseRequestProtocol {
    
    typealias ResponseType = User

    case path(userName: String)

    var method: HTTPMethod {
        switch self {
        case .path: return .get
        }
    }

    var path: String {
        switch self {
        case let .path(userName):
            return "users/\(userName)"
        }
    }

    var parameters: Parameters? {
        return [:]
    }
}
