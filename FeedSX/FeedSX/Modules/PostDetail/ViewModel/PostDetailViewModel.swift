//
//  PostDetailViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 10/04/23.
//

import Foundation
import LikeMindsFeed

protocol PostDetailViewModelDelegate: AnyObject {
    func didReceiveComments()
    func didReceiveCommentsReply()
    func insertAndScrollToRecentComment(_ indexPath: IndexPath)
    func didReceivedMemberState()
    func reloadSection(_ indexPath: IndexPath)
}

final class PostDetailViewModel: BaseViewModel {
    var comments: [PostDetailDataModel.Comment] = []
    var postDetail: PostFeedDataView?
    private var commentCurrentPage: Int = 1
    var commentPageSize: Int = 10
    private var repliesCurrentPage1: Int = 1
    var isCommentLoading: Bool = false
    var isCommentRepliesLoading: Bool = false
    weak var delegate: PostDetailViewModelDelegate?
    var postId: String = ""
    var taggedUsers: [User] = []
    var replyOnComment: PostDetailDataModel.Comment?
    
    func notifyObjectChanges() {
        NotificationCenter.default.post(name: .refreshHomeFeedDataObject, object: postDetail)
    }
    
    func postComment(text: String) {
        let parsedTaggedUserText = self.editAnswerTextWithTaggedList(text: text)
        if let replyOnComment = self.replyOnComment {
            self.postCommentsReply(commentId: replyOnComment.commentId, comment: parsedTaggedUserText)
        } else {
            self.postCommentOnPost(parsedTaggedUserText)
        }
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
            answerText = answerText.trimmedText()
            return answerText
        }
        return text ?? ""
    }
    
    func repliesCount(section: Int) -> Int {
        let comment = comments[section]
        if comment.replies.count > 0 {
            return comment.replies.count >= comment.commentCount ? comment.replies.count : comment.replies.count + 1
        } else {
            return 0
        }
    }
    
    func pullToRefreshData() {
        commentCurrentPage = 1
        getComments()
    }
    
    func getComments() {
        guard !self.isCommentLoading else { return }
        let request = GetPostRequest(postId: self.postId)
            .page(commentCurrentPage)
            .pageSize(commentPageSize)
        self.isCommentLoading = true
        LMFeedClient.shared.getPost(request) {[weak self] response in
            if response.success == false {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            guard let postDetails = response.data?.post, let users =  response.data?.users else {
                self?.isCommentLoading = false
                return
            }
            self?.postDetail = PostFeedDataView(post: postDetails, user: users[postDetails.userID ?? ""])
            if let replies = postDetails.replies, replies.count > 0 {
                if (self?.commentCurrentPage ?? 1) > 1 {
                    self?.comments.append(contentsOf: replies.compactMap({.init(comment: $0, user: users[$0.userId])}))
                } else {
                    self?.comments =  replies.compactMap({.init(comment: $0, user: users[$0.userId])})
                }
                self?.commentCurrentPage += 1
            }
            self?.delegate?.didReceiveComments()
            self?.isCommentLoading = false
        }
    }
    
    func getCommentReplies(commentId: String) {
        guard !self.isCommentRepliesLoading else { return }
        guard let selectedComment = self.comments.filter({$0.commentId == commentId}).first else {return}
        self.isCommentRepliesLoading = true
        let repliesCurrentPage = (selectedComment.replies.count/5) + 1
        let request = GetCommentRequest(postId: self.postId, commentId: commentId)
            .page(repliesCurrentPage)
            .pageSize(5)
        LMFeedClient.shared.getComment(request) {[weak self] response in
            if response.success == false {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            guard let comment = response.data?.comment, let users =  response.data?.users else {
                self?.isCommentRepliesLoading = false
                return
            }
            if repliesCurrentPage > 1 {
                selectedComment.replies.append(contentsOf: comment.replies?.compactMap({.init(comment: $0, user: users[$0.userId])}) ?? [])
            } else {
                selectedComment.replies = comment.replies?.compactMap({.init(comment: $0, user: users[$0.userId])}) ?? []
            }
            self?.delegate?.didReceiveCommentsReply()
            self?.isCommentRepliesLoading = false
        }
    }
    
    private func postCommentOnPost(_ comment: String) {
        let request = AddCommentRequest(postId: self.postId, text: comment)
        LMFeedClient.shared.addComment(request) { [weak self] response in
            if response.success == false {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            guard let comment = response.data?.comment, let users =  response.data?.users else {
                return
            }
            LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Comment.onPost, eventProperties: ["post_id": self?.postId ?? "", "comment_id": comment.id])
            let postComment = PostDetailDataModel.Comment(comment: comment, user: users[comment.userId])
            self?.postDetail?.commentCount += 1
            self?.comments.insert(postComment, at: 0)
            self?.delegate?.insertAndScrollToRecentComment(IndexPath(row: NSNotFound, section: 1))
            self?.notifyObjectChanges()
        }
    }
    
    private func postCommentsReply(commentId: String, comment: String) {
        let request = ReplyOnCommentRequest(postId: self.postId, text: comment, commentId: commentId)
        LMFeedClient.shared.replyOnComment(request) { [weak self] response in
            if response.success == false {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            guard let comment = response.data?.comment, let users =  response.data?.users else {
                return
            }
            LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Comment.reply, eventProperties: ["post_id": self?.postId ?? "", "comment_reply_id": comment.id, "comment_id": commentId])
            let postComment = PostDetailDataModel.Comment(comment: comment, user: users[comment.userId])
            self?.replyOnComment?.replies.insert(postComment, at: 0)
            self?.replyOnComment?.commentCount += 1
            guard let section = self?.comments.firstIndex(where:{$0.commentId == commentId}) else {
                self?.delegate?.didReceiveCommentsReply()
                return
            }
            self?.delegate?.insertAndScrollToRecentComment(IndexPath(row: 0, section: section+1))
        }
    }
    
    func likePost(postId: String) {
        let request = LikePostRequest(postId: postId)
        LMFeedClient.shared.likePost(request) {[weak self] response in
            if response.success {
                self?.notifyObjectChanges()
            } else {
                print(response.errorMessage)
                let isLike = !(self?.postDetail?.isLiked ?? false)
                self?.postDetail?.isLiked = isLike
                self?.postDetail?.likedCount += isLike ? 1 : -1
                self?.delegate?.reloadSection(IndexPath(row: 0, section: 0))
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func likeComment(postId: String, commentId: String, section: Int?, row: Int?) {
        let request = LikeCommentRequest(postId: postId, commentId: commentId)
        LMFeedClient.shared.likeComment(request) { [weak self] response in
            if response.success {
//                self?.notifyObjectChanges()
            } else {
                print(response.errorMessage)
                if let section = section, var comment = self?.comments[section] {
                    var tmpRow: Int = 0
                    if let row = row {
                        comment =  comment.replies[row]
                        tmpRow = row
                    }
                    let isLike = !(comment.isLiked)
                    comment.isLiked = isLike
                    comment.likedCount += isLike ? 1 : -1
                    self?.delegate?.reloadSection(IndexPath(row: tmpRow, section: section))
                }
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }

    func savePost(postId: String) {
        let request = SavePostRequest(postId: postId)
        LMFeedClient.shared.savePost(request) { [weak self] response in
            if response.success {
                self?.notifyObjectChanges()
            } else {
                self?.postDetail?.isSaved = !(self?.postDetail?.isSaved ?? false)
                self?.delegate?.reloadSection(IndexPath(row: 0, section: 0))
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
    func pinUnpinPost(postId: String) {
        let request = PinPostRequest(postId: postId)
        LMFeedClient.shared.pinPost(request) {[weak self] response in
            if response.success {
                self?.postDetail?.isPinned = !(self?.postDetail?.isPinned ?? false)
                self?.postDetail?.updatePinUnpinMenu()
                self?.delegate?.reloadSection(IndexPath(row: 0, section: 0))
                self?.notifyObjectChanges()
            } else {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
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
    
    func hasRightForCommentOnPost() -> Bool {
        if self.isAdmin() { return true }
        guard let rights = LocalPrefrerences.getMemberStateData()?.memberRights,
              let right = rights.filter({$0.state == .commentOrReplyOnPost}).first else {
            return true
        }
        return right.isSelected ?? true
    }
    
    func isAdmin() -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member else { return false }
        return member.state == 1
    }
    
    func isOwnPost() -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member, let post = self.postDetail else { return false }
        return post.feedByUser?.userId == member.userUniqueId
    }
    
    func isOwnComment(section: Int) -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member  else { return false }
        let comment = self.comments[section]
        return comment.user.userId == member.userUniqueId
    }
    
    func isOwnReply(section: Int, row: Int) -> Bool {
        guard let member = LocalPrefrerences.getMemberStateData()?.member  else { return false }
        let comment = self.comments[section].replies[row]
        return comment.user.userId == member.userUniqueId
    }
    
    func totalCommentsCount() -> String {
        let count = (self.postDetail?.commentCount) ?? 0
        let commentString = count > 1 ? "comments" : "comment"
        return "\(count) \(commentString)"
    }
}
