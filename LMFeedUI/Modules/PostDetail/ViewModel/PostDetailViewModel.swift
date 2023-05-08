//
//  PostDetailViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 10/04/23.
//

import Foundation
import LMFeed

protocol PostDetailViewModelDelegate: AnyObject {
    func didReceiveComments()
}

final class PostDetailViewModel {
    
    var comments: [PostDetailDataModel.Comment] = []
    var postDetail: PostFeedDataView?
    
    weak var delegate: PostDetailViewModelDelegate?
    
    func getPostDetails() {
        let request = GetPostRequest(postId: HomeFeedViewModel.postId)
            .page(1)
            .pageSize(20)
        LMFeedClient.shared.getPost(request) {[weak self] response in
            guard let postDetails = response.data?.post, let users =  response.data?.users else {
                return
            }
            self?.postDetail = PostFeedDataView(post: postDetails, user: users[postDetails.userID ?? ""])
            self?.comments.append(contentsOf: postDetails.replies?.compactMap({.init(comment: $0, user: users[$0.userId])}) ?? [])
            self?.delegate?.didReceiveComments()
        }
    }
    
    func getCommentReplies(commentId: String) {
        let request = GetCommentRequest(postId: HomeFeedViewModel.postId, commentId: commentId)
            .page(1)
            .pageSize(10)
        LMFeedClient.shared.getComment(request) { response in
            
        }
    }
    
}
