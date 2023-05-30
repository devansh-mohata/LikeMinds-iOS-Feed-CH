//
//  HomeFeedViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import Foundation
import UIKit
import Kingfisher
import LikeMindsFeed

public final class HomeFeedViewControler: BaseViewController {
    
    let feedTableView: UITableView = UITableView()
    let homeFeedViewModel = HomeFeedViewModel()
    let refreshControl = UIRefreshControl()
    var bottomLoadSpinner: UIActivityIndicatorView!
    let createPostButton: LMButton = {
        let createPost = LMButton()
        createPost.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        createPost.setTitle("NEW POST", for: .normal)
        createPost.titleLabel?.font = LMBranding.shared.font(13, .medium)
        createPost.tintColor = .white
        createPost.backgroundColor = LMBranding.shared.buttonColor
        createPost.clipsToBounds = true
        createPost.translatesAutoresizingMaskIntoConstraints = false
        return createPost
    }()
    
    let postingProgressSuperStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let postingProgressStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let postingImageView: UIImageView = {
        let imageSize = 50.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        return imageView
    }()
    
    let postingImageSuperView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setSizeConstraint(width: 70, height: 70)
        return view
    }()
    
    let postingLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .medium)
        label.text = "Posting"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let leftTitleLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(24, .medium)
        label.textColor = .white
        label.text = "Scalix"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    var spaceView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .red
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let progressIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTableView()
        setupCreateButton()
        setupPostingProgress()
        homeFeedViewModel.delegate = self
        self.postingImageSuperView.superview?.isHidden = true
        homeFeedViewModel.getFeed()
        createPostButton.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreationCompleted), name: .postCreationCompleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreationStarted), name: .postCreationStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFeed), name: .refreshHomeFeedData, object: nil)
//        self.setTitleAndSubtile(title: "Home Feed", subTitle: nil)
        self.setRightItemsOfNavigationBar()
        self.setLeftItemOfNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeFeedViewModel.getMemberState()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAllVideo()
    }
    
    func setRightItemsOfNavigationBar() {
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let profileImageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        profileImageview.makeCircleView()
        profileImageview.setImage(withUrl: LocalPrefrerences.getUserData()?.imageUrl ?? "", placeholder: UIImage.generateLetterImage(with:  LocalPrefrerences.getUserData()?.name ?? ""))
        
        containView.addSubview(profileImageview)
        let profileBarButton = UIBarButtonItem(customView: containView)
        let notificationFeedBarButton = UIBarButtonItem(image: UIImage(systemName: ImageIcon.bellFillIcon), style: .plain, target: self, action: #selector(notificationIconClicked))
        notificationFeedBarButton.tintColor = ColorConstant.textBlackColor
        notificationFeedBarButton.addBadge(number: 2)
        self.navigationItem.rightBarButtonItems = [profileBarButton, notificationFeedBarButton]
    }
    
    func setLeftItemOfNavigationBar() {
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftTitleLabel.center = containView.center
        containView.addSubview(leftTitleLabel)
        let leftItem = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    @objc func postCreationStarted(notification: Notification) {
        print("postCreationStarted")
        self.postingImageSuperView.superview?.isHidden = false
        if let image = notification.object as? UIImage {
            postingImageView.image = image
        } else {
            postingImageView.image = UIImage(systemName: "photo")
        }
    }
    
    @objc func postCreationCompleted(notification: Notification) {
        print("postCreationCompleted")
        self.postingImageSuperView.superview?.isHidden = true
        if let error = notification.object as? String {
            self.presentAlert(message: error)
            return
        }
        refreshFeed()
    }
    
    
    func setupTableView() {
        self.view.addSubview(postingProgressSuperStackView)
        self.view.addSubview(feedTableView)
        self.view.addSubview(createPostButton)
        
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        feedTableView.topAnchor.constraint(equalTo: postingProgressSuperStackView.bottomAnchor).isActive = true
        feedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        feedTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        feedTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        feedTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
        feedTableView.register(UINib(nibName: HomeFeedDocumentTableViewCell.nibName, bundle: HomeFeedDocumentTableViewCell.bundle), forCellReuseIdentifier: HomeFeedDocumentTableViewCell.nibName)
//        feedTableView.register(ImageVideoCollectionTableViewCell.self, forCellReuseIdentifier: ImageVideoCollectionTableViewCell.cellIdentifier)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        feedTableView.refreshControl = refreshControl
        setupSpinner()
    }
    func setupSpinner(){
        bottomLoadSpinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        bottomLoadSpinner.color = .gray
        self.feedTableView.tableFooterView = bottomLoadSpinner
        bottomLoadSpinner.hidesWhenStopped = true
    }
    
    func setupCreateButton() {
        createPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        createPostButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        createPostButton.setSizeConstraint(width: 150, height: 50)
        createPostButton.setInsets(forContentPadding: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), imageTitlePadding: 10)
        createPostButton.layer.cornerRadius = 25
    }
    
    func setupPostingProgress() {
        postingProgressSuperStackView.addArrangedSubview(postingProgressStackView)
        postingProgressStackView.addArrangedSubview(postingImageSuperView)
        postingProgressStackView.addArrangedSubview(postingLabel)
        postingProgressStackView.addArrangedSubview(spaceView)
        postingProgressStackView.addArrangedSubview(progressIndicator)
        postingImageSuperView.addSubview(postingImageView)
        postingImageView.centerYAnchor.constraint(equalTo: self.postingImageSuperView.centerYAnchor).isActive = true
        postingImageView.centerXAnchor.constraint(equalTo: self.postingImageSuperView.centerXAnchor).isActive = true
        spaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        postingProgressSuperStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        postingProgressSuperStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        postingProgressSuperStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
    }
    
    @objc func createNewPost() {
        guard self.homeFeedViewModel.hasRightForCreatePost() else  {
            self.presentAlert(message: MessageConstant.restrictToCreatePost)
            return
        }
        let createView = CreatePostViewController(nibName: "CreatePostViewController", bundle: Bundle(for: CreatePostViewController.self))
        self.navigationController?.pushViewController(createView, animated: true)
    }
    
    @objc func refreshFeed() {
        homeFeedViewModel.pullToRefresh()
    }
    
    @objc func notificationIconClicked() {
        let notificationFeedVC = NotificationFeedViewController()
        self.navigationController?.pushViewController(notificationFeedVC, animated: true)
    }
}

extension HomeFeedViewControler: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeFeedViewModel.feeds.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = homeFeedViewModel.feeds[indexPath.row]
        switch feed.postAttachmentType() {
        case .document:
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedDocumentTableViewCell.nibName, for: indexPath) as! HomeFeedDocumentTableViewCell
            cell.setupFeedCell(feed, withDelegate: self)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as! HomeFeedImageVideoTableViewCell
            cell.setupFeedCell(feed, withDelegate: self)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeFeedImageVideoTableViewCell {
            cell.pauseAllInVisibleVideos()
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeFeedImageVideoTableViewCell {
            cell.pauseAllInVisibleVideos()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        checkWhichVideoToEnable()
        if offsetY > contentHeight - (scrollView.frame.height + 60) && !bottomLoadSpinner.isAnimating && !homeFeedViewModel.isFeedLoading
        {
            bottomLoadSpinner.startAnimating()
            homeFeedViewModel.getFeed()
        }
    }
    
    func checkWhichVideoToEnable() {
        
        for cell in feedTableView.visibleCells as [UITableViewCell] {
            
            if let cell = cell as? HomeFeedImageVideoTableViewCell {
                
                let indexPath = feedTableView.indexPath(for: cell)
                let cellRect = feedTableView.rectForRow(at: indexPath!)
                let superView = feedTableView.superview
                
                let convertedRect = feedTableView.convert(cellRect, to: superView)
                let intersect = CGRectIntersection(feedTableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                cell.pauseAllInVisibleVideos()
                if visibleHeight > self.view.bounds.size.height * 0.6 {  // only if 60% of the cell is visible.
                    //cell is visible more than 60%
                    cell.playVisibleVideo()
                    print(indexPath?.row) //your visible cell.
                }
            } else {
                (cell as? HomeFeedImageVideoTableViewCell)?.pauseAllInVisibleVideos()
            }
        }
    }
    
    func pauseAllVideo() {
        for cell in feedTableView.visibleCells as [UITableViewCell] {
            (cell as? HomeFeedImageVideoTableViewCell)?.pauseAllInVisibleVideos()
        }
    }
    
}

extension HomeFeedViewControler: HomeFeedViewModelDelegate {
    
    func didReceivedFeedData(success: Bool) {
        bottomLoadSpinner.stopAnimating()
        refreshControl.endRefreshing()
        guard success else {return}
        feedTableView.reloadData()
    }
    
    func didReceivedMemberState() {
        if self.homeFeedViewModel.hasRightForCreatePost() {
            self.createPostButton.backgroundColor = LMBranding.shared.buttonColor
        } else {
            self.createPostButton.backgroundColor = .lightGray
        }
    }
}

extension HomeFeedViewControler: ProfileHeaderViewDelegate {
    func didTapOnMoreButton(selectedPost: PostFeedDataView?) {
        guard let menues = selectedPost?.postMenuItems else { return }
        print("more taped reached VC")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menues {
            switch menu.id {
            case .report:
                actionSheet.addAction(withOptions: menu.name) {
                    print("report menu clicked \(selectedPost?.caption)")
                    let reportContent = ReportContentViewController(nibName: "ReportContentViewController", bundle: Bundle(for: ReportContentViewController.self))
                    reportContent.entityId = selectedPost?.postId
                    reportContent.entityCreatorId = selectedPost?.feedByUser?.userId
                    reportContent.reportEntityType = .post
                    self.navigationController?.pushViewController(reportContent, animated: true)
                }
            case .delete:
                actionSheet.addAction(withOptions: menu.name) {
                    print("delete post menu clicked \(selectedPost?.caption)")
                    let deleteController = DeleteContentViewController(nibName: "DeleteContentViewController", bundle: Bundle(for: DeleteContentViewController.self))
                    deleteController.modalPresentationStyle = .overCurrentContext
                    deleteController.postId = selectedPost?.postId
                    deleteController.delegate = self
                    deleteController.isAdminRemoving = LocalPrefrerences.userUniqueId() != (selectedPost?.feedByUser?.userId ?? "") ? self.homeFeedViewModel.isAdmin() :  false
                    self.navigationController?.present(deleteController, animated: false)
                }
            case .edit:
//                actionSheet.addAction(withOptions: menu.name) {}
                break
            default:
                break
            }
        }
        actionSheet.addCancelAction(withOptions: "Cancel", actionHandler: nil)
        self.present(actionSheet, animated: true)
    }
}

extension HomeFeedViewControler: ActionsFooterViewDelegate {
   
    func didTappedAction(withActionType actionType: CellActionType, postData: PostFeedDataView?) {
        switch actionType {
        case .like:
            guard let postId = postData?.postId else { return }
            homeFeedViewModel.likePost(postId: postId)
        case .savePost:
            guard let postId = postData?.postId else { return }
            homeFeedViewModel.savePost(postId: postId)
        case .comment:
            guard let postId = postData?.postId else { return }
            let postDetail = PostDetailViewController(nibName: "PostDetailViewController", bundle: Bundle(for: PostDetailViewController.self))
            postDetail.postId = postId
            self.navigationController?.pushViewController(postDetail, animated: true)
        case .likeCount:
            guard let postId = postData?.postId, (postData?.likedCount ?? 0) > 0 else { return }
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

extension HomeFeedViewControler: DeleteContentViewProtocol {
    
    func didReceivedDeletePostResponse(postId: String, commentId: String?) {
        homeFeedViewModel.feeds.removeAll(where: {$0.postId == postId})
        feedTableView.reloadData()
    }
}
