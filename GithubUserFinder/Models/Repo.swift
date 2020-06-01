//
//  Repo.swift
//  GithubUserFinder
//
//  Created by POOJA on 31/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import Foundation

struct Repo: Decodable {
    let name: String
    let html_url: String
    
    let stargazers_count: Int
    let forks_count: Int
}
