//
//  UrlConfig.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/16.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import Alamofire

enum UrlConfig {
    
    static var baseURL = "https://api.github.com/"

    static var header: HTTPHeaders? {
        return []
    }
}
