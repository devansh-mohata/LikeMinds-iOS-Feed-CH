//
//  LikeMindsFeedExtras.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 28/06/23.
//

import Foundation

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
