//
//  LMFeedAnalytics.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 17/05/23.
//

import Foundation

class LMFeedAnalytics {
    
    static let shared = LMFeedAnalytics()
    
    private init() {}
    
    @objc func track(eventName: String, eventProperties: [String: Any]?) {
        
        let eventname = "LM - \(eventName)"
        print("\(eventname) - \(eventProperties)")
//        if let props = properties {
//            LikeMinds.shared.delegate?.eventFiredCallback(eventName: eventname, properties: props)
//        }
//        analyticHelper?.trackEvent(eventName: eventname, properties: properties)
    }
    
}
