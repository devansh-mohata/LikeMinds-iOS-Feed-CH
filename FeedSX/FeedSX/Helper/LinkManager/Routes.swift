//
//  Routes.swift
//  CollabMates
//
//  Created by Uvais Khan on 27/08/20.
//  Copyright © 2020 CollabMates. All rights reserved.
//

import Foundation
import UIKit

struct RouteTriggerProperties {
    var triggerSource:String
    var fromDeepLink: Bool
    var fromNotification: Bool
    var fromShareThirdParty:Bool = false
}

@objcMembers class Routes: NSObject {

    enum RouteHostURL: String {
        case routeToPost = "post"
        case routeToPostDetail = "post_detail"
        case routeToCreatePost = "create_post"
    }
    
    
    private var route: String?
    private var fromNotification = false
    private var fromDeeplink = false
    private var triggerSource = ""
    
    init(route: String?, source: String = "") {
        super.init()
        self.route = route
        self.triggerSource = source
       }

    init(route: String?, fromNotification: Bool, fromDeeplink: Bool, source: String = "") {
        super.init()
        self.route = route
        self.fromNotification = fromNotification
        self.fromDeeplink = fromDeeplink
        self.triggerSource = source
    }
    func fetchRouteHostURL() -> RouteHostURL? {
        guard let rt = route else {return nil}
        route = rt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let routeUrl = URL(string: route ?? ""),
              let host = routeUrl.host,
              let routeHostURL = RouteHostURL(rawValue: host) else {return nil}
        return routeHostURL
    }
    func implementedRoutes() -> Bool {
        guard let rt = route else {return false}
        route = rt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let routeUrl = URL(string: route ?? ""),
              let host = routeUrl.host,
              let routeHostURL = RouteHostURL(rawValue: host) else {return false}
        
        switch routeHostURL {
        case .routeToPostDetail,
             .routeToCreatePost:
            return true
        default:
            return false
        }
    }
    func fetchRoute(withCompletion completion: @escaping (UIViewController?) -> Void) {
        if route == nil {
            completion(nil)
            return
        }
        
        if let rt = route {
            route = rt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
        guard let routeUrl = URL(string: route ?? ""),
              let host = routeUrl.host,
              let routeHostURL = RouteHostURL(rawValue: host) else {
            completion(nil)
            return
        }

        switch routeHostURL {
        case .routeToCreatePost:
            break
        case .routeToPost,
             .routeToPostDetail:
            getRouteToPostDetails(withCompletion: completion)
        default:
            completion(nil)
        }
    }
    
    func getRouteToPostDetails(withCompletion completion: @escaping (UIViewController?) -> Void)   {
        let params = self.params(fromRoute: route)
        var postId: String? = nil
        var commentId: String? = nil
        
        if let id = params?["post_id"] as? String {
            postId = id
        }
        if let id = params?["comment_id"] as? String {
            commentId = id
        }
        guard let postId = postId else  {return completion(nil) }
        let postDetail = PostDetailViewController(nibName: "PostDetailViewController", bundle: Bundle(for: PostDetailViewController.self))
        postDetail.postId = postId
        postDetail.commentId = commentId
        completion(postDetail)
    }
    
    func params(fromRoute route: String?) -> [AnyHashable : Any]? {
        let urlComponents = NSURLComponents(string: self.route ?? "")
        let queryItems = urlComponents?.queryItems
        var dictionary: [AnyHashable : Any] = [:]
        for item in queryItems ?? [] {
            guard let item = item as? NSURLQueryItem else {
                continue
            }
            dictionary[item.name] = (item.value ?? "").replacingOccurrences(of: "%20", with: " ")
        }
        return dictionary
    }

}

