//
//  LikeMindsFeedSX.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 30/05/23.
//

import Foundation
import UIKit
import LikeMindsFeed
import FirebaseMessaging

public protocol LikeMindsFeedSXCallback: AnyObject {
    func openProfile(userUUID: String)
    func routeViewController(viewController: UIViewController?)
}

extension LikeMindsFeedSXCallback {
    func routeViewController(viewController: UIViewController?) {}
    func openProfile(userUUID: String) {}
}

public class LikeMindsFeedSX {
    public static let shared = LikeMindsFeedSX()
    private init() {}
    public weak var delegate: LikeMindsFeedSXCallback?
    
    public func configureLikeMindsFeed(lmCallback: LMCallback?, branding: SetBrandingRequest = SetBrandingRequest()) {
        LMBranding.shared.setBranding(branding)
        AWSS3Manager.shared.initializeS3()
        let _ = LMFeedClient.builder()
            .lmCallback(lmCallback)
            .build()
    }
    
    public func initiateLikeMindsFeed(withViewController viewController: UIViewController, apiKey: String, username: String, userId: String, deviceId: String?) {
        
        let request = InitiateUserRequest.builder()
            .apiKey(apiKey)
            .userName(username)
            .uuid(userId)
            .isGuest(false)
            .build()
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            print(response)
            guard let user = response.data?.user, let weakSelf = self else {
                viewController.presentAlert(message: response.errorMessage ?? "")
                return
            }
            if response.data?.appAccess == false {
                self?.logout(response.data?.refreshToken ?? "", deviceId: deviceId ?? "")
                return
            }
            LocalPrefrerences.save(apiKey, forKey: LocalPreferencesKey.feedApiKey)
            if response.success == true {
                weakSelf.registerDeviceToken(deviceid: deviceId)
            }
            LocalPrefrerences.saveObject(user, forKey: LocalPreferencesKey.userDetails)
            weakSelf.getCommunityConfiguration()
            let homeFeedVC = HomeFeedViewControler()
            viewController.addChild(homeFeedVC)
            viewController.view.addSubview(homeFeedVC.view)
            homeFeedVC.didMove(toParent: viewController)
        }
    }

    func registerDeviceToken(deviceid: String?) {
        guard let deviceid = deviceid, !deviceid.isEmpty else {
            print("Device id not available")
            return
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                let request = RegisterDeviceRequest.builder()
                    .token(token)
                    .deviceId(deviceid)
                    .build()
                LMFeedClient.shared.registerDevice(request: request) { response in
                    print(response)
                }
            }
        }
    }
    
    func getCommunityConfiguration() {
        LMFeedClient.shared.getCommunityConfiguration(GetCommunityConfigurationRequest.builder()) { response in
            guard let configurations = response.data?.communityConfigurations else {
                return
            }
            print("------Configuration Data----- \(configurations)")
            LocalPrefrerences.saveObject(configurations, forKey: LocalPreferencesKey.communityConfigurations)
        }
    }
    
    /**
     Call this method in AppDelegate in didReceiveRemoteNotification
     @param userInfo The info dict with the push
     */
    @discardableResult
    public func didReceieveNotification(userInfo: [AnyHashable: Any], withUUID uuid: String) -> Bool {
        guard let route = userInfo["route"] as? String else {return false }
        DeepLinkManager.sharedInstance.notificationRoute(withUUID: uuid, routeUrl: route, fromNotification: true)
        return true
    }
    
    /**
     Call this method when deeplink decoded url has received
     @param deeplinkRequest: deeplink url with userid and username details
     */
    public func parseDeepLink(routeUrl: String, withUUID uuid: String) {
        DeepLinkManager.sharedInstance.deeplinkRoute(withUUID: uuid, routeUrl: routeUrl, fromDeeplink: true)
    }
    
    public func logout(_ refreshToken: String, deviceId: String) {
        let request = LogoutRequest.builder()
            .refreshToken(refreshToken)
            .deviceId(deviceId)
            .build()
        LMFeedClient.shared.logout(request: request) { response in
            // do somthing on success or failure
        }
    }
    
    public func disbleIQKeyboardForViewController() -> [UIViewController.Type] {
        return [EditPostViewController.self,
                CreatePostViewController.self,
                PostDetailViewController.self]
    }
}

