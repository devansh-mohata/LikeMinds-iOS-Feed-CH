//
//  TagUserModel.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 03/09/23.
//

import Foundation

class TaggedUser {
    var user: TaggingUser
    var range: NSRange
    init(_ user: TaggingUser, range: NSRange) {
        self.user = user
        self.range = range
    }
}

class TaggingUser {
    var name: String?
    var id: String
    
    init(name: String?, id: String?) {
        self.name = name
        self.id = id ?? ""
    }
}
