//
//  DeleteContentViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import Foundation
import LMFeed

protocol DeleteContentViewModelProtocol: AnyObject {
    func didReceivedReportTags()
    func didReceivedDeletePostResponse(postId: String, commentId: String?)
}

extension DeleteContentViewModelProtocol {
    func didReceivedReportTags() {}
    func didReceivedDeletePostResponse(postId: String, commentId: String?) {}
}

final class DeleteContentViewModel {
    
    var reasons:[ReportTag]?
    var selectedReason: ReportTag?
    
    weak var delegate: DeleteContentViewModelProtocol?
    
    func fetchReportTags(type: Int) {
        let request = GetReportTagRequest(type)
        LMFeedClient.shared.getReportTags(request) {[weak self] result in
            if result.success, let tags = result.data?.reportTags {
                self?.reasons = tags
                self?.delegate?.didReceivedReportTags()
            } else {
                
            }
        }
    }
    
    func deletePost(postId: String, reasonText: String?, completion: (() -> Void)?) {
        let request = DeletePostRequest(postId: postId)
            .deleteReason(reasonText)
        LMFeedClient.shared.deletePost(request) {[weak self] response in
            if response.success{
                self?.delegate?.didReceivedDeletePostResponse(postId: postId, commentId: nil)
                completion?()
            } else {
                print(response.errorMessage)
            }
        }
    }
    
    func deleteComment(postId: String, commentId: String, reasonText: String?, completion: (() -> Void)?) {
        let request = DeleteCommentRequest(postId: postId, commentId: commentId)
            .deleteReason(reasonText)
        LMFeedClient.shared.deleteComment(request) { [weak self] response in
            if response.success{
                self?.delegate?.didReceivedDeletePostResponse(postId: postId, commentId: commentId)
                completion?()
            } else {
                print(response.errorMessage)
            }
        }
    }
}
