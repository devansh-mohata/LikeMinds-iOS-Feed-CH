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
    var postByUser: PostByUser?
    var imageVideos : [ImageVideo]?
    var attachments: [Attachment]?
    var linkAttachment: LinkAttachment?
    var likedCount: Int
    var caption: String?
    var header: String?
    var commentCount: Int
    var isLiked : Bool
    var isPinned: Bool
    var isEdited: Bool
    var isSaved: Bool
    var postTime: Int
    var postMenuItems: [MenuItem]?
    
    init(post: Post, user: User?, widgets: [String: Widget]?) {
        self.postId = post.id
        self.caption = post.text
        self.header = post.heading
        self.commentCount = post.commentsCount ?? 0
        self.likedCount = post.likesCount ?? 0
        self.isLiked = post.isLiked ?? false
        self.isPinned = post.isPinned ?? false
        self.isSaved = post.isSaved ?? false
        self.isEdited = post.isEdited ?? false
        self.postTime = (post.createdAt ?? 0)/1000
        self.postMenuItems = self.menuItems(post: post)
        self.postByUser = postByUser(user: user)
        self.imageVideos = imageVideoAttachments(post: post, widegts: widgets)
        self.attachments = docAttachments(post: post)
        self.linkAttachment = linkAttachment(post: post)
        self.postMenuItems = menuItems(post: post)
    }
    
    private func docAttachments(post: Post) -> [Attachment]? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType?.rawValue == 3}) else { return nil }
        
        return attachments.map { Attachment(attachmentUrl: $0.attachmentMeta?.attachmentUrl, attachmentType: $0.attachmentMeta?.format, attachmentSize: $0.attachmentMeta?.size, numberOfPages: $0.attachmentMeta?.pageCount, thumbnailUrl: $0.attachmentMeta?.thumbnailUrl, name: $0.attachmentMeta?.name)}
    }
    
    private func imageVideoAttachments(post: Post, widegts: [String: Widget]?) -> [ImageVideo]? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType == .image || $0.attachmentType == .video || $0.attachmentType == .article}) else {
            return nil }
        // mapping article title and body into header and caption 
        if let attchment = attachments.first,
            attchment.attachmentType == .article,
           let widget = widegts?[attchment.attachmentMeta?.entityID ?? ""] {
            self.header = widget.metadata?.title
            self.caption = widget.metadata?.body
        }
        return attachments.map { attachment in
            switch attachment.attachmentType {
            case .article:
                let widget = widegts?[attachment.attachmentMeta?.entityID ?? ""]
                let url = widget?.metadata?.coverImageURL ?? attachment.attachmentMeta?.attachmentUrl
                return ImageVideo(url: url, type: attachment.attachmentMeta?.format, duration: nil, size: widget?.metadata?.size, fileType: .article, name: widget?.metadata?.name, title: widget?.metadata?.title, body: widget?.metadata?.body, entityID: attachment.attachmentMeta?.entityID)
            default:
                let type: PostAttachmentType =  (attachment.attachmentType == .image ? .image : .video)
                let url =  attachment.attachmentMeta?.attachmentUrl
                return ImageVideo(url: url, type: attachment.attachmentMeta?.format, duration: attachment.attachmentMeta?.duration, size: attachment.attachmentMeta?.size, fileType: type, name: attachment.attachmentMeta?.name)
            }
        }
    }
    
    private func linkAttachment(post: Post) -> LinkAttachment? {
        guard let attachments = post.attachments, attachments.contains(where: {$0.attachmentType?.rawValue == 4}) else { return nil }
        return attachments.map { LinkAttachment(title: $0.attachmentMeta?.ogTags?.title, linkThumbnailUrl: $0.attachmentMeta?.ogTags?.image, description: $0.attachmentMeta?.ogTags?.description, url: $0.attachmentMeta?.ogTags?.url)}.first
    }
    
    private func menuItems(post: Post) -> [MenuItem] {
        guard let menuItems = post.menuItems else { return [] }
        return menuItems.map { MenuItem(id: .init(rawValue: $0.id) ?? .unknown, name: $0.title ?? "NA")}
    }
    
    func updatePinUnpinMenu() {
        guard let index = self.postMenuItems?.firstIndex(where: {$0.id == .unpin || $0.id == .pin}) else { return }
        if self.isPinned {
            let menu = MenuItem(id: .unpin, name: "Unpin this Post")
            self.postMenuItems?[index] = menu
        } else {
            let menu = MenuItem(id: .pin, name: "Pin this Post")
            self.postMenuItems?[index] = menu
        }
    }
    
    private func postByUser(user: User?) -> PostByUser? {
        guard let user = user,
              let userId = user.clientUUID else { return  nil }
        let answers = user.questionAnswers?.filter({$0.question?.tag?.lowercased() == "basic" })
        let designation = answers?.filter({$0.question?.state == 1 }).first?.answer?.answer
        let organisation = answers?.filter({$0.question?.state == 0 }).first?.answer?.answer
        
        return PostByUser(name: user.name ?? "",
                          profileImageUrl: user.imageUrl ?? "",
                          customTitle: user.customTitle,
                          uuid: userId,
                          designation: designation,
                          organisation: organisation)
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
        if let attachment = self.imageVideos?.first{return attachment.fileType}
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
        var name: String?
        var title: String?
        var body: String?
        var entityID: String?
        
        func attachmentName() -> String {
            return self.name ?? ((self.url as? NSString)?.lastPathComponent ?? "No name")
        }
        
        func attachmentDetails() -> String {
            let size: Float = Float((self.size ?? 0)/1000)
            let sizeInMb = String(format: "%.2f", (size/1000))
            return "\(sizeInMb)MB"
        }
    }
    struct Attachment {
        var attachmentUrl: String?
        var attachmentType: String?
        var attachmentSize: Int?
        var numberOfPages: Int?
        var thumbnailImage: UIImage?
        var thumbnailUrl: String?
        var name: String?
        
        func attachmentName() -> String {
            return self.name ?? ((self.attachmentUrl as? NSString)?.lastPathComponent ?? "No name")
        }
        
        func attachmentDetails() -> String {
            let size: Float = Float((self.attachmentSize ?? 0)/1000)
            let sizeInMb = String(format: "%.2f", (size/1000))
            let numberOfPagesString = (self.numberOfPages ?? 0) > 0 ? "\(self.numberOfPages ?? 0) Pages • " : ""
            return "\(numberOfPagesString)\(sizeInMb)MB • \(self.attachmentType ?? "")"
        }
    }
    
    struct LinkAttachment {
        var title, linkThumbnailUrl, description, url: String?
    }
    
    struct PostByUser {
        let name: String
        let profileImageUrl: String?
        let customTitle: String?
        let uuid: String
        let designation: String?
        let organisation: String?
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
        case article
        case link
        case unknown = "text"
    }
}
