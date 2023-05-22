//
//  TaggedUserList.swift
//  CollabMates
//
//  Created by Shashank on 02/06/21.
//  Copyright © 2021 CollabMates. All rights reserved.
//

import Foundation
import UIKit
import LMFeed


protocol TaggedUserListDelegate: AnyObject {
    func selectedMemberFromTagList(indexPath: IndexPath)
    func didSelectMemberFromTagList(_ user: User)
    func didScrolledToEnd()
    func hideTaggingViewContainer()
    func unhideTaggingViewContainer(heightValue: CGFloat)
}

extension TaggedUserListDelegate {
    func selectedMemberFromTagList(indexPath: IndexPath) {}
    func didSelectMemberFromTagList(_ user: User) {}
    func didScrolledToEnd() {}
}

@objcMembers class TaggedUserList: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var isPrivateChatroom: Bool = false
    var delegate: TaggedUserListDelegate?
    let cellIdentifier = "TaggedListTableViewCell"
    var viewModel = TaggedUserListViewModel()
    var typeTextRangeInTextView: NSRange?
    var isTaggingViewHidden = true
    var isReloadTaggingListView = true
    
    
    class func nibView() -> TaggedUserList? {
        return UINib(nibName: "TaggedUserList", bundle: Bundle(for: TaggedUserList.self)).instantiate(withOwner: nil, options: nil)[0] as? TaggedUserList
    }
    
    func setupTableView() {
        layer.masksToBounds = true
    }
    
    func setUp() {
        viewModel.delegate = self
        tableView.register(UINib(nibName: TaggedListTableViewCell.cellIdentifier, bundle: Bundle(for: TaggedListTableViewCell.self)), forCellReuseIdentifier: TaggedListTableViewCell.cellIdentifier)
    }
    
    func searchTaggedUserName(_ searchName: String) {
        viewModel.getTaggedUserList(searchName)
    }

    /*
    func hideTaggingViewContainer() {
        isTaggingViewHidden = true
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .showHideTransitionViews, animations: {
            //            self.taggingUserListContainer.alpha = 0
            self.tableViewHeightConstraint.constant = 0.1
            self.layoutIfNeeded()
        }) { finished in
            //            self.taggingUserListContainer.isHidden = true
        }
    }
    
    func unhideTaggingViewContainer(heightValue: CGFloat = 250) {
        if !isReloadTaggingListView {return}
        isTaggingViewHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations: {
            //            self.taggingUserListContainer.alpha = 1
            self.tableViewHeightConstraint.constant = heightValue
            self.layoutIfNeeded()
            
        }) { finished in
            //            self.taggingUserListContainer.isHidden = false
        }
    }
    */
    
    func showTaggingList(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        
        isReloadTaggingListView = true
        if text == "@" {
            viewModel.getSuggestionsFor(text, range: range)
        } else if !isTaggingViewHidden || checkTextForTag(range: range, text: textView.text) {
            var inputString = ""
            if textView.text.count == 0 {
                return
            } else if (text == "") && (textView.text[textView.text.index(textView.text.startIndex, offsetBy: range.location)] == "@") {
                isReloadTaggingListView = false
                self.delegate?.hideTaggingViewContainer()
                return
            } else if (text == "") && (textView.text.count == 1) {
                inputString = ""
            } else if text == "" {
                inputString = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: range.location))
            } else {
                inputString = "\(textView.text ?? "")\(text)"
            }
            viewModel.getSuggestionsFor(inputString, range: range)
        } else {
            self.delegate?.hideTaggingViewContainer()
        }
    }
    
    func checkTextForTag(range: NSRange, text: String) -> Bool {
        guard text.count >= range.location, let lastText = text.substring(to: text.index(text.startIndex, offsetBy: range.location)).components(separatedBy: " ").last else {return false}
        return lastText.range(of: "@") != nil
    }
    
}

extension TaggedUserList: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.taggingUsers.count > 0 {
            return viewModel.taggingUsers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userTaggingCell = tableView.dequeueReusableCell(withIdentifier: TaggedListTableViewCell.cellIdentifier) as? TaggedListTableViewCell
        if viewModel.taggingUsers.count > 0 {
            userTaggingCell?.setMemberForTag(viewModel.taggingUsers[indexPath.row])
            userTaggingCell?.isUserInteractionEnabled = true
        }
        return userTaggingCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.taggingUsers.count else {return}
        let selectedMember = viewModel.taggingUsers[indexPath.row]
        self.delegate?.selectedMemberFromTagList(indexPath: indexPath)
        self.delegate?.didSelectMemberFromTagList(selectedMember)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension TaggedUserList: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard (scrollView.contentSize.height == (scrollView.frame.size.height + position)) else {return}
        viewModel.loadTaggingList()
    }
}

extension TaggedUserList: TaggedUserListViewModelDelegate {
    
    func didReceiveTaggedUserList() {
        if viewModel.taggingUsers.count > 0 {
            var heightValue = CGFloat(60 * viewModel.taggingUsers.count)
            heightValue = heightValue > 300 ? 300 : heightValue
            self.isTaggingViewHidden = false
            self.delegate?.unhideTaggingViewContainer(heightValue:  heightValue)
            tableView.reloadData()
        } else {
            self.isTaggingViewHidden = true
            self.delegate?.hideTaggingViewContainer()
        }
    }
}
