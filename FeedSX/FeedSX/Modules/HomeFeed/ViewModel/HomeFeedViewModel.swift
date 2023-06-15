//
//  HomeFeedViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 30/03/23.
//

import Foundation
import LikeMindsFeed

protocol HomeFeedViewModelDelegate: AnyObject {
    func didReceivedFeedData(success: Bool)
    func didReceivedMemberState()
    func reloadSection(_ indexPath: IndexPath)
    func updateNotificationFeedCount(_ count: Int)
}

class HomeFeedViewModel: BaseViewModel {
    
    weak var delegate: HomeFeedViewModelDelegate?
    var feeds: [PostFeedDataView] = []
    var currentPage: Int = 1
    var isFeedLoading: Bool = false
    
    func getFeed() {
        self.isFeedLoading = true
        let requestFeed = GetFeedRequest(page: currentPage)
            .pageSize(20)
        LMFeedClient.shared.getFeeds(requestFeed) { [weak self] result in
            print(result)
            self?.isFeedLoading = false
            if result.success,
               let postsData = result.data?.posts,
               let users = result.data?.users, postsData.count > 0 {
                self?.prepareHomeFeedDataView(postsData, users: users)
                self?.currentPage += 1
            } else {
                print(result.errorMessage ?? "")
                self?.delegate?.didReceivedFeedData(success: false)
                self?.postErrorMessageNotification(error: result.errorMessage)
            }
        }
    }
    
    func pullToRefresh() {
        self.currentPage = 1
        getFeed()
    }
    
    func refreshFeedDataObject(_ postData: PostFeedDataView) {
        guard let index = self.feeds.firstIndex(where: {$0.postId == postData.postId}) else {return }
        self.feeds[index] = postData
    }
    
    func getMemberState() {
        LMFeedClient.shared.getMemberState() { [weak self] result in
            print(result)
            if result.success,
               let memberState = result.data {
                LocalPrefrerences.saveObject(memberState, forKey: LocalPreferencesKey.memberStates)
            } else {
                print(result.errorMessage ?? "")
            }
            self?.delegate?.didReceivedMemberState()
        }
    }
    
    func likePost(postId: String) {
        let request = LikePostRequest(postId: postId)
        LMFeedClient.shared.likePost(request) { [weak self] response in
            if !response.success {
                guard let index = self?.feeds.firstIndex(where: {$0.postId == postId}), let feed = self?.feeds[index] else {
                    return
                }
                let isLike = !(feed.isLiked)
                feed.isLiked = isLike
                feed.likedCount += isLike ? 1 : -1
                self?.delegate?.reloadSection(IndexPath(row: index, section: 0))
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func savePost(postId: String) {
        let request = SavePostRequest(postId: postId)
        LMFeedClient.shared.savePost(request) { [weak self] response in
            if !response.success {
                guard let index = self?.feeds.firstIndex(where: {$0.postId == postId}), let feed = self?.feeds[index] else {
                    return
                }
                feed.isSaved = !(feed.isSaved)
                self?.delegate?.reloadSection(IndexPath(row: index, section: 0))
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func pinUnpinPost(postId: String) {
        let request = PinPostRequest(postId: postId)
        LMFeedClient.shared.pinPost(request) {[weak self] response in
            if response.success {
                guard let index = self?.feeds.firstIndex(where: {$0.postId == postId}), let feed = self?.feeds[index] else {
                    return
                }
                feed.isPinned = !(feed.isPinned)
                feed.updatePinUnpinMenu()
                self?.delegate?.reloadSection(IndexPath(row: index, section: 0))
            } else {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func updateEditedPost(postDetail: PostFeedDataView?) -> Int {
        guard let postDetail = postDetail, let index = feeds.firstIndex(where: {$0.postId == postDetail.postId}) else { return 0 }
        feeds[index] = postDetail
        return index
    }
    
    func getUnreadNotificationCount(postId: String) {
        LMFeedClient.shared.getUnreadNotificationCount() {[weak self] response in
            if response.success, let count = response.data?.count {
                print("notification cout: \(count)")
            } else {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func prepareHomeFeedDataView(_ posts: [Post], users: [String: User]) {
        if self.currentPage > 1 {
            feeds.append(contentsOf: posts.map { PostFeedDataView(post: $0, user: users[$0.userID ?? ""])})
        } else {
            feeds = posts.map { PostFeedDataView(post: $0, user: users[$0.userID ?? ""])}
        }
        delegate?.didReceivedFeedData(success:  true)
    }
    
    func hasRightForCreatePost() -> Bool {
        if self.isAdmin() { return true }
        guard let rights = LocalPrefrerences.getMemberStateData()?.memberRights,
              let right = rights.filter({$0.state == .createPost}).first else {
            return true
        }
        return right.isSelected ?? true
    }
    
    func isAdmin() -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member else { return false }
        return member.state == 1
    }
    func isOwnPost(index: Int) -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member else { return false }
        let post = feeds[index]
        return post.feedByUser?.userId == member.userUniqueId
    }
}
