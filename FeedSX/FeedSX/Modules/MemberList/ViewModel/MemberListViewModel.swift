//
//  MemberListViewModel.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 02/09/23.
//

import Foundation
import LikeMindsFeed

protocol MemberListViewModelDelegate: AnyObject {
    func didReceivedMemberListData()
    func didFailedToReceivedMemberListData()
}

final class MemberListViewModel: BaseViewModel {
    
    var communityMembers: [MemberListDataView.MemberDataView] = []
    var totalMembersCount: Int = 0
    weak var delegate: MemberListViewModelDelegate?
    private var currentPage: Int = 1
    var isFetching: Bool = false
    private var searchName: String = ""
    private var searchNameDebounce: Timer?
    
    func fetchAllMembers(isNextFetch: Bool = false) {
        if isNextFetch {
            self.fetchTaggingList(searchName)
        } else {
            self.currentPage = 1
            self.fetchTaggingList(searchName)
        }
    }
    
    func searchMember(withName name: String = "") {
        searchNameDebounce?.invalidate()
        searchNameDebounce = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let weakSelf = self else {return}
                weakSelf.searchName = name
                weakSelf.currentPage = 1
                weakSelf.fetchTaggingList(name)
            }
        })
    }
    
    private func fetchTaggingList(_ searchName: String) {
        let request = GetTaggingListRequest.builder()
            .searchName(searchName)
            .page(currentPage)
            .pageSize(20)
            .build()
        LMFeedClient.shared.getTaggingList(request) {[weak self] response in
            
            guard let members = response.data?.members else {
                self?.postErrorMessageNotification(error: response.errorMessage)
                self?.delegate?.didFailedToReceivedMemberListData()
                return
            }
//            self?.totalMembersCount = response.data?.totalMembers ?? 0
            self?.prepareMemberListData(members)
            self?.currentPage += members.count > 0 ? 1 : 0
        }
    }
    
    func prepareMemberListData(_ members: [User]) {
        let membersData = members.map { member in
            return MemberListDataView.MemberDataView(name: member.name?.capitalized ?? "",
                                                     profileImageURL: member.imageUrl ?? "",
                                                     company: member.organisationName ?? "",
                                                     designation: "",
                                                     uuid: member.sdkClientInfo?.uuid ?? "", customTitle: member.customTitle)
        }
        if self.currentPage > 1 {
            self.communityMembers.append(contentsOf: membersData)
        } else {
            self.communityMembers = membersData
        }
        delegate?.didReceivedMemberListData()
    }
    
}
