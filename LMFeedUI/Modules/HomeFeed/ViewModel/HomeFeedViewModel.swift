//
//  HomeFeedViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 30/03/23.
//

import Foundation
import LMFeed

protocol HomeFeedViewModelDelegate: AnyObject {
    func didFeedReceived()
}

class HomeFeedViewModel {
    
    weak var delegate: HomeFeedViewModelDelegate?
    var feeds: [HomeFeedDataView] = []
    var currentPage: Int = 1
    
    func getFeed() {
        let requestFeed = GetFeedRequest(page: currentPage)
        LMFeedClient.shared.getFeeds(requestFeed) { [weak self] result in
            print(result)
            if result.success,
               let postsData = result.data?.posts,
               let users = result.data?.users {
                self?.prepareHomeFeedDataView(postsData, users: users)
            } else {
                print(result.errorMessage ?? "")
            }
        }
    }
    
    func getMemberState() {
        let requestState = GetMemberStateRequest(memberId: "adl", communityId: 123)
        LMFeedClient.shared.getMemberState(requestState) { [weak self] result in
            print(result)
            if result.success,
               let postsData = result.data?.member {
            } else {
                print(result.errorMessage ?? "")
            }
        }
    }
    
    func likePost(postId: String) {
        let request = LikePostRequest(postId: postId)
        LMFeedClient.shared.likePost(request) { response in
            if response.success {
                
            } else {
                print(response.errorMessage)
            }
        }
    }
    
    func savePost(postId: String) {
        let request = SavePostRequest(postId: postId)
        LMFeedClient.shared.savePost(request) { response in
            if response.success {
                
            } else {
                print(response.errorMessage)
            }
        }
    }
    
    func prepareHomeFeedDataView(_ posts: [Post], users: [String: User]) {
        feeds = posts.map { HomeFeedDataView(post: $0, user: users[$0.userID ?? ""])}
        delegate?.didFeedReceived()
    }
    
}
