//
//  UserDetails.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import Foundation

struct UserDetails: Decodable {
    let name: String?
    let location: String?
    let email: String?
    let bio: String?
    let public_repos: Int?
    let followers: Int?
    let following: Int?
    let created_at: String
}

struct Repo: Decodable {
    let name: String
    let git_url: String

    let stargazers_count: Int
    let forks_count: Int
}
