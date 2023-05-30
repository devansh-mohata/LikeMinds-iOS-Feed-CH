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
}

final class PostDetailViewModel {
    
    var comments: [PostDetailDataModel.Comment] = []
    var postDetail: PostFeedDataView?
    private var commentCurrentPage: Int = 1
    var commentPageSize: Int = 10
    private var repliesCurrentPage1: Int = 1
    var isCommentLoading: Bool = false
    var isCommentRepliesLoading: Bool = false
    weak var delegate: PostDetailViewModelDelegate?
    var postId: String = HomeFeedViewModel.postId
    var taggedUsers: [User] = []
    var replyOnComment: PostDetailDataModel.Comment?
    
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
        let request = GetCommentRequest(postId: HomeFeedViewModel.postId, commentId: commentId)
            .page(repliesCurrentPage)
            .pageSize(5)
        LMFeedClient.shared.getComment(request) {[weak self] response in
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
            guard let comment = response.data?.comment, let users =  response.data?.users else {
                return
            }
            let postComment = PostDetailDataModel.Comment(comment: comment, user: users[comment.userId])
            self?.postDetail?.commentCount += 1
            self?.comments.insert(postComment, at: 0)
            self?.delegate?.insertAndScrollToRecentComment(IndexPath(row: NSNotFound, section: 1))
        }
    }
    
    private func postCommentsReply(commentId: String, comment: String) {
        let request = ReplyOnCommentRequest(postId: self.postId, text: comment, commentId: commentId)
        LMFeedClient.shared.replyOnComment(request) { [weak self] response in
            guard let comment = response.data?.comment, let users =  response.data?.users else {
                return
            }
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
        LMFeedClient.shared.likePost(request) { response in
            if response.success {
                
            } else {
                print(response.errorMessage)
            }
        }
    }
    
    func likeComment(postId: String, commentId: String) {
        let request = LikeCommentRequest(postId: postId, commentId: commentId)
        LMFeedClient.shared.likeComment(request) { response in
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
    
    func hasRightForCommentOnPost() -> Bool {
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
    
    func sharePostUrl(postId: String) -> String {
        return "\(LMFeedClient.shared.domainUrl())/post?post_id=\(postId)"
    }
}
