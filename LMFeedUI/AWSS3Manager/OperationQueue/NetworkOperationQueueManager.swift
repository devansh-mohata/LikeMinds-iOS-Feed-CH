//
//  NetworkOperationQueueManager.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 21/05/23.
//

import Foundation
import UIKit

class NetworkOperationQueueManager {
    
    static let shared = NetworkOperationQueueManager()
    
    lazy var operationQueue :OperationQueue = {
        var queue = OperationQueue()
        queue.name = "likeminds.file.upload.queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
    
    func addOperation(networkOperation: NetworkOperation) {
        operationQueue.addOperation(networkOperation)
    }
    
    func createPostOperation(attachmentList : [AWSFileUploadRequest], postCaption: String?) {
        let attachmentsOperation = AttachmentUploadOperation(attachmentList: attachmentList, postCaption: postCaption)
        self.addOperation(networkOperation: attachmentsOperation)
    }
}
