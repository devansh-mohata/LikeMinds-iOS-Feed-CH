//
//  EditPostViewModel.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 04/06/23.
//

import Foundation
import PDFKit
import LikeMindsFeed
import AVFoundation

protocol EditPostViewModelDelegate: AnyObject {
    func reloadCollectionView()
    func reloadActionTableView()
    func didReceivedPostDetails()
}

final class EditPostViewModel: BaseViewModel {
    
    var imageAndVideoAttachments: [PostFeedDataView.ImageVideo] = []
    var documentAttachments: [PostFeedDataView.Attachment] = []
    var linkAttatchment: PostFeedDataView.LinkAttachment?
    let attachmentUploadTypes: [AttachmentUploadType] = [.image, .video, .document]
    var currentSelectedUploadeType: EditPostViewModel.AttachmentUploadType = .unknown
    weak var delegate: EditPostViewModelDelegate?
    var taggedUsers: [TaggedUser] = []
    var postId: String = ""
    var postDetail: PostFeedDataView?
    private let filePath = "files/post/\(LocalPrefrerences.getUserData()?.clientUUID ?? "user")/"
    
    enum AttachmentUploadType: String {
        case document = "Edit PDF Resource"
        case image = "Edit Photo Resource"
        case video = "Edit Video Resource"
        case link = "Edit Link Resource"
        case article = "Edit Article"
        case dontAttachOgTag
        case unknown
    }
    
    func editResourceType() -> AttachmentUploadType? {
        switch self.postDetail?.postAttachmentType() {
        case .article:
            return .article
        case .image:
            return .image
        case .video:
            return .video
        case .link:
            return .link
        case .document:
            return .document
        default:
            return .unknown
        }
    }
    
    func getPost() {
        let request = GetPostRequest.builder()
            .postId(self.postId)
            .page(1)
            .pageSize(1)
            .build()
        LMFeedClient.shared.getPost(request) {[weak self] response in
            if response.success == false {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            guard let postDetails = response.data?.post, let users =  response.data?.users else {
                self?.postErrorMessageNotification(error: response.errorMessage)
                return
            }
            self?.postDetail = PostFeedDataView(post: postDetails, user: users[postDetails.uuid ?? ""], widgets: response.data?.widgets)
            self?.postDetailsAttachments()
        }
    }
    
    private func postDetailsAttachments() {
        if let attachments = self.postDetail?.attachments, !attachments.isEmpty {
            documentAttachments.append(contentsOf: attachments)
            self.currentSelectedUploadeType = .document
        }
        
        if let attachments = self.postDetail?.imageVideos, !attachments.isEmpty {
            imageAndVideoAttachments.append(contentsOf: attachments)
            self.currentSelectedUploadeType = attachments.first?.fileType == .image ? .image : .video
        }
        
        if let attachment = self.postDetail?.linkAttachment {
            self.linkAttatchment = attachment
            self.currentSelectedUploadeType = .link
        }
        self.delegate?.didReceivedPostDetails()
    }
    
    func addDocumentAttachment(fileUrl: URL) {
        guard let docData = try? Data(contentsOf: fileUrl) else { return }
        try? docData.write(to: fileUrl)
        var attachment = PostFeedDataView.Attachment(attachmentUrl: fileUrl.path, attachmentType: "PDF", attachmentSize: 0, numberOfPages: 0)
        if let pdf = CGPDFDocument(fileUrl as CFURL) {
            print("number of page: \(pdf.numberOfPages)")
            attachment.numberOfPages = pdf.numberOfPages
        }
        if let attr = try? FileManager.default.attributesOfItem(atPath: fileUrl.relativePath) {
            attachment.attachmentSize = attr[.size] as? Int
        }
        if let image = generatePdfThumbnail(of: CGSize(width: 100, height: 100), for: fileUrl, atPage: 0){
            attachment.thumbnailImage = image
        }
        attachment.name = fileUrl.pathComponents.last ?? "attachment_\(Date().millisecondsSince1970)"
        self.documentAttachments.append(attachment)
        self.delegate?.reloadCollectionView()
    }
    
    func addImageVideoAttachment(fileUrl: URL, type: AttachmentUploadType) {
        var attachment = PostFeedDataView.ImageVideo(fileType: type == .image ? .image : .video)
        attachment.url = fileUrl.absoluteString
        attachment.type = fileUrl.pathExtension
        if let attr = try? FileManager.default.attributesOfItem(atPath: fileUrl.relativePath) {
            attachment.size = attr[.size] as? Int
        }
        if type == .image {
            attachment.thumbnailImage = UIImage(contentsOfFile: fileUrl.path)
        } else {
            attachment.thumbnailImage = generateVideoThumbnail(forUrl: fileUrl)
        }
        attachment.name = fileUrl.pathComponents.last ?? "media_\(Date().millisecondsSince1970)"
        self.imageAndVideoAttachments.append(attachment)
    }
    
    private func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    private func generateVideoThumbnail(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    func parseMessageForLink(message: String) {
        guard let link = message.detectedFirstLink, currentSelectedUploadeType != .dontAttachOgTag else {
            self.linkAttatchment = nil
            self.delegate?.reloadCollectionView()
            return
        }
        decodeUrl(stringUrl: link)
    }
    
    func verifyOgTagsAndEditPost(message: String, completion: (() -> Void)?) {
        guard let link = message.detectedFirstLink else {
            self.linkAttatchment = nil
            completion?()
            return
        }
        let request = DecodeUrlRequest.builder()
            .link(link)
            .build()
        LMFeedClient.shared.decodeUrl(request) {[weak self] response in
            print(response)
            if response.success, let ogTags = response.data?.oGTags {
                self?.currentSelectedUploadeType = .link
                self?.linkAttatchment = .init(title: ogTags.title, linkThumbnailUrl: ogTags.image, description: ogTags.description, url: ogTags.url)
            } else {
                //                self?.currentSelectedUploadeType = .unknown
                self?.linkAttatchment = nil
            }
            completion?()
        }
    }
    
    func decodeUrl(stringUrl: String) {
        let request = DecodeUrlRequest.builder()
            .link(stringUrl)
            .build()
        LMFeedClient.shared.decodeUrl(request) {[weak self] response in
            print(response)
            if response.success, let ogTags = response.data?.oGTags {
                self?.currentSelectedUploadeType = .link
                self?.linkAttatchment = .init(title: ogTags.title, linkThumbnailUrl: ogTags.image, description: ogTags.description, url: ogTags.url)
            } else {
                self?.currentSelectedUploadeType = .unknown
                self?.linkAttatchment = nil
            }
            self?.delegate?.reloadCollectionView()
        }
    }
    
    func editPost(_ text: String?, heading: String, postType: AttachmentUploadType) {
        let parsedTaggedUserPostText = TaggedRouteParser.shared.editAnswerTextWithTaggedList(text: text, taggedUsers: self.taggedUsers)
        if self.imageAndVideoAttachments.count > 0 {
            switch postType {
            case .article:
                self.editArticlePost(postCaption: parsedTaggedUserPostText, heading: heading)
            default:
                self.editPostWithImageOrVideoAttachment(postCaption: parsedTaggedUserPostText, heading: heading)
            }
        } else if self.documentAttachments.count > 0 {
            self.editPostWithDocAttachment(postCaption: parsedTaggedUserPostText, heading: heading)
        } else if self.linkAttatchment != nil {
            self.editPostWithLinkAttachment(postCaption: parsedTaggedUserPostText, heading: heading)
        } else if !parsedTaggedUserPostText.isEmpty {
            self.editPostWithOutAttachment(postCaption: parsedTaggedUserPostText, heading: heading)
        }
    }
    
    private func editPostWithLinkAttachment(postCaption: String?, heading: String) {
        guard let linkAttatchment = self.linkAttatchment else { return }
        let attachmentMeta = AttachmentMeta()
            .ogTags(.init()
                .image(linkAttatchment.linkThumbnailUrl ?? "")
                .title(linkAttatchment.title ?? "")
                .description(linkAttatchment.description ?? "")
                .url(linkAttatchment.url ?? ""))
        let attachmentRequest = Attachment()
            .attachmentType(.link)
            .attachmentMeta(attachmentMeta)
        let editPostRequest = EditPostRequest.builder()
            .postId(postId)
            .text(postCaption)
            .heading(heading)
            .attachments([attachmentRequest])
            .build()
        EditPostOperation.shared.editPost(request: editPostRequest, postId: self.postId)
    }
    
    private func editPostWithDocAttachment(postCaption: String, heading: String) {
        var documentAttachments: [AWSFileUploadRequest] = []
        var index = 0
        for attachedItem in self.documentAttachments {
            guard let fileUrl = attachedItem.attachmentUrl else { continue }
            let fileType: UploaderType = .file
            let item = AWSFileUploadRequest(fileUrl: fileUrl, awsFilePath: filePath, fileType: fileType, index: index, name: attachedItem.name ?? "document_\(Date().millisecondsSince1970)")
            item.awsUploadedUrl = fileUrl.hasPrefix("https://s3.ap-south-1.amazonaws.com") ? fileUrl : nil
            item.thumbnailImage = attachedItem.thumbnailImage
            item.thumbnailUrl = attachedItem.thumbnailUrl
            item.documentAttachmentSize = attachedItem.attachmentSize
            item.documentNumberOfPages = attachedItem.numberOfPages
            documentAttachments.append(item)
            index += 1
        }
        EditPostOperation.shared.editPostWithAttachment(attachments: documentAttachments, postCaption: postCaption, heading: heading, postId: self.postId, postType: currentSelectedUploadeType)
    }
    
    private func editPostWithImageOrVideoAttachment(postCaption: String, heading: String) {
        var imageVideoAttachments: [AWSFileUploadRequest] = []
        var index = 0
        for attachedItem in self.imageAndVideoAttachments {
            guard let fileUrl = attachedItem.url else { continue }
            let fileType: UploaderType = attachedItem.fileType == .image ? .image : .video
            let item = AWSFileUploadRequest(fileUrl: fileUrl, awsFilePath: filePath, fileType: fileType, index: index, name: attachedItem.name ?? "media_\(Date().millisecondsSince1970)")
            item.awsUploadedUrl = fileUrl.hasPrefix("https://s3.ap-south-1.amazonaws.com") ? fileUrl : nil
            item.thumbnailImage = attachedItem.thumbnailImage
            item.documentAttachmentSize = attachedItem.size
            imageVideoAttachments.append(item)
            index += 1
        }
        EditPostOperation.shared.editPostWithAttachment(attachments: imageVideoAttachments, postCaption: postCaption, heading: heading, postId: self.postId, postType: currentSelectedUploadeType)
    }
    
    private func editPostWithOutAttachment(postCaption: String?, heading: String) {
        let editPostRequest = EditPostRequest.builder()
            .postId(postId)
            .text(postCaption)
            .heading(heading)
            .build()
        EditPostOperation.shared.editPost(request: editPostRequest, postId: self.postId)
    }
    
    private func editArticlePost(postCaption: String?, heading: String) {
        var imageVideoAttachments: [AWSFileUploadRequest] = []
        var index = 0
        for attachedItem in self.imageAndVideoAttachments {
            guard let fileUrl = attachedItem.url else { continue }
            let fileType: UploaderType = .image
            let item = AWSFileUploadRequest(fileUrl: fileUrl, awsFilePath: filePath, fileType: fileType, index: index, name: attachedItem.name ?? "media_\(Date().millisecondsSince1970)")
            item.awsUploadedUrl = fileUrl.hasPrefix("https://s3.ap-south-1.amazonaws.com") ? fileUrl : nil
            item.thumbnailImage = attachedItem.thumbnailImage
            item.documentAttachmentSize = attachedItem.size
            item.title = heading
            item.body = postCaption
            item.entityID = self.postDetail?.imageVideos?.first?.entityID
            item.coverImageUrl = item.awsUploadedUrl
            imageVideoAttachments.append(item)
            index += 1
        }
        EditPostOperation.shared.editPostWithAttachment(attachments: imageVideoAttachments, postCaption: postCaption, heading: heading, postId: self.postId, postType: currentSelectedUploadeType)
    }
}

