//
//  PostDetailViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit
import LikeMindsFeed

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    @IBOutlet weak var commentTextView: LMTextView! {
        didSet{
            commentTextView.textColor = ColorConstant.textBlackColor
        }
    }
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
    var selectedReplyIndexPath: IndexPath?
    var selectedCommentSection: Int?
    var postId: String = ""
    var commentId: String?
    var isViewPost: Bool = true

    var viewModel: PostDetailViewModel = PostDetailViewModel()
    let taggingUserList: TaggedUserList =  {
        guard let userList = TaggedUserList.nibView() else { return TaggedUserList() }
        return userList
    }()
    
    let textViewPlaceHolder: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = "Write a comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let noCommentsFooterView: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 2
        label.font = LMBranding.shared.font(17, .medium)
        label.textAlignment = .center
        label.textColor = .lightGray
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
        viewModel.delegate = self
        viewModel.postId = self.postId
        postDetailTableView.rowHeight = 50
        refreshControl.addTarget(self, action: #selector(pullToRefreshData), for: .valueChanged)
        closeReplyToUserButton.addTarget(self, action: #selector(closeReplyToUsersCommentView), for: .touchUpInside)
        postDetailTableView.backgroundColor = ColorConstant.backgroudColor
        sendButton.isEnabled = false
        sendButton.tintColor = LMBranding.shared.buttonColor
        sendButton.addTarget(self, action: #selector(sendButtonClicked), for: .touchUpInside)
        postDetailTableView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(errorMessage), name: .postDetailErrorInApi, object: nil)
        postDetailTableView.sectionHeaderHeight = UITableView.automaticDimension
        postDetailTableView.estimatedSectionHeaderHeight = 75
        
        postDetailTableView.register(ReplyCommentTableViewCell.self, forCellReuseIdentifier: ReplyCommentTableViewCell.reuseIdentifier)
        postDetailTableView.register(CommentHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: CommentHeaderViewCell.reuseIdentifier)
        postDetailTableView.register(ViewMoreRepliesCell.self, forCellReuseIdentifier: ViewMoreRepliesCell.reuseIdentifier)
        postDetailTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
        postDetailTableView.register(UINib(nibName: HomeFeedDocumentTableViewCell.nibName, bundle: HomeFeedDocumentTableViewCell.bundle), forCellReuseIdentifier: HomeFeedDocumentTableViewCell.nibName)
        postDetailTableView.register(UINib(nibName: HomeFeedLinkTableViewCell.nibName, bundle: HomeFeedLinkTableViewCell.bundle), forCellReuseIdentifier: HomeFeedLinkTableViewCell.nibName)
        postDetailTableView.rowHeight = UITableView.automaticDimension
        postDetailTableView.estimatedRowHeight = 44
        postDetailTableView.separatorStyle = .none
        self.postDetailTableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        commentTextView.addSubview(textViewPlaceHolder)
        textViewPlaceHolder.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 8).isActive = true
        textViewPlaceHolder.leftAnchor.constraint(equalTo: commentTextView.leftAnchor, constant: 5).isActive = true
        commentTextView.delegate = self
        replyToUserContainer.isHidden = true
        replyToUserImageView.isHidden = true
        commentTextView.centerVertically()
        viewModel.getMemberState()
        viewModel.getComments()
        
        hideTaggingViewContainer()
        self.setTitleAndSubtile(title: "Post", subTitle: viewModel.totalCommentsCount())
        
        validateCommentRight()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setBackButtonIfNotExist()
        self.setupTaggingView()
    }
    
    func validateCommentRight() {
        if !viewModel.hasRightForCommentOnPost() {
            textViewPlaceHolder.text = MessageConstant.restrictToCommentOnPost
            sendButton.isHidden = true
            commentTextView.isUserInteractionEnabled = false
        } else {
            textViewPlaceHolder.text = "Write a comment"
            sendButton.isHidden = false
            commentTextView.isUserInteractionEnabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if !self.isViewPost {
                    self.commentTextView.becomeFirstResponder()
                }
            }
        }
    }
    
    func setAttributedTextForNoComments() {
        let myAttribute = [ NSAttributedString.Key.font: LMBranding.shared.font(18, .regular), NSAttributedString.Key.foregroundColor: ColorConstant.textBlackColor ]
        let noCommentFound = NSMutableAttributedString(string: "No comment found", attributes: myAttribute )
        let myAttribute2 = [ NSAttributedString.Key.font: LMBranding.shared.font(16, .regular), NSAttributedString.Key.foregroundColor: ColorConstant.postCaptionColor]
        let beFirstOne = NSMutableAttributedString(string: "\nBe the first one to comment", attributes: myAttribute2 )
        noCommentFound.append(beFirstOne)
        noCommentsFooterView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        self.noCommentsFooterView.attributedText = noCommentFound
        self.postDetailTableView.tableFooterView = noCommentsFooterView
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
        self.taggingUserListContainer.layer.borderWidth = 1
        self.taggingUserListContainer.layer.borderColor = ColorConstant.disableButtonColor.cgColor
        taggingUserListContainer.layer.cornerRadius = 8
    }
    
    func setBackButtonIfNotExist() {
//        guard self.navigationItem.backBarButtonItem == nil else {return}
        let backImage = UIImage(systemName: ImageIcon.backIcon)
        let backItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(dismissController))
        backItem.tintColor = LMBranding.shared.buttonColor
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func dismissController() {
        guard let _ = self.navigationController?.popViewController(animated: true) else {
            self.dismiss(animated: true)
            return
        }
    }
    
    @objc func pullToRefreshData() {
        viewModel.pullToRefreshData()
    }
    
    func moreMenuClicked(comment: PostDetailDataModel.Comment, isReplied: Bool) {
        guard let menus = comment.menuItems else { return }
        print("more taped reached VC")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menus {
            switch menu.id {
            case .commentReport:
                actionSheet.addAction(withOptions: menu.name) {
                    let reportContent = ReportContentViewController(nibName: "ReportContentViewController", bundle: Bundle(for: ReportContentViewController.self))
                    reportContent.entityId = comment.commentId
                    reportContent.entityCreatorId = comment.user.userId
                    reportContent.reportEntityType = isReplied ? .reply : .comment
                    self.navigationController?.pushViewController(reportContent, animated: true)
                }
            case .commentDelete:
                actionSheet.addAction(withOptions: menu.name) {
                    let deleteController = DeleteContentViewController(nibName: "DeleteContentViewController", bundle: Bundle(for: DeleteContentViewController.self))
                    deleteController.modalPresentationStyle = .overCurrentContext
                    deleteController.postId = comment.postId
                    deleteController.commentId = comment.commentId
                    deleteController.delegate = self
                    deleteController.isAdminRemoving = LocalPrefrerences.userUniqueId() != (comment.user.userId) ? self.viewModel.isAdmin() :  false
                    self.navigationController?.present(deleteController, animated: false)
                }
            case .commentEdit:
//                actionSheet.addAction(withOptions: menu.name) {}
                break
            case .pin:
//                actionSheet.addAction(withOptions: menu.name) {}
                break
            default:
                break
            }
        }
        actionSheet.addCancelAction(withOptions: "Cancel", actionHandler: nil)
        self.present(actionSheet, animated: true)
    }
    
    @objc func closeReplyToUsersCommentView() {
        replyToUserContainer.isHidden = true
        replyToUserImageView.isHidden = true
        viewModel.replyOnComment = nil
    }
    
    @objc func sendButtonClicked() {
        let text = commentTextView.trimmedText()
        guard !text.isEmpty else {return}
        viewModel.postComment(text: text)
        sendButton.isEnabled = false
        commentTextView.text = ""
        commentTextView.resignFirstResponder()
    }
    
    @objc
    override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
//              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
//              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] else {
            return
        }
        self.textViewContainerBottomConstraints.constant = (frame.size.height - self.view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    override func keyboardWillHide(_ sender: Notification) {
        self.textViewContainerBottomConstraints.constant = 0
        self.view.layoutIfNeeded()
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
           let post = viewModel.postDetail
        {
            switch post.postAttachmentType() {
            case .document:
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedDocumentTableViewCell.nibName, for: indexPath) as! HomeFeedDocumentTableViewCell
                cell.setupFeedCell(post, withDelegate: self)
                return cell
            case .link:
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedLinkTableViewCell.nibName, for: indexPath) as! HomeFeedLinkTableViewCell
                cell.setupFeedCell(post, withDelegate: self)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as! HomeFeedImageVideoTableViewCell
                cell.setupFeedCell(post, withDelegate: self)
                return cell
            }
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
        if (section == viewModel.comments.count), viewModel.comments.count < (viewModel.postDetail?.commentCount ?? 0), !viewModel.isCommentLoading {
            postDetailTableView.tableFooterView?.isHidden = false
            viewModel.getComments()
        } 
        return commentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let comment = viewModel.comments[indexPath.section - 1]
            if indexPath.row == comment.replies.count {
                viewModel.getCommentReplies(commentId: comment.commentId)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}

extension PostDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !textView.trimmedText().isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !textView.trimmedText().isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textViewPlaceHolder.isHidden = true
        self.typeTextRangeInTextView = range
        if text != "" {
            typeTextRangeInTextView?.location += 1
        }
        if text != " " {
            taggingUserList.showTaggingList(textView, shouldChangeTextIn: range, replacementText: text)
        } else {
            hideTaggingViewContainer()
        }

        if textView.textColor == LMBranding.shared.textLinkColor, text != "" {
            let colorAttr = [ NSAttributedString.Key.foregroundColor: ColorConstant.textBlackColor,
                              NSAttributedString.Key.font: LMBranding.shared.font(16, .regular)]
            let attributedString = NSMutableAttributedString(string: text, attributes: colorAttr)
            let combination = NSMutableAttributedString()
            combination.append(textView.attributedText)
            combination.append(attributedString)
            textView.attributedText = combination
            return false
        }
        let numLines = Int(textView.contentSize.height/textView.font!.lineHeight)
        textView.isScrollEnabled = (textView.bounds.height >= 80) && (numLines > 4)
        self.view.layoutIfNeeded()
        return true
    }
    
    func checkTextForTag(range: NSRange, text: String) -> Bool {
        guard text.count >= range.location, let lastText = text.substring(to: text.index(text.startIndex, offsetBy: range.location)).components(separatedBy: " ").last else {return false}
        return lastText.range(of: "@") != nil
    }
}

extension PostDetailViewController: PostDetailViewModelDelegate {
    
    func didReceiveComments() {
        refreshControl.endRefreshing()
        closeReplyToUsersCommentView()
        postDetailTableView.reloadData()
        self.subTitleLabel.text = viewModel.totalCommentsCount()
        postDetailTableView.tableFooterView?.isHidden = true
        if viewModel.comments.count == 0 {
            postDetailTableView.tableFooterView = nil
            postDetailTableView.tableFooterView?.isHidden = false
            self.setAttributedTextForNoComments()
        }
        
    }
    
    func didReceiveCommentsReply() {
        postDetailTableView.reloadData()
        closeReplyToUsersCommentView()
    }
    
    func insertAndScrollToRecentComment(_ indexPath: IndexPath) {
        if indexPath.row == NSNotFound {
            postDetailTableView.insertSections([1], with: .automatic)
            postDetailTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else {
//            postDetailTableView.insertRows(at: [indexPath], with: .automatic)
            postDetailTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }
        postDetailTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        postDetailTableView.tableFooterView?.isHidden = true
        closeReplyToUsersCommentView()
        self.subTitleLabel.text = viewModel.totalCommentsCount()
    }
    
    func reloadSection(_ indexPath: IndexPath) {
        postDetailTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
    
    
    func didReceivedMemberState() {
        validateCommentRight()
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
            viewModel.postId = postId
            closeReplyToUsersCommentView()
            commentTextView.becomeFirstResponder()
        case .likeCount:
            guard (postData?.likedCount ?? 0) > 0 else {return}
            let likedUserListView = LikedUserListViewController()
            likedUserListView.viewModel = .init(postId: postId, commentId: nil)
            self.navigationController?.pushViewController(likedUserListView, animated: true)
        case .sharePost:
            guard let postId = postData?.postId else { return }
            self.share(secondActivityItem: LocalPrefrerences.sharePostUrl(postId: postId))
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
            viewModel.likeComment(postId: selectedComment.postId ?? "", commentId: selectedComment.commentId, section:(section-1), row: nil)
        case .more:
            print("More Button Tapped - \(section)")
            self.selectedReplyIndexPath = nil
            self.selectedCommentSection = section - 1
            self.moreMenuClicked(comment: selectedComment, isReplied: false)
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
                postDetailTableView.reloadSections(IndexSet(integer: section), with: .none)
            } else {
                viewModel.getCommentReplies(commentId: selectedComment.commentId)
            }
        case .likeCount:
            print("likecount Button Tapped - \(section)")
            let postId = selectedComment.postId ?? ""
            guard selectedComment.likedCount > 0 else {return}
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
            viewModel.likeComment(postId: selectedComment.postId ?? "", commentId: selectedComment.commentId, section:(indexPath.section-1), row: indexPath.row)
        case .more:
            self.selectedReplyIndexPath = indexPath
            self.selectedCommentSection = nil
            self.moreMenuClicked(comment: selectedComment, isReplied: true)
        case .likeCount:
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
        if commentTextView.trimmedText().isEmpty {
            self.hideTaggingViewContainer()
            return
        }
        isTaggingViewHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations: {
            self.taggingUserListContainer.alpha = 1
            self.taggingUserListContainerHeightConstraints.constant = heightValue
            self.taggingUserList.frame = self.taggingUserListContainer.bounds
            self.view.layoutIfNeeded()
            
        }) { finished in
//            self.taggingUserListContainer.isHidden = false
        }
    }
}

extension PostDetailViewController: ProfileHeaderViewDelegate {
    func didTapOnMoreButton(selectedPost: PostFeedDataView?) {
        guard let menues = selectedPost?.postMenuItems else { return }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menues {
            switch menu.id {
            case .report:
                actionSheet.addAction(withOptions: menu.name) {
                    let reportContent = ReportContentViewController(nibName: "ReportContentViewController", bundle: Bundle(for: ReportContentViewController.self))
                    reportContent.entityId = selectedPost?.postId
                    reportContent.entityCreatorId = selectedPost?.feedByUser?.userId
                    reportContent.reportEntityType = .post
                    self.navigationController?.pushViewController(reportContent, animated: true)
                }
            case .delete:
                actionSheet.addAction(withOptions: menu.name) {
                    let deleteController = DeleteContentViewController(nibName: "DeleteContentViewController", bundle: Bundle(for: DeleteContentViewController.self))
                    deleteController.modalPresentationStyle = .fullScreen
                    deleteController.postId = selectedPost?.postId
                    deleteController.delegate = self
                    deleteController.isAdminRemoving = LocalPrefrerences.userUniqueId() != (selectedPost?.feedByUser?.userId ?? "") ? self.viewModel.isAdmin() :  false
                    self.navigationController?.present(deleteController, animated: true)
                }
            case .edit:
                actionSheet.addAction(withOptions: menu.name) {
                    guard let postId = selectedPost?.postId else {return}
                    let editPost = EditPostViewController(nibName: "EditPostViewController", bundle: Bundle(for: EditPostViewController.self))
                    editPost.postId = postId
                    self.navigationController?.pushViewController(editPost, animated: true)
                }
            case .pin:
                actionSheet.addAction(withOptions: menu.name) { [weak self] in
                    guard let postId = selectedPost?.postId else {return}
                    self?.viewModel.pinUnpinPost(postId: postId)
                }
            case .unpin:
                actionSheet.addAction(withOptions: menu.name) { [weak self] in
                    guard let postId = selectedPost?.postId else {return}
                    self?.viewModel.pinUnpinPost(postId: postId)
                }
            default:
                break
            }
        }
        actionSheet.addCancelAction(withOptions: "Cancel", actionHandler: nil)
        self.present(actionSheet, animated: true)
    }
}

extension PostDetailViewController: DeleteContentViewProtocol {
    
    func didReceivedDeletePostResponse(postId: String, commentId: String?) {
        guard let commentId = commentId else {
            NotificationCenter.default.post(name: .refreshHomeFeedData, object: nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let section = self.selectedCommentSection {
            self.viewModel.comments.remove(at: section)
            self.viewModel.postDetail?.commentCount -= (self.viewModel.postDetail?.commentCount ?? 0) > 0 ? 1 : 0
            self.subTitleLabel.text = self.viewModel.totalCommentsCount()
        } else if let indexpath = self.selectedReplyIndexPath {
            let comment = self.viewModel.comments[indexpath.section - 1]
            comment.replies.remove(at: indexpath.row)
            comment.commentCount -=  comment.commentCount > 0 ? 1 : 0
        }
        self.postDetailTableView.reloadData()
    }
}
