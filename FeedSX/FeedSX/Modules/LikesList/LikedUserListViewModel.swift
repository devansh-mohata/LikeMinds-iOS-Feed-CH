//
//  LikedUserListViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 11/04/23.
//

import Foundation
import LikeMindsFeed

protocol LikedUserListViewModelDelegate: AnyObject {
    func reloadLikedUserList()
    func responseFailed(withError error: String?)
}

final class LikedUserListViewModel {
    
    var currentPage: Int = 1
    let postId: String
    let commentId: String?
    var likedUsers: [LikedUserDataView.LikedUser] = []
    var totalLikes: Int?
    weak var delegate: LikedUserListViewModelDelegate?
    
    init(postId: String, commentId: String?) {
        self.postId = postId
        self.commentId = commentId
    }
    
    func fetchLikedUsers() {
        if let _ = self.commentId {
            self.fetchCommentLikedUsers()
        } else {
            self.fetchPostLikedUsers()
        }
    }
    
    func fetchPostLikedUsers() {
        let request = GetPostLikesRequest.builder()
            .postId(postId)
            .page(currentPage)
            .pageSize(20)
            .build()
        LMFeedClient.shared.getPostLikes(request) {[weak self] result in
            print(result)
            if result.success,
               let likes = result.data?.likes,
               let users = result.data?.users {
                self?.totalLikes = result.data?.totalCount
                if (self?.currentPage ?? 0) == 1 {
                    self?.likedUsers = []
                }
                for like in likes {
                    let user = users[like.uuid ?? ""]
                    let likedUser = LikedUserDataView.LikedUser(username: user?.name ?? "",
                                                                profileImage: user?.imageUrl ?? "",
                                                                userTitle: user?.customTitle ?? "",
                                                                isDeleted: user?.isDeleted ?? false)
                    self?.likedUsers.append(likedUser)
                }
                self?.currentPage += 1
                self?.delegate?.reloadLikedUserList()
            } else {
                self?.delegate?.responseFailed(withError: result.errorMessage)
            }
        }
    }
    
    func fetchCommentLikedUsers() {
        guard let commentId = self.commentId else {return}
        let request = GetCommentLikesRequest.builder()
            .postId(postId)
            .commentId(commentId)
            .page(currentPage)
            .pageSize(20)
            .build()
        LMFeedClient.shared.getCommentLikes(request) {[weak self] result in
            print(result)
            if result.success,
               let likes = result.data?.likes,
               let users = result.data?.users {
                self?.totalLikes = result.data?.totalLikes
                if (self?.currentPage ?? 0) == 1 {
                    self?.likedUsers = []
                }
                for like in likes {
                    let user = users[like.uuid ?? ""]
                    let likedUser = LikedUserDataView.LikedUser(username: user?.name ?? "",
                                                                profileImage: user?.imageUrl ?? "",
                                                                userTitle: user?.customTitle ?? "", isDeleted: user?.isDeleted ?? false)
                    self?.likedUsers.append(likedUser)
                }
                self?.currentPage += 1
                self?.delegate?.reloadLikedUserList()
            } else {
                self?.delegate?.responseFailed(withError: result.errorMessage)
            }
        }
    }
}
