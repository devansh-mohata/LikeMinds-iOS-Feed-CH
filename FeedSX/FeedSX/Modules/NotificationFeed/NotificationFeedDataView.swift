//
//  NotificationFeedDataView.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 15/06/23.
//

import Foundation
import LikeMindsFeed

class NotificationFeedDataView {
    let activity: Activity
    let user: User?
    var isRead: Bool
    
    init(activity: Activity, user: User?) {
        self.activity = activity
        self.user = user
        self.isRead = activity.isRead ?? false
    }
}
