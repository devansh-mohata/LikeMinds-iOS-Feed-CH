//
//  AttachmentUploadOperation.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 21/05/23.
//

import Foundation
import UIKit
import AVFoundation
import LikeMindsFeed
import BackgroundTasks

class AttachmentUploadOperation: NetworkOperation {
    
    var attachmentList : [AWSFileUploadRequest]
    var postCaption: String?
    
    init(attachmentList : [AWSFileUploadRequest], postCaption: String?) {
        self.attachmentList = attachmentList
        self.postCaption = postCaption
    }
    
    func postMessageToCompleteAttachmentUpload() {
        
    }
    
    func postMessageToCompleteCreatePost() {
        NotificationCenter.default.post(name: .postCreationCompleted, object: nil)
    }
    
    func createPost() {
        print("Creating post....")
        if attachmentList.count > 0 {
            var attachments: [Attachment] = []
            for attachedItem in self.attachmentList {
                switch attachedItem.fileType {
                case .image:
                    attachments.append(self.imageAttachmentData(attachment: attachedItem))
                case .video:
                    attachments.append(self.videoAttachmentData(attachment: attachedItem))
                case .file:
                    attachments.append(self.fileAttachmentData(attachment: attachedItem))
                default:
                    break
                }
            }
            
            let addPostRequest = AddPostRequest.builder()
                .text(self.postCaption)
                .attachments(attachments)
                .build()
            LMFeedClient.shared.addPost(addPostRequest) { [weak self] response in
                print("Post Creation with attachment done....")
                self?.postMessageToCompleteCreatePost()
            }
            
        } else {
            let addPostRequest = AddPostRequest.builder()
                .text(self.postCaption)
                .build()
            LMFeedClient.shared.addPost(addPostRequest) { [weak self] response in
                print("Post Creation without attachment done....")
                self?.postMessageToCompleteCreatePost()
            }
        }
    }
    
    func imageAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int?
        if let attr = try? FileManager.default.attributesOfItem(atPath: attachment.fileUrl) {
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
    
    func fileAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
        var size: Int?
        var numberOfPages: Int?
        guard let fileUrl = URL(string: attachment.fileUrl) else { return Attachment() }
        if let pdf = CGPDFDocument(fileUrl as CFURL) {
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
    
    func videoAttachmentData(attachment: AWSFileUploadRequest) -> Attachment {
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
    
    override func main() {
        print( "attachment upload starting...")
        if self.checkCancel() {
            print( "attachment upload cancelled...")
            return
        }
        NotificationCenter.default.post(name: .postCreationStarted, object: nil)
        guard let attachment = attachmentList.filter({$0.awsUploadedUrl == nil}).first else {
            print( "attachment upload completed...")
            createPost()
            return
        }
        
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
                NetworkOperationQueueManager.shared.addOperation(networkOperation: AttachmentUploadOperation(attachmentList: self?.attachmentList ?? [], postCaption: self?.postCaption))
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
                NetworkOperationQueueManager.shared.addOperation(networkOperation: AttachmentUploadOperation(attachmentList: self?.attachmentList ?? [], postCaption: self?.postCaption))
            }
        case .file:
            AWSUploadManager.sharedInstance.awsUploader(uploaderType: .file, filePath: attachment.awsFilePath, path: attachment.fileUrl, thumbNailUrl: nil, index: attachment.index ) { (progress) in
                print("file - \(attachment.index) upload progress...\(progress)")
            } completion: {[weak self] (fileResponse, thumbnailUrl, error, nil)  in
                print(fileResponse)
                attachment.awsUploadedUrl = (fileResponse as? String) ?? ""
                NetworkOperationQueueManager.shared.addOperation(networkOperation: AttachmentUploadOperation(attachmentList: self?.attachmentList ?? [], postCaption: self?.postCaption))
            }
        default:
            break
        }
        
        // Pop image off front of array
     /*   let strS3ImageName  = "img_water\(imageList.count).jpg"
        
        let image = imageList.remove(at: 0)
        var data : Data!
        data = (image).jpegData(compressionQuality: 0.9)
        let   strExtention = "JPG"
        
        var strContentType = "image/"+strExtention.lowercased()
        let  transferUtility = AWSS3TransferUtility.default()
        let expression = AWSS3TransferUtilityUploadExpression()
        
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            if(progress.fractionCompleted == 1.0){
            }
            
        })
        }
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if(error == nil){
                    print("Image completed: \(strS3ImageName)")
                    
                    if !self.isCancelled {
                        if self.imageList.count == 0 {
                            // All images done, here you could call a final completion handler or somthing.
                        } else {
                            // More images left to do, let's put another Operation on the barbie:)
                            NetOpsQueueMgr.shared.submitOp(netOp: ImagesUploadOp(imageList: self.imageList))
                        }
                    }
                }
                self.complete()
            })
        }
        strContentType = "image/"+strExtention.lowercased()
        transferUtility.uploadData(data,
                                   bucket: S3BucketName,
                                   key: strS3ImageName,
                                   contentType: strContentType,
                                   expression: expression,
                                   completionHandler: completionHandler).continueOnSuccessWith {
            (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            if let result = task.result {
                print("this is result \(result)")
            }
            if  task.isCancelled {
                print("task has been cancled")
            }
            
            return nil;
        }
        */
    }
    
}
