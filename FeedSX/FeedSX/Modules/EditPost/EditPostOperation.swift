//
//  EditPostOperation.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 06/06/23.
//

import Foundation
import LikeMindsFeed
import UIKit
import AVFoundation

class EditPostOperation {
    
    static let shared = EditPostOperation()
    var attachmentList: [AWSFileUploadRequest]?
    let dispatchGroup = DispatchGroup()
    private init(){}
    
    private func postMessageForCompleteEditPost(with error: Any?) {
        NotificationCenter.default.post(name: .postEditCompleted, object: error)
    }
    
    private func postMessageForEditingPost(with object: Any? = nil) {
        let attachment = attachmentList?.first
        NotificationCenter.default.post(name: .postEditStarted, object: attachment?.thumbnailImage)
    }
    
    func editPost(request: EditPostRequest, postId: String) {
        postMessageForEditingPost()
        LMFeedClient.shared.editPost(request) { [weak self] response in
            self?.attachmentList = nil
            if response.success == false {
                self?.postMessageForCompleteEditPost(with: response.errorMessage)
            }
            guard let postDetails = response.data?.post, let users =  response.data?.users else {
                self?.postMessageForCompleteEditPost(with: response.errorMessage)
                return
            }
            
            self?.postMessageForCompleteEditPost(with: PostFeedDataView(post: postDetails, user: users[postDetails.uuid ?? ""], widgets: response.data?.widgets))
        }
    }
    
    func editPostWithAttachment(attachments:  [AWSFileUploadRequest], postCaption: String?, heading: String, postId: String, postType: EditPostViewModel.AttachmentUploadType) {
        self.attachmentList = attachments
        guard let newAttachments = self.attachmentList?.filter({($0.awsUploadedUrl ?? "").isEmpty}), newAttachments.count > 0 else {
            postMessageForEditingPost()
            self.editPostWithAttachments(postId: postId, postCaption: postCaption, heading: heading, postType: postType)
            return
        }
        postMessageForEditingPost()
        for attachment in newAttachments {
            dispatchGroup.enter()
            switch attachment.fileType {
            case .image:
                guard let url = URL(string: attachment.fileUrl),
                      let data = try? Data(contentsOf:url),
                      let image = UIImage(data: data)
                else {
                    print("Unable to upload image.. \(attachment.fileUrl)")
                    return
                }
                AWSUploadManager.sharedInstance.awsUploader(uploaderType: .image, filePath: attachment.awsFilePath, image: image, thumbNailUrl: nil,index: attachment.index) { (progress) in
                    print("Image - \(attachment.index) upload progress...\(progress)")
                } completion: {[weak self] (imageResponse,thumbnailUrl, error, nil)  in
                    print(imageResponse)
                    attachment.awsUploadedUrl = (imageResponse as? String) ?? ""
                    self?.dispatchGroup.leave()
                }
            case .video:
                guard let url = URL(string: attachment.fileUrl)
                else {
                    print("Unable to upload video.. \(attachment.fileUrl)")
                    return
                }
                AWSUploadManager.sharedInstance.awsUploader(uploaderType: .video, filePath: attachment.awsFilePath, path: url.path , thumbNailUrl: nil, index: attachment.index ) { (progress) in
                    print("video - \(attachment.index) upload progress...\(progress)")
                } completion: {[weak self] (videoResponse, thumbnailUrl, error, nil)  in
                    print(videoResponse)
                    attachment.awsUploadedUrl = (videoResponse as? String) ?? ""
                    self?.dispatchGroup.leave()
                }
            case .file:
                AWSUploadManager.sharedInstance.awsUploader(uploaderType: .file, filePath: attachment.awsFilePath, path: attachment.fileUrl, thumbNailUrl: nil, index: attachment.index ) { (progress) in
                    print("file - \(attachment.index) upload progress...\(progress)")
                } completion: {[weak self] (fileResponse, thumbnailUrl, error, nil)  in
                    print(fileResponse)
                    attachment.awsUploadedUrl = (fileResponse as? String) ?? ""
                    self?.dispatchGroup.leave()
                }
            default:
                break
            }
        }
        self.dispatchGroup.notify(queue: DispatchQueue.global()) { [weak self] in
            self?.editPostWithAttachments(postId: postId, postCaption: postCaption, heading: heading, postType: postType)
        }
    }
    
    private func editPostWithAttachments(postId: String, postCaption: String?, heading: String, postType: EditPostViewModel.AttachmentUploadType) {
        guard let attachmentList = self.attachmentList else {return}
        if attachmentList.count > 0 {
            var attachments: [Attachment] = []
            for attachedItem in attachmentList {
                switch attachedItem.fileType {
                case .image:
                    switch postType {
                    case .article:
                        let imageAttachment = self.articleImageAttachmentData(attachment: attachedItem)
                        attachments.append(imageAttachment)
                    default:
                        let imageAttachment = self.imageAttachmentData(attachment: attachedItem)
                        attachments.append(imageAttachment)
                    }
                case .video:
                     let videoAttachment = self.videoAttachmentData(attachment: attachedItem)
                    attachments.append(videoAttachment)
                case .file:
                     let docAttachment = self.fileAttachmentData(attachment: attachedItem)
                    attachments.append(docAttachment)
                default:
                    break
                }
            }
            let editPostRequest = EditPostRequest.builder()
                .postId(postId)
                .attachments(attachments)
                .build()
            if postType != .article {
                _ = editPostRequest.text(postCaption)
                _ = editPostRequest.heading(heading)
            }
            LMFeedClient.shared.editPost(editPostRequest) { [weak self] response in
                self?.attachmentList = nil
                if response.success == false {
                    self?.postMessageForCompleteEditPost(with: response.errorMessage)
                }
                guard let postDetails = response.data?.post, let users =  response.data?.users else {
                    self?.postMessageForCompleteEditPost(with: response.errorMessage)
                    return
                }
                self?.postMessageForCompleteEditPost(with: PostFeedDataView(post: postDetails, user: users[postDetails.uuid ?? ""], widgets: response.data?.widgets))
            }
        }
    }
    
    private func imageAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int? = attachment.documentAttachmentSize
        if size == nil, let attr = try? FileManager.default.attributesOfItem(atPath: attachment.fileUrl) {
            size = attr[.size] as? Int
        }
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(attachment.awsUploadedUrl ?? "")
            .size(size ?? 0)
            .name(attachment.name)
        let attachmentRequest = Attachment()
            .attachmentType(.image)
            .attachmentMeta(attachmentMeta)
        return attachmentRequest
    }
    
    private func fileAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int? = attachment.documentAttachmentSize
        var numberOfPages: Int? = attachment.documentNumberOfPages
        guard let fileUrl = URL(string: attachment.fileUrl) else { return Attachment() }
        if (numberOfPages == nil || numberOfPages == 0), let pdf = CGPDFDocument(fileUrl as CFURL) {
            print("number of page: \(pdf.numberOfPages)")
            numberOfPages = pdf.numberOfPages
        }
        if let attr = try? FileManager.default.attributesOfItem(atPath: fileUrl.relativePath) {
            size = attr[.size] as? Int
        }
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(attachment.awsUploadedUrl ?? "")
            .size(size ?? 0)
            .name(attachment.name)
            .pageCount(numberOfPages ?? 0)
            .format("pdf")
        let attachmentRequest = Attachment()
            .attachmentType(.doc)
            .attachmentMeta(attachmentMeta)
        return attachmentRequest
    }
    
    private func videoAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.fileUrl) {
            size = attr[.size] as? Int
        }
        guard let url = URL(string: attachment.fileUrl) else { return Attachment()}
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        let attachmentMeta = AttachmentMeta()
            .attachmentUrl(attachment.awsUploadedUrl ?? "")
            .size(size ?? 0)
            .name(attachment.name)
            .duration(Int(durationTime))
        let attachmentRequest = Attachment()
            .attachmentType(.video)
            .attachmentMeta(attachmentMeta)
        return attachmentRequest
    }
    
    private func articleImageAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int? = attachment.documentAttachmentSize
        if size == nil, let attr = try? FileManager.default.attributesOfItem(atPath: attachment.fileUrl) {
            size = attr[.size] as? Int
        }
        let attachmentMeta = AttachmentMeta()
            .coverImageUrl(attachment.awsUploadedUrl ?? "")
            .size(size ?? 0)
            .name(attachment.name)
            .title(attachment.title ?? "")
            .body(attachment.body ?? "")
            .entityID(attachment.entityID ?? "")
        let attachmentRequest = Attachment()
            .attachmentType(.article)
            .attachmentMeta(attachmentMeta)
        return attachmentRequest
    }
    
}

