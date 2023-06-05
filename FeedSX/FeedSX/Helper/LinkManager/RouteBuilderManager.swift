//
//  SwiftRouteBuilder.swift
//  CollabMates
//
//  Created by Uvais Khan on 30/08/20.
//  Copyright © 2020 CollabMates. All rights reserved.
//

import Foundation

class RouteBuilderManager {
    
    class func buildRouteForPostDetails(url: String) -> String? {
        guard let dict = params(fromRoute: url),
              let postId = dict["post_id"] as? String else {return nil}
        let commentId = dict["comment_id"] as? String
        let commentParam = commentId != nil ? "&comment_id=\(commentId ?? "")" : ""
        let route = "route://post?post_id=\(postId)\(commentParam)"
        return route
    }
    
    class func buildRouteForCreatePost() -> String? {
        let route = "route://create_post"
        return route
    }
    
    class func params(fromRoute url: String) -> [AnyHashable : Any]? {
        let urlComponents = NSURLComponents(string: url)
        let queryItems = urlComponents?.queryItems
        var dictionary: [AnyHashable : Any] = [:]
        for item in queryItems ?? [] {
            dictionary[item.name] = (item.value ?? "").replacingOccurrences(of: "%20", with: " ")
        }
        return dictionary
    }
}
