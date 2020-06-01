//
//  UserDetailViewController.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import UIKit
import Alamofire

class UserDetailViewController: UIViewController {
    
    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var joinDateLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var followersLable: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var bioLabel: UILabel!
    @IBOutlet private weak var reposCountLabel: UILabel!

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    // Required user data passed from previous VC to load this page.
    var user: User!
    
    private var userDetails: UserDetails?
    private var repos: [Repo] = []
    private var filteredRepos: [Repo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RepoCell", bundle: nil), forCellReuseIdentifier: "RepoCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // This image can also be passed from previous VC but I think its okay as alamofire cache image data.
        if let imageUrl = URL(string: user.avatarUrl) {
            userImageView.af.setImage(withURL: imageUrl, cacheKey: "CacheUserImageKey\(user.id)")
        }
        getDetails(for: user)
        getRepos(for: user)
    }
    
    private func displayUserDetails(userDetails: UserDetails) {
        //If userDetails doesn't have name using user.login to display
        nameLabel.text = userDetails.name ?? user.login
        emailLabel.text = userDetails.email ?? ""
        joinDateLabel.text = userDetails.created_at
        locationLabel.text = userDetails.location ?? ""
        followersLable.text = "\(userDetails.followers ?? 0) Followers"
        followingLabel.text = "Following \(userDetails.following ?? 0)"
        reposCountLabel.text = "\(userDetails.public_repos ?? 0) Repos"
        
        bioLabel.text = userDetails.bio ?? ""
        
//        let labels = self.view.subviews.compactMap { $0 as? UILabel }
//
//        for label in labels {
//            label.isHidden = true
//        }
    }
    
    private func getDetails(for user: User) {
        ServiceManager.getDetails(for: user.login) { (response) in
            guard let userDetails = response as? UserDetails else { return }
                //TODO:- use weak self
                self.userDetails = userDetails
                self.displayUserDetails(userDetails: userDetails)
        }
    }
    
    private func getRepos(for user: User) {
        ServiceManager.getRepos(for: user.login) { (response) in
            guard let repos = response as? [Repo] else { return }
                self.repos = repos
                self.filteredRepos = repos
                self.tableView.reloadData()
        }
    }
}

//MARK:- TableView datasource
extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRepos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RepoCell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath) as? RepoCell else {
            return UITableViewCell()
        }
        let repo = filteredRepos[indexPath.row]
        cell.repoNameLabel.text = repo.name
        cell.forksLabel.text = "\(repo.forks_count)" + "\(repo.forks_count > 1 ? " Forks" : " Fork")"
        cell.starsLabel.text = "\(repo.stargazers_count)" + "\(repo.stargazers_count > 1 ? " Stars" : " Star")"
        return cell
    }
}

//MARK:- SearchResultBar delegate
extension UserDetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, !text.isEmpty {
            filteredRepos = repos.filter( { $0.name.contains(text.lowercased()) } )
        } else {
            filteredRepos = repos
        }
        tableView.reloadData()
    }
}
