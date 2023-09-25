//
//  SelectTopicViewModel.swift
//  FeedSX
//
//  Created by Devansh Mohata on 20/09/23.
//

import Foundation
import LikeMindsFeed

protocol SelectTopicViewModelToView: AnyObject {
    func updateTableView(with data: [SelectTopicTableViewCell.ViewModel], isSelectAllTopics: Bool)
    func updateSelection(with data: [TopicFeedDataModel])
}

final class SelectTopicViewModel {
    enum SelectionStyle {
        case single,
             multiple
    }
    
    private let selectionStyle: SelectionStyle
    private var pageNumber: Int
    private var selectedTopics: [TopicFeedDataModel]
    private var allowAPICall: Bool
    private var allTopics: [TopicFeedDataModel]
    var isShowAllTopics: Bool
    
    weak var delegate: SelectTopicViewModelToView?
    
    init(selectedTopics: [TopicFeedDataModel], selectionStyle: SelectionStyle, isShowAllTopics: Bool) {
        self.pageNumber = 1
        self.allowAPICall = true
        self.allTopics = []
        self.selectedTopics = selectedTopics
        self.selectionStyle = selectionStyle
        self.isShowAllTopics = isShowAllTopics
    }
    
    func fetchTopics(searchQuery: String?, isFreshSearch: Bool = false) {
        if isFreshSearch {
            pageNumber = 1
            allTopics = []
            allowAPICall = true
        }
        
        guard allowAPICall else { return }
        
        var request = TopicFeedRequest.builder()
            .setEnableState(true)
            .setPage(pageNumber)
        
        if let searchQuery,
           !searchQuery.isEmpty {
            request = request.setSearchTopic(searchQuery)
                .setSearchType("name")
        }
        
        LMFeedClient.shared.getTopicFeed(request) { [weak self] response in
            guard let self else { return }
            if response.success {
                self.pageNumber += 1
                self.allowAPICall = !(response.data?.topics?.isEmpty ?? true)
                let transformedTopics: [TopicFeedDataModel] = response.data?.topics?.compactMap {
                    guard let name = $0.name,
                          let id = $0.id else { return nil }
                    return .init(title: name, topicID: id, isEnabled: $0.isEnabled ?? false)
                } ?? []
                
                allTopics.append(contentsOf: transformedTopics)
                self.updateData()
            }
        }
    }
    
    private func updateData() {
        allTopics = allTopics.filter { topic in
            !selectedTopics.contains(where: { $0.topicID == topic.topicID })
        }
        
        allTopics.insert(contentsOf: selectedTopics, at: .zero)
        
        delegate?.updateTableView(with: transformToViewModel(), isSelectAllTopics: selectedTopics.isEmpty)
    }
    
    private func transformToViewModel() -> [SelectTopicTableViewCell.ViewModel] {
        allTopics.map { topic in
            let isSelected = selectedTopics.contains { topic.topicID == $0.topicID }
            return .init(isSelected: isSelected, title: topic.title)
        }
    }
        
    func didSelectRowAt(indexPath: IndexPath) {
        if let idx = selectedTopics.firstIndex(where: {
            $0.topicID == allTopics[indexPath.row].topicID
        }) {
            selectedTopics.remove(at: idx)
            delegate?.updateTableView(with: transformToViewModel(), isSelectAllTopics: selectedTopics.isEmpty)
            return
        }
        
        if selectionStyle == .single {
            selectedTopics.removeAll()
        }
        selectedTopics.append(allTopics[indexPath.row])
        delegate?.updateTableView(with: transformToViewModel(), isSelectAllTopics: selectedTopics.isEmpty)
    }
    
    func didSelectAllTopics() {
        selectedTopics.removeAll()
        delegate?.updateTableView(with: transformToViewModel(), isSelectAllTopics: selectedTopics.isEmpty)
    }
    
    func updateSelection() {
        delegate?.updateSelection(with: selectedTopics)
    }
}
