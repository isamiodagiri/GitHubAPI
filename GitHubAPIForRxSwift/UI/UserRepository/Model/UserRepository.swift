//
//  UserRepository.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import ObjectMapper

class User: Mappable {

    var avatarUrl: URL?
    var userName: String?
    var userFullName: String?
    var followersCount: Int?
    var followingCount: Int?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.avatarUrl <- (map["avatar_url"], URLTransform())
        self.userName <- map["mojombo"]
        self.userFullName <- map["name"]
        self.followersCount <- map["followers"]
        self.followingCount <- map["following"]
    }
}

class Repository: Mappable {

    var repositoryName: String?
    var language: String?
    var description: String?
    var stargazersCount: Int?
    var repositoryUrl: URL?
    var isFork: Bool?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.repositoryName <- map["name"]
        self.language <- map["language"]
        self.description <- map["description"]
        self.stargazersCount <- map["stargazers_count"]
        self.repositoryUrl <- (map["html_url"], URLTransform())
        self.isFork <- map["fork"]
    }
}
