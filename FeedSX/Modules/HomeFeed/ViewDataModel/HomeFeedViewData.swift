//
//  HomeFeedViewData.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 29/03/23.
//

import Foundation
import LikeMindsFeed
import UIKit

final class PostFeedDataView {
    var postId: String
    var feedByUser: PostByUser?
    var imageVideos : [ImageVideo]?
    var attachments: [Attachment]?
    var linkAttachment: LinkAttachment?
    var likedCount: Int
    var caption: String?
    var commentCount: Int
    var isLiked : Bool
    var isPinned: Bool
    var isEdited: Bool
    var isSaved: Bool
    var postTime: Int
    var postMenuItems: [MenuItem]?
    
    init(post: Post, user: User?) {
        self.postId = post.id
        self.caption = post.text
        self.commentCount = post.commentsCount ?? 0
        self.likedCount = post.likesCount ?? 0
        self.isLiked = post.isLiked ?? false
        self.isPinned = post.isPinned ?? false
        self.isSaved = post.isSaved ?? false
        self.isEdited = post.isEdited ?? false
        self.postTime = (post.createdAt ?? 0)/1000
        self.postMenuItems = self.menuItems(post: post)
        self.feedByUser = postByUser(user: user)
        self.imageVideos = imageVideoAttachments(post: post)
        self.attachments = docAttachments(post: post)
        self.linkAttachment = linkAttachment(post: post)
        self.postMenuItems = menuItems(post: post)
    }
    
    private func docAttachments(post: Post) -> [Attachment]? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType?.rawValue == 3}) else { return nil }
        
        return attachments.map { Attachment(attachmentUrl: $0.attachmentMeta?.attachmentUrl, attachmentType: $0.attachmentMeta?.format, attachmentSize: $0.attachmentMeta?.size, numberOfPages: $0.attachmentMeta?.pageCount)}
    }
    
    private func imageVideoAttachments(post: Post) -> [ImageVideo]? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType?.rawValue == 1 || $0.attachmentType?.rawValue == 2}) else { return nil }
        return attachments.map { ImageVideo(url: $0.attachmentMeta?.attachmentUrl, type: $0.attachmentMeta?.format, duration: $0.attachmentMeta?.duration, size: $0.attachmentMeta?.size, fileType: $0.attachmentType == .image ? .image : .video)}
    }
    
    private func linkAttachment(post: Post) -> LinkAttachment? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType?.rawValue == 4}) else { return nil }
        return attachments.map { LinkAttachment(title: $0.attachmentMeta?.ogTags?.title, linkThumbnailUrl: $0.attachmentMeta?.ogTags?.image, description: $0.attachmentMeta?.ogTags?.description, url: $0.attachmentMeta?.ogTags?.url)}.first
    }
    
    private func menuItems(post: Post) -> [MenuItem] {
        guard let menuItems = post.menuItems else { return [] }
        return menuItems.map { MenuItem(id: .init(rawValue: $0.id) ?? .unknown, name: $0.title ?? "NA")}
    }
    
    private func postByUser(user: User?) -> PostByUser? {
        guard let user = user,
              let userId = user.userUniqueId else { return  nil }
        return PostByUser(name: user.name ?? "Test",
                          profileImageUrl: user.imageUrl ?? "https://beta-likeminds-media.s3.amazonaws.com/post/c6c4aa41-cdca-4c1d-863c-89c2ea3bc922/SamplePNGImage_20mbmb-1679906349694.png",
                          customTitle: user.customTitle,
                          userId: userId)
    }
    
    func likeCounts() -> String {
        let likePlural = self.likedCount > 1 ? "Likes" : "Like"
        let counts = self.likedCount > 0 ? "\(self.likedCount) \(likePlural)" : "\(likePlural)"
        return counts
    }
    
    func commentCounts() -> String {
        let commentPlural = self.commentCount > 1 ? "Comments" : (self.commentCount > 0 ? "Comment" : "Add Comment")
        let counts = self.commentCount > 0 ? "\(self.commentCount) \(commentPlural)" : "\(commentPlural)"
        return counts
    }
    
    func postAttachmentType() -> PostAttachmentType {
        if (self.imageVideos?.count ?? 0) > 0 {return .image}
        if (self.attachments?.count ?? 0) > 0 {return .document}
        if self.linkAttachment != nil {return .link}
        return .unknown
    }
    
    struct ImageVideo {
        var url: String?
        var type: String?
        var duration: Int?
        var size: Int?
        var fileType: PostAttachmentType
        var thumbnailImage: UIImage?
    }
    struct Attachment {
        var attachmentUrl: String?
        var attachmentType: String?
        var attachmentSize: Int?
        var numberOfPages: Int?
        var thumbnailImage: UIImage?
        
        func attachmentName() -> String {
            return (self.attachmentUrl as? NSString)?.lastPathComponent ?? "No name"
        }
        
        func attachmentDetails() -> String {
            let size = (self.attachmentSize ?? 0)/1000
            let numberOfPagesString = (self.numberOfPages ?? 0) > 0 ? "\(self.numberOfPages ?? 0) Pages • " : ""
            return "\(numberOfPagesString)\(size) Kb • \(self.attachmentType ?? "")"
        }
    }
    
    struct LinkAttachment {
        var title, linkThumbnailUrl, description, url: String?
    }
    
    struct PostByUser {
        let name: String
        let profileImageUrl: String?
        let customTitle: String?
        let userId: String
    }
    
    struct MenuItem {
        enum State: Int {
            case delete = 1
            case pin = 2
            case unpin = 3
            case report = 4
            case edit = 5
            case commentDelete = 6
            case commentReport = 7
            case commentEdit = 8
            case unknown = -1
        }
        let id: State
        let name: String
    }
    
    enum PostAttachmentType: String {
        case image
        case video
        case document
        case link
        case unknown
    }
}
