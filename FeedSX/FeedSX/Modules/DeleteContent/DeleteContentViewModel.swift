//
//  DeleteContentViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import Foundation
import LikeMindsFeed

protocol DeleteContentViewModelProtocol: AnyObject {
    func didReceivedReportTags()
    func didReceivedDeletePostResponse(postId: String, commentId: String?)
    func didReceivedDeletePostResponse(with error: String?)
}

extension DeleteContentViewModelProtocol {
    func didReceivedReportTags() {}
    func didReceivedDeletePostResponse(postId: String, commentId: String?) {}
    func didReceivedDeletePostResponse(with error: String?) {}
}

final class DeleteContentViewModel {
    
    var reasons:[ReportTag]?
    var selectedReason: ReportTag?
    
    weak var delegate: DeleteContentViewModelProtocol?
    
    func fetchReportTags(type: Int) {
        let request = GetReportTagRequest.builder()
            .type(type)
            .build()
        LMFeedClient.shared.getReportTags(request) {[weak self] result in
            if result.success, let tags = result.data?.reportTags {
                self?.reasons = tags
                self?.delegate?.didReceivedReportTags()
            } else {
                self?.delegate?.didReceivedDeletePostResponse(with: result.errorMessage)
            }
        }
    }
    
    func deletePost(postId: String, reasonText: String?, completion: (() -> Void)?) {
        let request = DeletePostRequest.builder()
            .postId(postId)
            .deleteReason(reasonText)
            .build()
        LMFeedClient.shared.deletePost(request) {[weak self] response in
            if response.success{
                self?.delegate?.didReceivedDeletePostResponse(postId: postId, commentId: nil)
                completion?()
            } else {
                print(response.errorMessage)
                self?.delegate?.didReceivedDeletePostResponse(with: response.errorMessage)
            }
        }
    }
    
    func deleteComment(postId: String, commentId: String, reasonText: String?, completion: (() -> Void)?) {
        let request = DeleteCommentRequest.builder()
            .postId(postId)
            .commentId(commentId)
            .deleteReason(reasonText)
            .build()
        LMFeedClient.shared.deleteComment(request) { [weak self] response in
            if response.success{
                LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Comment.deleted, eventProperties: ["post_id": postId, "comment_id": commentId])
                self?.delegate?.didReceivedDeletePostResponse(postId: postId, commentId: commentId)
                completion?()
            } else {
                print(response.errorMessage)
                self?.delegate?.didReceivedDeletePostResponse(with: response.errorMessage)
            }
        }
    }
}
