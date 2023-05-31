//
//  CreatePostViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import Foundation
import PDFKit
import LikeMindsFeed
import AVFoundation

protocol CreatePostViewModelDelegate: AnyObject {
    func reloadCollectionView()
    func reloadActionTableView()
}

final class CreatePostViewModel {
    
    var imageAndVideoAttachments: [PostFeedDataView.ImageVideo] = []
    var documentAttachments: [PostFeedDataView.Attachment] = []
    var linkAttatchment: PostFeedDataView.LinkAttachment?
    let attachmentUploadTypes: [AttachmentUploadType] = [.image, .video, .document]
    var currentSelectedUploadeType: CreatePostViewModel.AttachmentUploadType = .unknown
    weak var delegate: CreatePostViewModelDelegate?
    var postCaption: String?
    var taggedUsers: [User] = []
    
    enum AttachmentUploadType: String {
        case document = "Attach Files"
        case image = "Add Photo"
        case video = "Add Video"
        case link
        case unknown
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
        self.imageAndVideoAttachments.append(attachment)
    }
    
    func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
        let pdfDocument = PDFDocument(url: documentUrl)
        let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
        return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
    
    func generateVideoThumbnail(forUrl url: URL) -> UIImage? {
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
        guard let link = message.detectedFirstLink else {
            self.currentSelectedUploadeType = .unknown
            self.linkAttatchment = nil
            self.delegate?.reloadCollectionView()
            return
        }
        decodeUrl(stringUrl: link)
    }
    
    func decodeUrl(stringUrl: String) {
        let request = DecodeUrlRequest(stringUrl)
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
    
    func createPost(_ text: String?) {
        let parsedTaggedUserPostText = self.editAnswerTextWithTaggedList(text: text)
        let filePath = "files/post/\(LocalPrefrerences.getUserData()?.userUniqueId ?? "user")/"
        if self.imageAndVideoAttachments.count > 0 {
            var imageVideoAttachments: [AWSFileUploadRequest] = []
            var index = 0
            for attachedItem in self.imageAndVideoAttachments {
                guard let fileUrl = attachedItem.url else { continue }
                let fileType: UploaderType = attachedItem.fileType == .image ? .image : .video
                let item = AWSFileUploadRequest(fileUrl: fileUrl, awsFilePath: filePath, fileType: fileType, index: index, name: attachedItem.url?.components(separatedBy: "/").last ?? "attache_\(Date().millisecondsSince1970)")
                item.thumbnailImage = attachedItem.thumbnailImage
                imageVideoAttachments.append(item)
                index += 1
            }
            CreatePostOperation.shared.createPostWithAttachment(attachments: imageVideoAttachments, postCaption: parsedTaggedUserPostText)
        } else if self.documentAttachments.count > 0 {
            var documentAttachments: [AWSFileUploadRequest] = []
            var index = 0
            for attachedItem in self.documentAttachments {
                guard let fileUrl = attachedItem.attachmentUrl else { continue }
                let fileType: UploaderType = .file
                let item = AWSFileUploadRequest(fileUrl: fileUrl, awsFilePath: filePath, fileType: fileType, index: index, name: attachedItem.attachmentUrl?.components(separatedBy: "/").last ?? "attache_\(Date().millisecondsSince1970)")
                item.thumbnailImage = attachedItem.thumbnailImage
                documentAttachments.append(item)
                index += 1
            }
            CreatePostOperation.shared.createPostWithAttachment(attachments: documentAttachments, postCaption: parsedTaggedUserPostText)
        } else if self.linkAttatchment != nil {
            self.createPostWithLinkAttachment(postCaption: parsedTaggedUserPostText)
        } else if !parsedTaggedUserPostText.isEmpty {
            self.createPostWithOutAttachment(postCaption: parsedTaggedUserPostText)
        }
    }
    
    private func createPostWithLinkAttachment(postCaption: String?) {
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
        let addPostRequest = AddPostRequest()
            .text(postCaption)
            .attachments([attachmentRequest])
        CreatePostOperation.shared.createPost(request: addPostRequest)
    }
    
    private func createPostWithDocAttachment(postCaption: String?) {
        
    }
    
    private func createPostWithImageOrVideoAttachment(postCaption: String?) {
        
    }
    
    private func createPostWithOutAttachment(postCaption: String?) {
        let addPostRequest = AddPostRequest()
            .text(postCaption)
        CreatePostOperation.shared.createPost(request: addPostRequest)
    }
    
    func editAnswerTextWithTaggedList(text: String?) -> String  {
        if var answerText = text, self.taggedUsers.count > 0 {
            for member in taggedUsers {
                if let memberName = member.name {
                    let memberNameWithTag = "@"+memberName
                    if answerText.contains(memberNameWithTag) {
                        if let _ = answerText.range(of: memberNameWithTag) {
                            answerText = answerText.replacingOccurrences(of: memberNameWithTag, with: "<<\(memberName)|route://member/\(member.userUniqueId ?? "")>>")
                        }
                    }
                }
            }
            answerText = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
            return answerText
        }
        return text ?? ""
    }
}
