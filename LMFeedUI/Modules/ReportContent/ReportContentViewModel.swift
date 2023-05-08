//
//  ReportContentViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 14/04/23.
//

import Foundation
import LMFeed

protocol ReportContentViewModelDelegate: AnyObject {
    func reloadReportTags()
}

class ReportContentViewModel {
    
    weak var delegate: ReportContentViewModelDelegate?
    var reportTags: [String] = []
    var selected = [String]()
    
    func fetchReportTags() {
        let request = GetReportTagRequest(3)
        LMFeedClient.shared.getReportTags(request) { [weak self] response in
            guard let tags = response.data?.reportTags else { return }
            self?.reportTags = tags.compactMap({$0.name})
            self?.delegate?.reloadReportTags()
        }
    }
    
}
