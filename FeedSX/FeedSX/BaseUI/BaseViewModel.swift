//
//  BaseViewModel.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 04/06/23.
//

import Foundation

class BaseViewModel {
    
    func postErrorMessageNotification(error: String?) {
        NotificationCenter.default.post(name: .errorInApi, object: error)
    }
    
}
