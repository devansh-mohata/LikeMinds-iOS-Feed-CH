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
    let createPostButton: LMButton = {
        let createPost = LMButton()
        createPost.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        createPost.setTitle("NEW POST", for: .normal)
        createPost.backgroundColor = .blue
        createPost.clipsToBounds = true
        createPost.translatesAutoresizingMaskIntoConstraints = false
        return createPost
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        homeFeedViewModel.delegate = self
        homeFeedViewModel.getFeed()
        homeFeedViewModel.getMemberState()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(LocalPrefrerences.getUserData())
    }
    
    func setupTableView() {
        self.view.addSubview(feedTableView)
        self.view.addSubview(createPostButton)
        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        feedTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        feedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        feedTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        feedTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        feedTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
//        feedTableView.register(ImageVideoCollectionTableViewCell.self, forCellReuseIdentifier: ImageVideoCollectionTableViewCell.cellIdentifier)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.separatorStyle = .none
        createPostButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16).isActive = true
        createPostButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 16).isActive = true
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
    
}

extension HomeFeedViewControler: HomeFeedViewModelDelegate {
    
    func didFeedReceived() {
        feedTableView.reloadData()
    }
}

extension HomeFeedViewControler: ProfileHeaderViewDelegate {
    func didTapOnMoreButton(selectedPost: HomeFeedDataView?) {
        guard let menues = selectedPost?.postMenuItems else { return }
        print("more taped reached VC")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for menu in menues {
            switch menu.id {
            case .report:
                actionSheet.addAction(withOptions: menu.name) {
                    print("report menu clicked \(selectedPost?.caption)")
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
   
    func didTappedAction(withActionType actionType: ActionType, postData: HomeFeedDataView?) {
        switch actionType {
        case .like:
            guard let postId = postData?.postId else { return }
            homeFeedViewModel.likePost(postId: postId)
        case .savePost:
            guard let postId = postData?.postId else { return }
            homeFeedViewModel.savePost(postId: postId)
        case .comment:
            break
        case .likeCount:
            break
        case .sharePost:
            break
        }
    }
}
