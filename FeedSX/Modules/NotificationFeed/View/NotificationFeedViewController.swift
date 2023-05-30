//
//  NotificationFeedViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 22/05/23.
//

import UIKit

class NotificationFeedViewController: BaseViewController {
    
    let notificationFeedTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    } ()
    let refreshControl = UIRefreshControl()
    var bottomLoadSpinner: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTableView()
        setTitleAndSubtile(title: "Notifications", subTitle: nil)
    }
    
    func setupTableView() {
        self.view.addSubview(notificationFeedTableView)
        notificationFeedTableView.translatesAutoresizingMaskIntoConstraints = false
        notificationFeedTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        notificationFeedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        notificationFeedTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        notificationFeedTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        notificationFeedTableView.register(UINib(nibName: NotificationFeedTableViewCell.nibName, bundle: NotificationFeedTableViewCell.bundle), forCellReuseIdentifier: NotificationFeedTableViewCell.nibName)
        notificationFeedTableView.delegate = self
        notificationFeedTableView.dataSource = self
        notificationFeedTableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        notificationFeedTableView.refreshControl = refreshControl
        setupSpinner()
    }
    
    func setupSpinner(){
        bottomLoadSpinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        bottomLoadSpinner.color = .gray
        self.notificationFeedTableView.tableFooterView = bottomLoadSpinner
        bottomLoadSpinner.hidesWhenStopped = true
    }
    
    func showAndHideBottomSpinner(_ show: Bool) {
        if show {
            bottomLoadSpinner.startAnimating()
            self.notificationFeedTableView.tableFooterView = bottomLoadSpinner
        } else {
            bottomLoadSpinner.stopAnimating()
            self.notificationFeedTableView.tableFooterView = nil
        }
    }
    
    @objc func refreshFeed() {
//        homeFeedViewModel.pullToRefresh()
    }

}

extension NotificationFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationFeedTableViewCell.nibName, for: indexPath) as! NotificationFeedTableViewCell
        cell.setupNotificationFeedCell()
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
//        if offsetY > contentHeight - (scrollView.frame.height + 60) && !bottomLoadSpinner.isAnimating && !homeFeedViewModel.isFeedLoading
//        {
//            bottomLoadSpinner.startAnimating()
//            homeFeedViewModel.getFeed()
//        }
    }
    
}

extension NotificationFeedViewController: NotificationFeedTableViewCellDelegate {
    
    func menuButtonClicked(_ cell: UITableViewCell) {
        print("menu clicked")
    }
    
}
