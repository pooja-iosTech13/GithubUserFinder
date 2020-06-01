//
//  ViewController.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    //datasource
    private var users: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private enum constants {
        static let userCellNibName = "UserCell"
        static let cellReuseIdentifier = "Cell"
        static let searchUsersPlaceholderText = "Search Users"
        static let segueIdentifier = "detailSegue"
        static let placeholderImageName = "placeholder"
    }
    
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
        tableView.register(UINib(nibName: constants.userCellNibName, bundle: nil), forCellReuseIdentifier: constants.cellReuseIdentifier)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = constants.searchUsersPlaceholderText
    }
    
    private func searchUsers(for name: String) {
        ServiceManager.getUsers(for: name) {[weak self] (response) in
            guard let self = self else { return }
            guard let response = response as? SearchResponse else { return }
            self.users = response.users
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.segueIdentifier {
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
        guard let cell: UserCell = tableView.dequeueReusableCell(withIdentifier: constants.cellReuseIdentifier, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.populate(user: user)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: constants.segueIdentifier, sender: users[indexPath.row]);
    }
}

//MARK:- SearchResultBar delegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, !text.isEmpty {
            searchUsers(for: text)
        } else {
            users = []
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
