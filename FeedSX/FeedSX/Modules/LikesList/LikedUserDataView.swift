//
//  LikeListDataView.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 11/04/23.
//

import Foundation
import UIKit

struct LikedUserDataView {
    struct LikedUser {
        let username: String
        let profileImage: String
        let userTitle: String
        let isDeleted: Bool
        
        func usernameWithTitle() -> NSAttributedString {
            let nameAttribute = [ NSAttributedString.Key.font: LMBranding.shared.font(16, .medium) ]
            let name = NSMutableAttributedString(string: username, attributes: nameAttribute)
            
            guard !self.userTitle.isEmpty else { return name }
            
            let dotAttribute = [ NSAttributedString.Key.font: LMBranding.shared.font(14, .regular),
                                 NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            let dot = NSMutableAttributedString(string: " • ", attributes: dotAttribute)
            
            let titleAttribute = [ NSAttributedString.Key.font: LMBranding.shared.font(14, .regular),
                                   NSAttributedString.Key.foregroundColor: LMBranding.shared.buttonColor]
            let title = NSMutableAttributedString(string: userTitle, attributes: titleAttribute)
            var mutableString = NSMutableAttributedString(attributedString: name)
            mutableString.append(dot)
            mutableString.append(title)
            return mutableString
        }
    }
}
