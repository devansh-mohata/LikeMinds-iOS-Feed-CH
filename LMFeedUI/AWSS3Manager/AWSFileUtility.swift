//
//  AWSFileUtility.swift
//  LMFeed
//
//  Created by Pushpendra Singh on 09/03/23.
//

import Foundation

class AWSFileUploadRequest {
    let fileUrl: String
    let fileType: UploaderType
    let index: Int
    var awsFilePath: String
    var awsUploadedUrl: String?
    
    init(fileUrl: String, awsFilePath: String, fileType: UploaderType, index: Int) {
        self.fileUrl = fileUrl
        self.awsFilePath = awsFilePath
        self.fileType = fileType
        self.index = index
    }
}

class AWSFileUtility {
    
    static let shared = AWSFileUtility()
    private var dispatchGroupOperation = DispatchGroup()
    private var uploadProgress: Double = 0
    private var uploadFiles: [AWSFileUploadRequest] = []
    private var progressBlock: ProgressBlock?
    
    private init() {}

    func uploadFiles(uploadFilesRequest: [AWSFileUploadRequest], progress: ProgressBlock?, completion: (([AWSFileUploadRequest]) -> Void)?) {
        dispatchGroupOperation = DispatchGroup()
        uploadFiles = uploadFilesRequest
        self.progressBlock = progress
        for request in uploadFilesRequest {
            switch request.fileType {
            case .image:
                uploadImage(imageUrl: request.fileUrl, request: request)
            default:
                uploadFile(fileUrl: request.fileUrl, request: request)
            }
        }
        dispatchGroupOperation.notify(queue: .main) {
            completion?(uploadFilesRequest)
        }
    }
    
    private func uploadImage(imageUrl: String, request: AWSFileUploadRequest) {
        do {
            dispatchGroupOperation.enter()
            let imagedata = try Data(contentsOf: URL(string: imageUrl)!)
            AWSAttachmentUploader.sharedInstance.awsUploader(uploaderType: .image, awsFilePath: request.awsFilePath, image: imagedata, localFilePath: imageUrl, index: request.index) { progress in
                
            } completion: { [weak self] response, thumbNail, error, index in
                if let awspath = response as? String {
                    request.awsUploadedUrl = awspath
                }
                self?.uploadProgress += 1
                self?.progressBlock?(self?.uploadProgress ?? 0)
                self?.dispatchGroupOperation.leave()
            }
        } catch let error {
            print(error)
            dispatchGroupOperation.leave()
        }
    }
    
    private func uploadFile(fileUrl: String, request: AWSFileUploadRequest) {
        dispatchGroupOperation.enter()
        AWSAttachmentUploader.sharedInstance.awsUploader(uploaderType: request.fileType, awsFilePath: request.awsFilePath, image: nil, localFilePath: fileUrl, index: request.index) { progress in
            
        } completion: { [weak self] response, thumbNail, error, index in
            if let awspath = response as? String {
                request.awsUploadedUrl = awspath
            }
            self?.uploadProgress += 1
            self?.progressBlock?(self?.uploadProgress ?? 0)
            self?.dispatchGroupOperation.leave()
        }
    }
    
    func cancelAllOperation() {
    }
}
