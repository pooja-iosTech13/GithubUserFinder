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
    
    private var repos: [Repo] = []
    private var filteredRepos: [Repo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    enum constants {
        static let repoCellNibName = "RepoCell"
        static let followersText = "Followers"
        static let followingText = "Following"
        static let reposText = "Repos"
        static let searchUsersPlaceholderText = "Search for User's Repositories"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Intial Setup
        setupSearchBar()
        setUpTableView()
        
        // This image can also be passed from previous VC but I think its okay as I'm caching image data.
        if let imageUrl = URL(string: user.avatarUrl) {
            userImageView.af.setImage(withURL: imageUrl, cacheKey: "\(AppConstants.kCacheImagekey)\(user.id)")
        }
        // placing cuncurrent call to fetch details and repos.
        getDetails(for: user)
        getRepos(for: user)
    }
    
    //MARK:- Setup
    private func setUpTableView() {
        tableView.register(UINib(nibName: constants.repoCellNibName, bundle: nil), forCellReuseIdentifier: constants.repoCellNibName)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = constants.searchUsersPlaceholderText
    }
    
    private func displayUserDetails(userDetails: UserDetails) {
        //If userDetails doesn't have name then use user.login become name
        nameLabel.text = userDetails.name ?? user.login
        emailLabel.text = userDetails.email ?? ""
        // Assumption: 'created_at' is used as join data
        joinDateLabel.text = AppDateFormatter.formatedDateString(stringDate: userDetails.created_at)
        locationLabel.text = userDetails.location ?? ""
        followersLable.text = "\(userDetails.followers ?? 0) \(constants.followersText)"
        followingLabel.text = "\(constants.followingText) \(userDetails.following ?? 0)"
        reposCountLabel.text = "\(userDetails.public_repos ?? 0) \(constants.reposText)"
        //TODO:- on multiline bioLable text table content offset needs to be adjusted
        bioLabel.text = userDetails.bio ?? ""
    }
    
    //MARK:- Service api call
    private func getDetails(for user: User) {
        ServiceManager.getDetails(for: user.login) {[weak self] (response) in
            guard let self = self else { return }
            guard let userDetails = response as? UserDetails else { return }
                self.displayUserDetails(userDetails: userDetails)
        }
    }
    
    private func getRepos(for user: User) {
        ServiceManager.getRepos(for: user.login) {[weak self] (response) in
            guard let self = self else { return }
            guard let repos = response as? [Repo] else { return }
                self.repos = repos
                self.filteredRepos = repos
        }
    }
}

//MARK:- TableView datasource
extension UserDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRepos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: RepoCell = tableView.dequeueReusableCell(withIdentifier: constants.repoCellNibName, for: indexPath) as? RepoCell else {
            return UITableViewCell()
        }
        let repo = filteredRepos[indexPath.row]
        cell.populate(repo: repo)
        return cell
    }
}

//MARK:- TableView delegate
extension UserDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let repo = repos[indexPath.row]
        //Open git repo page on web
        if let link = URL(string: repo.html_url) {
            UIApplication.shared.open(link)
        } else {
            //TODO:- Handle error
        }
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
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
