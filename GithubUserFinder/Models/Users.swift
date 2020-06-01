//
//  Users.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    
    let users: [User]
    
  enum CodingKeys: String, CodingKey {
    case users = "items"
  }
}

struct User: Decodable {
    let login: String
    let id: Int
    let avatarUrl: String
    let url: String
    let reposUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case avatarUrl = "avatar_url"
        case url = "url"
        case reposUrl = "repos_url"
    }
}
