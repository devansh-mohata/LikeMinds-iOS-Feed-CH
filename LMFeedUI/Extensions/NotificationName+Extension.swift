//
//  NotificationName+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 21/05/23.
//

import Foundation

extension Notification.Name {
    static let postCreationCompleted = Notification.Name("Post creation completed")
    static let postCreationStarted = Notification.Name("Post creation started")
    static let refreshHomeFeedData = Notification.Name("Refresh home feed data")
}
