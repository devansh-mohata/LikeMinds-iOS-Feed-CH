//
//  HomeFeedViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import Foundation
import UIKit
import LMFeed

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
    
    let postingProgressStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .red
        return sv
    }()
    
    let postingImageView: UIImageView = {
        let imageSize = 50.0
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: imageSize, height: imageSize)
        imageView.drawCornerRadius(radius: CGSize(width: imageSize, height: imageSize))
        return imageView
    }()
    
    let postingLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .bold)
        label.text = "Posting"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTableView()
        setupCreateButton()
        setupPostingProgress()
        homeFeedViewModel.delegate = self
        homeFeedViewModel.getFeed()
        homeFeedViewModel.getMemberState()
        createPostButton.addTarget(self, action: #selector(createNewPost), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreationCompleted), name: .postCreationCompleted, object: nil)
        self.setTitleAndSubtile(title: "Home Feed", subTitle: nil)
        self.setRightItemsOfNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc func postCreationCompleted(notification: Notification) {
        print("postCreationCompleted")
        refreshFeed()
        self.postingImageView.isHidden = true
        self.postingLabel.isHidden = true
    }
    
    func setupTableView() {
        self.view.addSubview(postingProgressStackView)
        self.view.addSubview(feedTableView)
        self.view.addSubview(createPostButton)
        
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        feedTableView.topAnchor.constraint(equalTo: postingProgressStackView.bottomAnchor).isActive = true
        feedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        feedTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        feedTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        feedTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
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
        postingProgressStackView.addArrangedSubview(postingImageView)
        postingProgressStackView.addArrangedSubview(postingLabel)
        postingProgressStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        postingProgressStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        postingProgressStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
    }
    
    @objc func createNewPost() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as! HomeFeedImageVideoTableViewCell
        cell.setupFeedCell(homeFeedViewModel.feeds[indexPath.row], withDelegate: self)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - (scrollView.frame.height + 60) && !bottomLoadSpinner.isAnimating && !homeFeedViewModel.isFeedLoading
        {
            bottomLoadSpinner.startAnimating()
            homeFeedViewModel.getFeed()
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
            HomeFeedViewModel.postId = postId
            let postDetail = PostDetailViewController(nibName: "PostDetailViewController", bundle: Bundle(for: PostDetailViewController.self))
            self.navigationController?.pushViewController(postDetail, animated: true)
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
