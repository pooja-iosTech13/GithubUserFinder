# GithubUserFinder

This Project has user search functionality on the first page, User details along with repository list on the second page.
You also get the option to seach for repository.

This POC uses Alamofire for all the network request.
AlamofireImage to download the image from url and add it to the imageView.
Swift Decodable for json parsing.

## Getting Started

Just go ahead and clone the project, althogh I have used cocoa pods but you don't have to pull anything as its already been commited
and part of this project.

## Architecture & Design pattern

Popular MVC as an architectural design pattern, Single responsibilty principle

## Folder Structure

* Models - Users, UserDetails, Repo
* Servies - ServiceManager
* UserSearch Module - ViewController, Cell
* UserDetail Module -ViewController, Cell
* Utils

## Let's start with code..

### 1. ViewController (search users)

```
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
```

### 2. TableView Cell (UserCell.swift)

```
import UIKit
import AlamofireImage

class UserCell: UITableViewCell {

    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var repoLable: UILabel!
    
    private enum constants {
        static let placeholderImageName = "placeholder"
    }
    
    func populate(user: User) {
        nameLabel.text = user.login
        let placeholderImage = UIImage(named: constants.placeholderImageName)
        if let imageUrl = URL(string: user.avatarUrl) {
            userImageView.af.setImage(withURL: imageUrl, cacheKey: "\(AppConstants.kCacheImagekey)\(user.id)", placeholderImage: placeholderImage);
        }
    }
}
```

### 3. Service Manager (ServiceManager.swift)

```
import Foundation
import Alamofire

enum ServiceType {
    case users
    case details
    case repos
}

class ServiceManager {
    
    typealias CompletionHandler = (_ response:Any?) -> Void
    
    private static let baseUrl = "https://api.github.com/"
    
    // Add your client Id and client secret here..
    private static let clientId = ""
    private static let clientSecret = ""
    
    private static func getMethod(type: ServiceType) -> String {
        switch type {
        case .users:
            return "search/users?q="
        case .details, .repos:
            return "users/"
        }
    }
    
    private static func clientIdSecret() -> String {
        //Add your client Id and client secret if you hit max hour limit which is only
        // 50-60 request per hour. And enable this.
        //return "&client_id=\(ServiceManager.clientId)&client_secret=\(ServiceManager.clinetSecret)"
        return ""
    }
    
    public static func getUsers(for query: String, completion: @escaping CompletionHandler) {
        let url = baseUrl + getMethod(type: .users) + query + clientIdSecret()
        AF.request(url, parameters: nil).validate()
            .responseDecodable(of: SearchResponse.self) { response in
                guard let result = response.value else {
                    //TODO:- Currently the errors are not handled.
                    return
                }
                completion(result)
        }
    }
    
    public static func getDetails(for query: String, completion: @escaping CompletionHandler) {
        let url = baseUrl + getMethod(type: .details) + query
        AF.request(url, parameters: nil).validate()
            .responseDecodable(of: UserDetails.self) { response in
                guard let result = response.value else { return }
                completion(result)
        }
    }
    
    public static func getRepos(for query: String, completion: @escaping CompletionHandler) {
        let url = baseUrl + getMethod(type: .repos) + query + "/repos"
        AF.request(url, parameters: nil).validate()
            .responseDecodable(of: [Repo].self) { response in
                guard let result = response.value else { return }
                completion(result)
        }
    }
    
}
```

### 4. Model (Users.swift)

```
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
```








