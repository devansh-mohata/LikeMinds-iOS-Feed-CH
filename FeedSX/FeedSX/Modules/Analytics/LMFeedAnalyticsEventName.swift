//
//  LMFeedAnalyticsEventName.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 17/05/23.
//

import Foundation

struct LMFeedAnalyticsEventName {
    
    struct Notification {
        static let pageOpened = "Notification page opened"
        static let removed = "Notification removed"
        static let muted = "Notification muted"
    }
    
    struct Profile {
        static let aboutSectionViewed = "About section viewed"
        static let postSectionViewed = "Post section viewed"
        static let activitySectionViewed = "Activity section viewed"
        static let savedPostViewed = "Saved post viewed"
    }
    
    struct Feed {
        static let opened = "Feed opened"
    }
    
    struct Post {
        static let creationStarted = "Post creation started"
        static let clickedOnAttachment = "Clicked on Attachment"
        static let creationIncompleted = "Backed from creation page"
        static let userTagged = "User tagged in a post"
        static let linkAttached = "Link attached in the post"
        static let imageAttached = "Image attached to post"
        static let videoAttached = "Video attached to post"
        static let documentAttached = "Document attached in post"
        static let creationCompleted = "Post creation completed"
        static let pinned = "Post pinned"
        static let unpinned = "Post unpinned"
        static let edited = "Post edited"
        static let reported = "Post reported"
        static let deleted = "Post deleted"
        static let userFollowed = "User followed"
        static let likeListOpen = "Like list open"
        static let postLiked = "Post Liked"
        static let postUnliked = "Post Unliked"
    }
    
    struct Comment {
        static let listOpened = "Comment list open"
        static let deleted = "Comment deleted"
        static let reported = "Comment reported"
        static let onPost = "Comment posted"
        static let reply = "Reply posted"
        static let replyDeleted = "Reply deleted"
        static let replyReported = "Reply reported"
        static let liked = "Comment Like"
        static let unliked = "Comment Unlike"
    }
}
