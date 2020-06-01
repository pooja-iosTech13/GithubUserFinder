//
//  UserCell.swift
//  GithubUserFinder
//
//  Created by POOJA on 30/05/20.
//  Copyright © 2020 POOJA. All rights reserved.
//

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
