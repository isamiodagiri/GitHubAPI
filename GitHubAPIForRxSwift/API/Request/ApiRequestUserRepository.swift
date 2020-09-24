//
//  ApiRequestUserRepository.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/17.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire
import ObjectMapper

enum ApiRequestUserRepository: BaseRequestProtocol {
    
    typealias ResponseType = Repository

    case path(userName: String)

    var method: HTTPMethod {
        switch self {
        case .path: return .get
        }
    }

    var path: String {
        switch self {
        case let .path(userName):
            return "users/\(userName)/repos"
        }
    }

    var parameters: Parameters? {
        return [:]
    }
}
