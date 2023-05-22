//
//  PostDetailDataModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 10/04/23.
//

import Foundation
import LMFeed

class PostDetailDataModel {
    
    class Comment {
        var commentId: String
        var postId: String?
        var likedCount: Int
        var text: String?
        var commentCount: Int
        var isLiked : Bool
        var isEdited: Bool
        var createdAt: Int
        var level: Int?
        var menuItems: [PostFeedDataView.MenuItem]?
        var replies: [Comment] = []
        var user: PostFeedDataView.PostByUser
        
        init(comment: LMFeed.Comment, user: User?) {
            self.commentId = comment.id
            self.postId = comment.postId
            self.text = comment.text
            self.commentCount = comment.commentsCount ?? 0
            self.likedCount = comment.likesCount ?? 0
            self.isLiked = comment.isLiked ?? false
            self.isEdited = comment.isEdited ?? false
            self.level = comment.level
            self.createdAt = (comment.createdAt ?? 0)/1000
            self.menuItems = comment.menuItems?.compactMap({PostFeedDataView.MenuItem(id: .init(rawValue: $0.id) ?? .unknown, name: $0.title ?? "")})
            self.user = .init(name: user?.name ?? "", profileImageUrl: user?.imageUrl, customTitle: user?.customTitle, userId: user?.userUniqueId ?? "")
        }
        
        func likeCounts() -> String {
            let likePlural = self.likedCount > 1 ? "Likes" : "Like"
            let counts = self.likedCount > 0 ? "\(self.likedCount) \(likePlural)" : ""
            return counts
        }
        
        func repliesCounts() -> String {
            let replyPlural = self.commentCount > 1 ? "Replies" : "Reply"
            let counts = self.commentCount > 0 ? "\(SpecialCharString.centerDot) \(self.commentCount) \(replyPlural)" : ""
            return counts
        }
    }
    
}
