//
//  ServiceManager.swift
//  GithubUserFinder
//
//  Created by POOJA on 31/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//


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
