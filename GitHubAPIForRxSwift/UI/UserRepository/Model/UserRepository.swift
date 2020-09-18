//
//  UserRepository.swift
//  GitHubAPIForRxSwift
//
//  Created by Isami Odagiri on 2020/09/13.
//  Copyright © 2020 Isami Odagiri. All rights reserved.
//

import ObjectMapper

class User: Mappable {

    var avatarUrl: String?
    var userName: String?
    var userFullName: String?
    var followersCount: Int?
    var followingCount: Int?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        avatarUrl <- map["avatar_url"]
        userName <- map["login"]
        userFullName <- map["name"]
        followersCount <- map["followers"]
        followingCount <- map["following"]
    }
}

class Repository: Mappable {

    var repositoryName: String?
    var language: String?
    var description: String?
    var stargazersCount: String?
    var repositoryUrl: String?
    var isFork: Bool?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        repositoryName <- map["name"]
        language <- map["language"]
        description <- map["description"]
        stargazersCount <- map["stargazers_count"]
        repositoryUrl <- map["html_url"]
        isFork <- map["fork"]
    }
}
