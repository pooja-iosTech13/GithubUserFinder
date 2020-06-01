//
//  UserCell.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {
    
    @IBOutlet private weak var repoNameLabel: UILabel!
    @IBOutlet private weak var forksLabel: UILabel!
    @IBOutlet private weak var starsLabel: UILabel!
    
    private enum constants {
        static let forkText = " Fork"
        static let forksText = " Forks"
        static let starText = " Star"
        static let starsText = " Stars"
    }
    
    func populate(repo: Repo) {
        repoNameLabel.text = repo.name
        forksLabel.text = "\(repo.forks_count)" + "\(repo.forks_count > 1 ? "\(constants.forksText)" : "\(constants.forkText)")"
        starsLabel.text = "\(repo.stargazers_count)" + "\(repo.stargazers_count > 1 ? "\(constants.starsText)" : "\(constants.starText)")"
    }
}
