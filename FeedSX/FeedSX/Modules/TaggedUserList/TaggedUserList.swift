//
//  TaggedUserList.swift
//  CollabMates
//
//  Created by Shashank on 02/06/21.
//  Copyright © 2021 CollabMates. All rights reserved.
//

import Foundation
import UIKit
import LikeMindsFeed


protocol TaggedUserListDelegate: AnyObject {
    func selectedMemberFromTagList(indexPath: IndexPath)
    func didSelectMemberFromTagList(_ user: User)
    func didScrolledToEnd()
    func hideTaggingViewContainer()
    func unhideTaggingViewContainer(heightValue: CGFloat)
    func didChangedTaggedList(taggedList: [TaggedUser])
}

extension TaggedUserListDelegate {
    func selectedMemberFromTagList(indexPath: IndexPath) {}
    func didSelectMemberFromTagList(_ user: User) {}
    func didScrolledToEnd() {}
    func didChangedTaggedList(taggedList: [TaggedUser]) {}
}

@objcMembers class TaggedUserList: UIView {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var isPrivateChatroom: Bool = false
    weak var delegate: TaggedUserListDelegate?
    let cellIdentifier = "TaggedListTableViewCell"
    var viewModel = TaggedUserListViewModel()
    var typeTextRangeInTextView: NSRange?
    var isTaggingViewHidden = true
    var isReloadTaggingListView = true
    var cellHeight = 50
    
    private var taggingView: TaggingView = TaggingView()
    
    class func nibView() -> TaggedUserList? {
        return UINib(nibName: "TaggedUserList", bundle: Bundle.lmBundle).instantiate(withOwner: nil, options: nil)[0] as? TaggedUserList
    }
    
    func setupTableView() {
        layer.masksToBounds = true
    }
    
    func setupTaggingView() {
        taggingView.defaultAttributes = [NSAttributedString.Key.foregroundColor: ColorConstant.textBlackColor, NSAttributedString.Key.font: LMBranding.shared.font(16, .regular)]
        taggingView.symbolAttributes = [NSAttributedString.Key.foregroundColor: LMBranding.shared.textLinkColor]
        taggingView.taggedAttributes = [NSAttributedString.Key.foregroundColor: LMBranding.shared.textLinkColor]
        taggingView.dataSource = self
        taggingView.symbol = "@"
    }
    
    func setUp() {
        setupTaggingView()
        viewModel.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: TaggedListTableViewCell.cellIdentifier, bundle: Bundle.lmBundle), forCellReuseIdentifier: TaggedListTableViewCell.cellIdentifier)
        tableView.superview?.addShadow()
    }
    
    func searchTaggedUserName(_ searchName: String) {
        viewModel.getTaggedUserList(searchName)
    }
    
    func showTaggingList(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        
        isReloadTaggingListView = true
        if text == "@" {
            viewModel.getSuggestionsFor(text, range: range)
        } else if viewModel.checkTextForTag(range: range, text: textView.text) {
            var inputString = ""
            if textView.text.count == 0 {
                return
            } else if (text == "") && textView.text.count >= range.location && (textView.text[textView.text.index(textView.text.startIndex, offsetBy: range.location)] == "@") {
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
    
    func initialTaggedUsers(taggedUsers: [TaggedUser]) {
        taggingView.initialTaggedList(list: taggedUsers)
    }
    
}

extension TaggedUserList {
    
    func textViewDidChange(_ textView: UITextView) {
        taggingView.textView = textView
        taggingView.textViewDidChange(textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        taggingView.textView = textView
        taggingView.textViewDidChangeSelection(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        taggingView.textView = textView
        taggingView.textView(textView, shouldChangeTextIn: range, replacementText: text)
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
        taggingView.updateTaggedList(allText: taggingView.textView.text, tagText: selectedMember)
//        self.delegate?.selectedMemberFromTagList(indexPath: indexPath)
//        self.delegate?.didSelectMemberFromTagList(selectedMember)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(cellHeight)
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
            var heightValue = cellHeight * viewModel.taggingUsers.count
            let maxHeight:Int = 4 * cellHeight
            heightValue = heightValue > maxHeight ? maxHeight : heightValue
            self.isTaggingViewHidden = false
            self.delegate?.unhideTaggingViewContainer(heightValue:  CGFloat(heightValue))
            tableView.reloadData()
        } else {
            self.isTaggingViewHidden = true
            self.delegate?.hideTaggingViewContainer()
        }
    }
}

extension TaggedUserList: TaggingViewDataSource {
    
    func tagging(_ tagging: TaggingView, didChangedTagableList tagableList: [String]) {
//        matchedList = tagableList
    }
    
    func tagging(_ tagging: TaggingView, didChangedTaggedList taggedList: [TaggedUser]) {
//        self.taggedList = taggedList
        self.delegate?.didChangedTaggedList(taggedList: taggedList)
    }
    
    func tagging(_ tagging: TaggingView, searchForTagableList fromText: String) {
        print("search for tagging....\(fromText)")
        let searchText = fromText == "@" ? "" : fromText
        viewModel.getSuggestionsFor(searchText)
    }
}
