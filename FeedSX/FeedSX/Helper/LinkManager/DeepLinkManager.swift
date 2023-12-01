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
                    // Added this check due to delay in delegate value assign in case of routing from app killed state
                    if LikeMindsFeedSX.shared.delegate != nil {
                        LikeMindsFeedSX.shared.delegate?.routeViewController(viewController: vc)
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            LikeMindsFeedSX.shared.delegate?.routeViewController(viewController: vc)
                        }
                    }
                }
            }
        }
    }
    
    private func initiateFeed(withUUID uuid: String, routeUrl: String, fromNotification: Bool, fromDeeplink: Bool) {
        let uuid = LocalPrefrerences.uuid().isEmpty ? uuid : LocalPrefrerences.uuid()
        guard let user = LocalPrefrerences.getUserData(),
        let apiKey = LocalPrefrerences.userDefault.string(forKey: LocalPreferencesKey.feedApiKey),
        !uuid.isEmpty else { return }
        
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(user.name ?? "")
            .uuid(uuid)
            .isGuest(false)
            .build()
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            print(response)
            guard let user = response.data?.user, let weakSelf = self else { return }
            LocalPrefrerences.saveObject(user, forKey: LocalPreferencesKey.userDetails)
            weakSelf.routeToScreen(routeUrl: routeUrl, fromNotification: fromNotification, fromDeeplink: fromDeeplink)
        }
    }
    
    func notificationRoute(withUUID uuid: String, routeUrl: String, fromNotification: Bool) {
        self.initiateFeed(withUUID: uuid, routeUrl: routeUrl, fromNotification: fromNotification, fromDeeplink: false)
    }
    
    func deeplinkRoute(withUUID uuid: String, routeUrl: String, fromDeeplink: Bool) {
        guard let linkUrl = URL(string: routeUrl),
              let firstPath = linkUrl.path.components(separatedBy: "/").filter({$0 != ""}).first?.lowercased(),
              (firstPath == post || firstPath == postDetail),
              let routeUrl = RouteBuilderManager.buildRouteForPostDetails(url: routeUrl) else {
            return
        }
        self.initiateFeed(withUUID: uuid, routeUrl: routeUrl, fromNotification: false, fromDeeplink: fromDeeplink)
    }
}
