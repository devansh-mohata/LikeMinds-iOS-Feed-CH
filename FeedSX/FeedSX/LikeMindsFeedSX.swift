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

public class LikeMindsFeedSX {
    public static let shared = LikeMindsFeedSX()
    private init() {}
    
    public func configureLikeMindsFeed(extras: LikeMindsFeedExtras) {
        LocalPrefrerences.save(extras.getDeviceId() ?? "" , forKey: LocalPreferencesKey.deviceId)
        LocalPrefrerences.save(extras.getApiKey() , forKey: LocalPreferencesKey.feedApiKey)
        LocalPrefrerences.save(extras.getDomainUrl() ?? "" , forKey: LocalPreferencesKey.clientDomainUrl)
        LMBranding.shared.setBranding(extras.getBrandingData())
        AWSS3Manager.shared.initializeS3()
        let _ = LMFeedClient.builder()
            .lmCallback(extras.likemindsCallback as? LMCallback)
            .build()
    }
    
    public func initiateLikeMindsFeed(withViewController viewController: UIViewController, apiKey: String, username: String, userId: String) {
        
        let request = InitiateUserRequest(apiKey)
            .userName(username)
            .userUniqueId(userId)
            .isGuest(false)
        LMFeedClient.shared.initiateUser(request: request) { [weak self] response in
            print(response)
            guard let user = response.data?.user, let weakSelf = self else {return }
            if response.success == true {
                weakSelf.registerDeviceToken()
            }
            LocalPrefrerences.saveObject(user, forKey: LocalPreferencesKey.userDetails)
            let homeFeedVC = UINavigationController(rootViewController: HomeFeedViewControler())
            homeFeedVC.modalPresentationStyle = .fullScreen
            viewController.navigationController?.present(homeFeedVC, animated: true)
        }
    }

    func registerDeviceToken() {
        guard let deviceid = LocalPrefrerences.userDefault.string(forKey: LocalPreferencesKey.deviceId), !deviceid.isEmpty else {
            print("Device id not available")
            return
        }
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                let request = RegisterDeviceRequest(deviceid, token: token)
                LMFeedClient.shared.registerDevice(request: request) { response in
                    print(response)
                }
            }
        }
    }
    
    func didTapOnNotificationRoute(userInfo: [AnyHashable: Any]) {
//        MixPanelEventTriggerHelper.registerForNotificationClicked(userInfo: userInfo)
//        guard let route = userInfo["route"] as? String, UIApplication.shared.applicationState == .inactive else {return}
//        let pref = PreferencesFactory.userPreferences()
//        pref.put(route, forKey: kPrefNotificationRouteUrl)
//        _ = pref.save()
//        DeepLinkManager.sharedInstance.routeToScreen(routeUrl: route, fromNotification: true, fromDeeplink: false)
    }
    
    /**
     Call this method in AppDelegate in didReceiveRemoteNotification
     @param userInfo The info dict with the push
     */
    public func didReceieveNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard let route = userInfo["route"] as? String, UIApplication.shared.applicationState == .inactive else {return false }
        DeepLinkManager.sharedInstance.notificationRoute(routeUrl: route, fromNotification: true, fromDeeplink: false)
        return true
    }
    
    /**
     Call this method when deeplink decoded url has received
     @param deeplinkRequest: deeplink url with userid and username details
     */
    public func parseDeepLink(routeUrl: String) {
        DeepLinkManager.sharedInstance.deeplinkRoute(routeUrl: routeUrl, fromNotification: false, fromDeeplink: true)
    }
}

/// Initiate LikeMinds extras data model for passing the initial value for sdk initialization
public class LikeMindsFeedExtras {
    
    private var apiKey: String // Api key of sdk
    private var domain: String? // Client domain url
    private var deviceUUID: String? // UUID of device
    weak var likemindsCallback: AnyObject? // LikeMinds callback
    private var branding: SetBrandingRequest = SetBrandingRequest()
    
    /// Initiate method with api key param
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Set the domain url
    public func domainUrl(_ domain: String) -> LikeMindsFeedExtras {
        self.domain = domain
        return self
    }
    
    /// Set the UUID of device
    public func deviceUUID(_ deviceUUID: String) -> LikeMindsFeedExtras {
        self.deviceUUID = deviceUUID
        return self
    }
    
    /// Set the callback
    public func callback(_ callback: AnyObject) -> LikeMindsFeedExtras {
        self.likemindsCallback = callback
        return self
    }
    
    /// Set the callback
    public func setBranding(_ branding: SetBrandingRequest) -> LikeMindsFeedExtras {
        self.branding = branding
        return self
    }
    
    /// get the api key
    func getApiKey() -> String { return self.apiKey }
    /// get the domain url
    func getDomainUrl() -> String? { return self.domain }
    /// get the domain url
    func getDeviceId() -> String? { return self.deviceUUID }
    func getBrandingData() -> SetBrandingRequest { return self.branding }
}
