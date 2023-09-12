//
//  RedirectionManager.swift
//  CollabMates
//
//  Created by Uvais Khan on 27/08/20.
//  Copyright © 2020 CollabMates. All rights reserved.
//

import Foundation
import LikeMindsFeed
import UIKit

@objc class DeepLinkManager: NSObject {
    
    static let sharedInstance = DeepLinkManager()
    var routeUrl: String?
    
    private var supportUrlHosts = ["likeminds.community", "www.likeminds.community", "beta.likeminds.community", "www.beta.likeminds.community", "*", "collabmates.app.link"]
    private var supportSchemes = ["https", "likeminds", "collabmates"]
    
// MARK: - Private Variable (Internal)
    private var post = "post"
    private var postDetail = "post_detail"
    private var createPost = "create_post"
 
// MARK: - Internal func (Rediection  Flow)
    
// MARK:- Go to external Browser
    
    private func gotoExternalBrowser(_ url: String) {
        guard let url = URL(string: url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

   //MARK:- Deeplink SDK route handled
    private func routeToScreen(routeUrl: String, fromNotification: Bool, fromDeeplink: Bool) {
        let routeManager = Routes(route: routeUrl, fromNotification: fromNotification, fromDeeplink: fromDeeplink)
        DispatchQueue.main.async {
            routeManager.fetchRoute { viewController in
                DispatchQueue.main.async {
                    guard let vc = viewController else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        UIViewController.topViewController()?.present(nav, animated: true)
                    }
                }
            }
        }
    }
    
    private func initiateFeed(routeUrl: String, fromNotification: Bool, fromDeeplink: Bool) {
        guard let user = LocalPrefrerences.getUserData(),
        let apiKey = LocalPrefrerences.userDefault.string(forKey: LocalPreferencesKey.feedApiKey) else { return }
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(user.name ?? "")
            .uuid(LocalPrefrerences.uuid())
            .isGuest(false)
            .build()
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            print(response)
            guard let user = response.data?.user, let weakSelf = self else { return }
            LocalPrefrerences.saveObject(user, forKey: LocalPreferencesKey.userDetails)
            weakSelf.routeToScreen(routeUrl: routeUrl, fromNotification: fromNotification, fromDeeplink: fromDeeplink)
        }
    }
    
    func notificationRoute(routeUrl: String, fromNotification: Bool, fromDeeplink: Bool) {
        self.initiateFeed(routeUrl: routeUrl, fromNotification: fromNotification, fromDeeplink: fromDeeplink)
    }
    
    func deeplinkRoute(routeUrl: String, fromNotification: Bool, fromDeeplink: Bool) {
        guard let linkUrl = URL(string: routeUrl),
              let firstPath = linkUrl.path.components(separatedBy: "/").filter({$0 != ""}).first?.lowercased(),
              (firstPath == post || firstPath == postDetail),
              let routeUrl = RouteBuilderManager.buildRouteForPostDetails(url: routeUrl) else {
            return
        }
        self.initiateFeed(routeUrl: routeUrl, fromNotification: fromNotification, fromDeeplink: fromDeeplink)
    }
}
