//
//  TaggedUserListViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 11/05/23.
//

import Foundation
import LMFeed

protocol TaggedUserListViewModelDelegate: AnyObject {
    func didReceiveTaggedUserList()
}

class TaggedUserListViewModel {
    
    private var currentPage: Int = 1
    var taggingUsers: [User] = []
    weak var delegate: TaggedUserListViewModelDelegate?
    private var searchUsername: String = ""
    var taggingSearchDebounceTime: Timer?
    
    private func fetchTaggingList(_ searchName: String) {
        let request = GetTaggingListRequest(searchName: searchName)
            .page(currentPage)
            .pageSize(10)
        LMFeedClient.shared.getTaggingList(request) {[weak self] response in
            guard let users = response.data?.members, users.count > 0 else {
                if (self?.currentPage ?? 0) == 1 {
                    self?.taggingUsers = []
                    self?.delegate?.didReceiveTaggedUserList()
                }
                return
            }
            if (self?.currentPage ?? 0) > 1 {
                self?.taggingUsers.append(contentsOf: users)
            } else {
                self?.taggingUsers = users
            }
            self?.currentPage += 1
            self?.delegate?.didReceiveTaggedUserList()
        }
    }
    
    func loadTaggingList() {
        self.fetchTaggingList(self.searchUsername)
    }
    
    func getTaggedUserList(_ searchName: String) {
        self.currentPage = 1
        self.searchUsername = searchName
        self.fetchTaggingList(searchName)
    }
    
    func getSuggestionsFor(_ inputString: String, range: NSRange? = nil) {
        taggingSearchDebounceTime?.invalidate()
        taggingSearchDebounceTime = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let weakSelf = self else {return}
                var inputString = inputString.lowercased()
                if let range = range, range.location <= inputString.count {
                    let index = inputString.index(inputString.startIndex, offsetBy: range.location)
                    inputString = String(inputString[..<index])
                }
                let seperatedStingsArray = inputString.components(separatedBy: "@")
                inputString = seperatedStingsArray.last ?? ""
                weakSelf.getTaggedUserList(inputString)
            }
        })
    }
    
}
