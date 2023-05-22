//
//  PostDetailViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit
import LMFeed

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    @IBOutlet weak var commentTextView: LMTextView!
    @IBOutlet weak var sendButton: LMButton!
    @IBOutlet weak var taggingUserListContainer: UIView!
    @IBOutlet weak var taggingUserListContainerHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var replyToUserLabel: LMLabel!
    @IBOutlet weak var closeReplyToUserButton: LMButton!
    @IBOutlet weak var replyToUserContainer: UIView!
    @IBOutlet weak var replyToUserImageView: UIImageView! {
        didSet{
            replyToUserImageView.makeCircleView()
        }
    }
    
    let refreshControl = UIRefreshControl()
    var spinner: UIActivityIndicatorView!
    var typeTextRangeInTextView: NSRange?
    var isTaggingViewHidden = true
    var isReloadTaggingListView = true

    var viewModel: PostDetailViewModel = PostDetailViewModel()
    let taggingUserList: TaggedUserList =  {
        guard let userList = TaggedUserList.nibView() else { return TaggedUserList() }
        userList.translatesAutoresizingMaskIntoConstraints = false
        return userList
    }()
    
    let textViewPlaceHolder: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(17, .regular)
        label.textColor = .lightGray
        label.text = "Write a comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let noCommentsFooterView: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(17, .medium)
        label.textColor = .lightGray
        label.text = "Write a comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
        viewModel.delegate = self
        postDetailTableView.rowHeight = 50
        refreshControl.addTarget(self, action: #selector(pullToRefreshData), for: .valueChanged)
        closeReplyToUserButton.addTarget(self, action: #selector(closeReplyToUsersCommentView), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        postDetailTableView.refreshControl = refreshControl
        postDetailTableView.keyboardDismissMode = .onDrag
        
        postDetailTableView.sectionHeaderHeight = UITableView.automaticDimension
        postDetailTableView.estimatedSectionHeaderHeight = 75
        
        postDetailTableView.register(ReplyCommentTableViewCell.self, forCellReuseIdentifier: ReplyCommentTableViewCell.reuseIdentifier)
        postDetailTableView.register(CommentHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: CommentHeaderViewCell.reuseIdentifier)
        postDetailTableView.register(ViewMoreRepliesCell.self, forCellReuseIdentifier: ViewMoreRepliesCell.reuseIdentifier)
        postDetailTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
        postDetailTableView.rowHeight = UITableView.automaticDimension
        postDetailTableView.estimatedRowHeight = 44
        postDetailTableView.separatorStyle = .none
        commentTextView.addSubview(textViewPlaceHolder)
        textViewPlaceHolder.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 8).isActive = true
        textViewPlaceHolder.leftAnchor.constraint(equalTo: commentTextView.leftAnchor, constant: 5).isActive = true
        commentTextView.delegate = self
        replyToUserContainer.isHidden = true
        replyToUserImageView.isHidden = true
        commentTextView.centerVertically()
        viewModel.getComments()
        self.setupTaggingView()
        hideTaggingViewContainer()
        self.setTitleAndSubtile(title: "Post", subTitle: "0 comments")
    }
    
    func setupSpinner(){
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        spinner.color = .gray
        self.postDetailTableView.tableFooterView = spinner
        spinner.hidesWhenStopped = true
        commentTextView.superview?.addShadow()
    }
    
    func setupTaggingView() {
        self.taggingUserListContainer.translatesAutoresizingMaskIntoConstraints = false
        self.taggingUserListContainer.addSubview(taggingUserList)
        taggingUserList.addConstraints(equalToView: self.taggingUserListContainer)
        taggingUserList.setUp()
        taggingUserList.delegate = self
    }
    
    @objc func pullToRefreshData() {
        viewModel.pullToRefreshData()
    }
    
    func moreMenuClicked(comment: PostDetailDataModel.Comment) {
        guard let menus = comment.menuItems else { return }
        print("more taped reached VC")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menus {
            switch menu.id {
            case .commentReport:
                actionSheet.addAction(withOptions: menu.name) {
                    let postDetail = ReportContentViewController(nibName: "ReportContentViewController", bundle: Bundle(for: ReportContentViewController.self))
                    self.navigationController?.pushViewController(postDetail, animated: true)
                }
            case .commentDelete:
                actionSheet.addAction(withOptions: menu.name) {}
            case .commentEdit:
                actionSheet.addAction(withOptions: menu.name) {}
            case .pin:
                actionSheet.addAction(withOptions: menu.name) {}
            default:
                break
            }
        }
        actionSheet.addCancelAction(withOptions: "Cancel", actionHandler: nil)
        self.present(actionSheet, animated: true)
    }
    
    func getSuggestionsFor(_ inputString: String, range: NSRange? = nil) {
        var inputString = inputString.lowercased()
        if let range = range, range.location <= inputString.count {
            let index = inputString.index(inputString.startIndex, offsetBy: range.location)
            inputString = String(inputString[..<index])
//            substring(to: range.location)
        }
        let seperatedStingsArray = inputString.components(separatedBy: "@")
        inputString = seperatedStingsArray.last ?? ""
        taggingUserList.searchTaggedUserName(inputString)
    }
    
    @objc func closeReplyToUsersCommentView() {
        replyToUserContainer.isHidden = true
        replyToUserImageView.isHidden = true
        viewModel.replyOnComment = nil
    }
    
    @objc func sendButtonClicked() {
        let text = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.postComment(text: text)
        commentTextView.text = ""
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = viewModel.postDetail else { return 0 }
        return viewModel.comments.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1}
//        return viewModel.comments[section - 1].replies.count
        return viewModel.repliesCount(section: section - 1)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as? HomeFeedImageVideoTableViewCell,
           let post = viewModel.postDetail
        {
            cell.setupFeedCell(post, withDelegate: self)
            return cell
        }
        let comment = viewModel.comments[indexPath.section - 1]
        if indexPath.row < (comment.replies.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReplyCommentTableViewCell.reuseIdentifier, for: indexPath) as! ReplyCommentTableViewCell
            cell.delegate = self
            cell.setupDataView(comment: comment.replies[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ViewMoreRepliesCell.reuseIdentifier, for: indexPath) as! ViewMoreRepliesCell
            cell.setupDataView(comment: comment)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil}
        let commentView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentHeaderViewCell.reuseIdentifier) as! CommentHeaderViewCell
        commentView.delegate = self
        commentView.section = section
        commentView.setupDataView(comment: viewModel.comments[section - 1])
        return commentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = viewModel.comments[indexPath.section - 1]
        if indexPath.row == comment.replies.count {
            viewModel.getCommentReplies(commentId: comment.commentId)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard (scrollView.contentSize.height == (scrollView.frame.size.height + position)), !spinner.isAnimating else {return}
        spinner.startAnimating()
        print("Next page...")
        viewModel.getComments()
    }
    
}

extension PostDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        textView.isScrollEnabled = textView.bounds.height >= 80
        textView.superview?.layoutIfNeeded()
        self.typeTextRangeInTextView = range
        if text != "" {
            typeTextRangeInTextView?.location += 1
        }
        taggingUserList.showTaggingList(textView, shouldChangeTextIn: range, replacementText: text)
        if (taggingUserList.isTaggingViewHidden && text != "@" ){
            if textView.textColor == LMBranding.shared.textLinkColor {
                let colorAttr = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                  NSAttributedString.Key.font: LMBranding.shared.font(16, .regular)]
                let attributedString = NSMutableAttributedString(string: text, attributes: colorAttr)
                let combination = NSMutableAttributedString()
                combination.append(textView.attributedText)
                combination.append(attributedString)
                textView.attributedText = combination
            }
        }
        return true
    }
    
    func checkTextForTag(range: NSRange, text: String) -> Bool {
        guard text.count >= range.location, let lastText = text.substring(to: text.index(text.startIndex, offsetBy: range.location)).components(separatedBy: " ").last else {return false}
        return lastText.range(of: "@") != nil
    }
}

extension PostDetailViewController: PostDetailViewModelDelegate {
    
    func didReceiveComments() {
        spinner.stopAnimating()
        refreshControl.endRefreshing()
        closeReplyToUsersCommentView()
        postDetailTableView.reloadData()
    }
    
    func didReceiveCommentsReply() {
        postDetailTableView.reloadData()
        closeReplyToUsersCommentView()
    }
    
    func insertAndScrollToRecentComment(_ indexPath: IndexPath) {
        if indexPath.row == NSNotFound {
            postDetailTableView.insertSections([1], with: .automatic)
        } else {
            postDetailTableView.insertRows(at: [indexPath], with: .automatic)
        }
        postDetailTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        closeReplyToUsersCommentView()
    }
}

extension PostDetailViewController: ActionsFooterViewDelegate {
    
    func didTappedAction(withActionType actionType: CellActionType, postData: PostFeedDataView?) {
        guard let postId = postData?.postId else { return }
        switch actionType {
        case .like:
            viewModel.likePost(postId: postId)
        case .savePost:
            viewModel.savePost(postId: postId)
        case .comment:
            HomeFeedViewModel.postId = postId
            closeReplyToUsersCommentView()
            commentTextView.becomeFirstResponder()
        case .likeCount:
            let likedUserListView = LikedUserListViewController()
            likedUserListView.viewModel = .init(postId: postId, commentId: nil)
            self.navigationController?.pushViewController(likedUserListView, animated: true)
        case .sharePost:
            break
        default:
            break
        }
    }
}

extension PostDetailViewController: CommentHeaderViewCellDelegate {
    func didTapActionButton(withActionType actionType: CellActionType, section: Int?) {
        guard let section = section else {return}
        let selectedComment = viewModel.comments[section-1]
        switch actionType {
        case .like:
            print("like Button Tapped - \(section)")
            viewModel.likeComment(postId: selectedComment.postId ?? "", commentId: selectedComment.commentId)
        case .more:
            print("More Button Tapped - \(section)")
            self.moreMenuClicked(comment: selectedComment)
        case .comment:
            print("reply Button Tapped - \(section)")
            replyToUserContainer.isHidden = false
            replyToUserImageView.isHidden = false
            replyToUserLabel.text = "Replying to \(selectedComment.user.name)"
            replyToUserImageView.setImage(withUrl: selectedComment.user.profileImageUrl ?? "", placeholder: UIImage.generateLetterImage(with: selectedComment.user.name))
            viewModel.replyOnComment = selectedComment
            commentTextView.becomeFirstResponder()
        case .commentCount:
            print("reply count Button Tapped - \(section)")
            if selectedComment.replies.count > 0 {
                selectedComment.replies = []
                postDetailTableView.reloadSections(IndexSet(integer: section), with: .automatic)
            } else {
                viewModel.getCommentReplies(commentId: selectedComment.commentId)
            }
        case .likeCount:
            print("likecount Button Tapped - \(section)")
            let postId = selectedComment.postId ?? ""
            let likedUserListView = LikedUserListViewController()
            likedUserListView.viewModel = .init(postId: postId, commentId: selectedComment.commentId)
            self.navigationController?.pushViewController(likedUserListView, animated: true)
        default:
            break
        }
    }
}

extension PostDetailViewController: ReplyCommentTableViewCellDelegate {
    func didTapActionButton(withActionType actionType: CellActionType, cell: UITableViewCell) {
        guard let indexPath = postDetailTableView.indexPath(for: cell) else { return }
        let selectedComment = viewModel.comments[indexPath.section-1].replies[indexPath.row]
        switch actionType {
        case .like:
            print("like Button Tapped")
            viewModel.likeComment(postId: selectedComment.postId ?? "", commentId: selectedComment.commentId)
        case .more:
            self.moreMenuClicked(comment: selectedComment)
        case .likeCount:
            print("likecount Button Tapped")
            let postId = selectedComment.postId ?? ""
            let likedUserListView = LikedUserListViewController()
            likedUserListView.viewModel = .init(postId: postId, commentId: selectedComment.commentId)
            self.navigationController?.pushViewController(likedUserListView, animated: true)
        case .sharePost:
            break
        default:
            break
        }
    }
}

extension PostDetailViewController: TaggedUserListDelegate {
    
    func didSelectMemberFromTagList(_ user: User) {
        hideTaggingViewContainer()
        var attributedMessage:NSAttributedString?
        if let attributedText = commentTextView.attributedText {
            attributedMessage = attributedText
        }
        commentTextView.textColor = .black
        if let selectedRange = commentTextView.selectedTextRange {
            commentTextView.attributedText = TaggedRouteParser.shared.createTaggednames(with: commentTextView.text, member: user, attributedMessage: attributedMessage, textRange: self.typeTextRangeInTextView)
            let increasedLength = commentTextView.attributedText.length - (attributedMessage?.length ?? 0)
            if let newPosition = commentTextView.position(from: selectedRange.start, offset: increasedLength) {
                commentTextView.selectedTextRange = commentTextView.textRange(from: newPosition, to: newPosition)
            }
        }
        if !viewModel.taggedUsers.contains(where: {$0.userUniqueId == user.userUniqueId}) {
            viewModel.taggedUsers.append(user)
        }
    }
    
    func hideTaggingViewContainer() {
        isTaggingViewHidden = true
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .showHideTransitionViews, animations: {
            self.taggingUserListContainer.alpha = 0
            self.taggingUserListContainerHeightConstraints.constant = 48
            self.view.layoutIfNeeded()
            
        }) { finished in
//            self.taggingUserListContainer.isHidden = true
        }
    }
    
    func unhideTaggingViewContainer(heightValue: CGFloat) {
        if !isReloadTaggingListView {return}
        isTaggingViewHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations: {
            self.taggingUserListContainer.alpha = 1
            self.taggingUserListContainerHeightConstraints.constant = heightValue
            self.view.layoutIfNeeded()
            
        }) { finished in
//            self.taggingUserListContainer.isHidden = false
        }
    }
}

extension PostDetailViewController: ProfileHeaderViewDelegate {
    func didTapOnMoreButton(selectedPost: PostFeedDataView?) {
        guard let menues = selectedPost?.postMenuItems else { return }
        print("more taped reached VC")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menues {
            switch menu.id {
            case .report:
                actionSheet.addAction(withOptions: menu.name) {
                    print("report menu clicked \(selectedPost?.caption)")
                    let postDetail = ReportContentViewController(nibName: "ReportContentViewController", bundle: Bundle(for: ReportContentViewController.self))
                    self.navigationController?.pushViewController(postDetail, animated: true)
                }
            case .delete:
                actionSheet.addAction(withOptions: menu.name) {
                    print("delete post menu clicked \(selectedPost?.caption)")
                }
            case .edit:
                actionSheet.addAction(withOptions: menu.name) {
                    print("edit post menu clicked \(selectedPost?.caption)")
                }
            default:
                break
            }
        }
        actionSheet.addCancelAction(withOptions: "Cancel", actionHandler: nil)
        self.present(actionSheet, animated: true)
    }
}
