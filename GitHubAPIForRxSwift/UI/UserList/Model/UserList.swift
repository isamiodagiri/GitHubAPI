//
//  UserList.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import ObjectMapper

class UserList: Mappable {
    var totalCount: Int?
    var userDetail: [UserDetail]?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        totalCount <- map["total_count"]
        userDetail <- map["items"]
    }
}

class UserDetail: Mappable {
    var avatarUrl: String?
    var userName: String?
    var detailUrl: String?
    var repositoryUrl: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        avatarUrl <- map["avatar_url"]
        userName <- map["login"]
        detailUrl <- map["url"]
        repositoryUrl <- map["repos_url"]
    }
}
