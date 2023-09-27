//
//  LikedUserListViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 11/04/23.
//

import UIKit

class LikedUserListViewController: BaseViewController {
    
    var viewModel: LikedUserListViewModel?
    
    let likedUserTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(errorMessage), name: .errorInApi, object: nil)
        self.view.backgroundColor = .white
        self.view.addSubview(likedUserTableView)
        likedUserTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        likedUserTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        likedUserTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        likedUserTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        likedUserTableView.delegate = self
        likedUserTableView.dataSource = self
        likedUserTableView.register(LikedUserTableViewCell.self, forCellReuseIdentifier: LikedUserTableViewCell.reuseIdentifier)
        self.viewModel?.delegate = self
        self.viewModel?.fetchLikedUsers()
        self.setTitleAndSubtile(title: "Likes", subTitle: "")
    }
    
}

extension LikedUserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.likedUsers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LikedUserTableViewCell.reuseIdentifier) as? LikedUserTableViewCell,
              let data = self.viewModel?.likedUsers[indexPath.row] else {
            return UITableViewCell()
        }
        cell.setupUserData(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.viewModel?.likedUsers[indexPath.row]
        LikeMindsFeedSX.shared.delegate?.openProfile(userUUID: data?.userUUID ?? "")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard (scrollView.contentSize.height == (scrollView.frame.size.height + position)) else {return}
        self.viewModel?.fetchLikedUsers()
    }
}

extension LikedUserListViewController: LikedUserListViewModelDelegate {
    func reloadLikedUserList() {
        let likes = (self.viewModel?.totalLikes ?? 0)
        self.subTitleLabel.text = likes > 1 ? "\(likes) likes" : "\(likes) like"
        self.likedUserTableView.reloadData()
    }
    
    func responseFailed(withError error: String?) {
        self.showErrorAlert(message: error)
    }
}
