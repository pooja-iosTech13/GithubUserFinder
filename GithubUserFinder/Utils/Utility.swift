//
//  Constants.swift
//  GithubUserFinder
//
//  Created by POOJA on 31/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

import Foundation


class AppConstants {
    
    static let kCacheImagekey = "CacheUserImageKey"
}

class AppDateFormatter {
    // Need refactoring
    static func formatedDateString(stringDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: stringDate) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
}
