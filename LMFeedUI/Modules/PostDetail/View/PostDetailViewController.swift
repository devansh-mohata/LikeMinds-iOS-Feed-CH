//
//  PostDetailViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    @IBOutlet weak var commentTextView: LMTextView!
    @IBOutlet weak var sendButton: LMButton!
    
    var viewModel: PostDetailViewModel = PostDetailViewModel()
    
    let textViewPlaceHolder: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(14, .regular)
        label.textColor = .lightGray
        label.text = "Write a comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        postDetailTableView.rowHeight = 50
        postDetailTableView.keyboardDismissMode = .onDrag
        
        postDetailTableView.sectionHeaderHeight = UITableView.automaticDimension
        postDetailTableView.estimatedSectionHeaderHeight = 75
        
        postDetailTableView.register(ReplyCommentTableViewCell.self, forCellReuseIdentifier: ReplyCommentTableViewCell.reuseIdentifier)
        postDetailTableView.register(CommentHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: CommentHeaderViewCell.reuseIdentifier)
        postDetailTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
        postDetailTableView.rowHeight = UITableView.automaticDimension
        postDetailTableView.estimatedRowHeight = 44
        postDetailTableView.separatorStyle = .none
        commentTextView.addSubview(textViewPlaceHolder)
        textViewPlaceHolder.centerYAnchor.constraint(equalTo: commentTextView.centerYAnchor).isActive = true
        commentTextView.delegate = self
        commentTextView.centerVertically()
        viewModel.getPostDetails()
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let postDetail = viewModel.postDetail else { return 0 }
        return viewModel.comments.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1}
        return viewModel.comments[section - 1].replies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as? HomeFeedImageVideoTableViewCell,
           let post = viewModel.postDetail
        {
            cell.setupFeedCell(post, withDelegate: self)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReplyCommentTableViewCell.reuseIdentifier, for: indexPath) as! ReplyCommentTableViewCell
        cell.setupDataView(comment: viewModel.comments[indexPath.section - 1].replies[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil}
        let commentView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentHeaderViewCell.reuseIdentifier) as! CommentHeaderViewCell
        commentView.setupDataView(comment: viewModel.comments[section - 1])
        return commentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            
            return nil
        }
        return nil
    }
}

extension PostDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = true
    }
}

extension PostDetailViewController: PostDetailViewModelDelegate {
    
    func didReceiveComments() {
        postDetailTableView.reloadData()
    }
}

extension PostDetailViewController: ActionsFooterViewDelegate {
    
    func didTappedAction(withActionType actionType: CellActionType, postData: PostFeedDataView?) {
        switch actionType {
        case .like:
            guard let postId = postData?.postId else { return }
//            homeFeedViewModel.likePost(postId: postId)
        case .savePost:
            guard let postId = postData?.postId else { return }
//            homeFeedViewModel.savePost(postId: postId)
        case .comment:
            guard let postId = postData?.postId else { return }
            HomeFeedViewModel.postId = postId
        case .likeCount:
            guard let postId = postData?.postId else { return }
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
