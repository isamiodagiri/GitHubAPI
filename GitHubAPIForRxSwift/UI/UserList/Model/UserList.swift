//
//  UserList.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import ObjectMapper

class UserList: Mappable {
    
    var avatarUrl: URL?
    var userName: String?
    var detailUrl: URL?
    var repositoryUrl: URL?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.avatarUrl <- (map["avatar_url"], URLTransform())
        self.userName <- map["login"]
        self.detailUrl <- (map["url"], URLTransform())
        self.repositoryUrl <- (map["repos_url"], URLTransform())
    }
}
