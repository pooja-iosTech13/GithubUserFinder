//
//  ViewController.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    var users: [User] = []
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //MARK:- Setup
    private func setUpTableView() {
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search Users"
    }
    
    //MARK:- SearchBar Validator
    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    private func searchUsers(for name: String) {
        ServiceManager.getUsers(for: name) { (response) in
            guard let response = response as? SearchResponse else { return }
            print(response.users)
            //TODO:- use weak self
            self.users = response.users
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            guard let destinationVC = segue.destination as? UserDetailViewController else {
                return
            }
            destinationVC.user = sender as? User
        }
    }
    
}

//MARK:- TableView datasource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.nameLabel.text = user.login
        let placeholderImage = UIImage(named: "placeholder")
        if let imageUrl = URL(string: user.avatarUrl) {
            cell.userImageView.af.setImage(withURL: imageUrl, cacheKey: "CacheUserImageKey\(user.id)", placeholderImage: placeholderImage);
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "detailSegue", sender: users[indexPath.row]);
    }
}

//MARK:- SearchResultBar delegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, !text.isEmpty {
            searchUsers(for: text)
        } else {
            users = []
            tableView.reloadData()
        }
    }
}

