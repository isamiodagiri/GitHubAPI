//
//  BaseApiRequestProtocol.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/16.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire
import ObjectMapper

protocol BaseApiProtocol {
    associatedtype ResponseType // レスポンスの型

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
}

extension BaseApiProtocol {
    var baseURL: URL {
        return URL(string: UrlConfig.baseURL)!
    }
    
    var headers: HTTPHeaders? {
        return UrlConfig.header
    }
}

// MARK: - BaseRequestProtocol
protocol BaseRequestProtocol: BaseApiProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: URLEncoding { get }
}

extension BaseRequestProtocol {
    var encoding: URLEncoding {
        return URLEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.headers = headers ?? HTTPHeaders()
        urlRequest.timeoutInterval = TimeInterval(30)

        if let params = parameters {
            urlRequest = try encoding.encode(urlRequest, with: params)
        }

        return urlRequest
    }

}
