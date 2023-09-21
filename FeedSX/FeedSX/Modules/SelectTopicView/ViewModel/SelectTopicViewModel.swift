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
    func updateTitleView(with subtitle: String?)
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
                    return .init(title: name, topicID: id)
                } ?? []
                
                allTopics.append(contentsOf: transformedTopics)
                self.transformToViewModel()
            }
        }
    }
    
    private func transformToViewModel() {
        // Doing this in case if the user selects all the topics, i.e it means select all topics.
        if isShowAllTopics && selectedTopics.count == allTopics.count {
            selectedTopics.removeAll()
        }
        
        let transformedData: [SelectTopicTableViewCell.ViewModel] = allTopics.map { topic in
            let isSelected = selectedTopics.contains { topic.topicID == $0.topicID }
            return .init(isSelected: isSelected, title: topic.title)
        }
        updateTitleView()
        delegate?.updateTableView(with: transformedData, isSelectAllTopics: selectedTopics.isEmpty)
    }
    
    func updateTitleView() {
        let subtitle = selectedTopics.isEmpty ? nil : "\(selectedTopics.count) selected"
        delegate?.updateTitleView(with: subtitle)
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        if let idx = selectedTopics.firstIndex(where: {
            $0.topicID == allTopics[indexPath.row].topicID
        }) {
            selectedTopics.remove(at: idx)
            transformToViewModel()
            return
        }
        
        if selectionStyle == .single {
            selectedTopics.removeAll()
        }
        selectedTopics.append(allTopics[indexPath.row])
        transformToViewModel()
    }
    
    func didSelectAllTopics() {
        selectedTopics.removeAll()
        transformToViewModel()
    }
    
    func updateSelection() {
        delegate?.updateSelection(with: selectedTopics)
    }
}
