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
        self.totalCount <- map["total_count"]
        self.userDetail <- map["items"]
    }
}

class UserDetail: Mappable {
    var avatarUrl: String?
    var userName: String?
    var detailUrl: String?
    var repositoryUrl: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.avatarUrl <- map["avatar_url"]
        self.userName <- map["login"]
        self.detailUrl <- map["url"]
        self.repositoryUrl <- map["repos_url"]
    }
}
