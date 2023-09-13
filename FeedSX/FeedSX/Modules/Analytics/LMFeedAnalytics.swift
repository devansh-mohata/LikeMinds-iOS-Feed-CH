//
//  LMFeedAnalytics.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 17/05/23.
//

import Foundation

public protocol LMFeedAnalyticsDelegate: AnyObject {
    func trackLMFeedAnalyticsEvent(withName eventName: String, eventProperties properties: [String: Any]?)
}

public class LMFeedAnalytics {
    
    public static let shared = LMFeedAnalytics()
    weak var delegate: LMFeedAnalyticsDelegate?
    
    private init() {}
    
    @objc func track(eventName: String, eventProperties: [String: Any]?) {
        let eventname = "LM - \(eventName)"
        print("\(eventname) - \(eventProperties)")
        delegate?.trackLMFeedAnalyticsEvent(withName: eventName, eventProperties: eventProperties)
    }
    
    public func delegate(_ delegate: LMFeedAnalyticsDelegate) {
        self.delegate = delegate
    }
    
}
