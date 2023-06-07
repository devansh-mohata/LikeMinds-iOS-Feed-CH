//
//  ReportContentViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 14/04/23.
//

import Foundation
import LikeMindsFeed

protocol ReportContentViewModelDelegate: AnyObject {
    func reloadReportTags()
    func didReceivedReportRespone(_ errorMessage: String?)
}

class ReportContentViewModel {
    
    weak var delegate: ReportContentViewModelDelegate?
    var reportTags: [ReportTag] = []
    var selected = [ReportTag]()
    var entityId: String?
    var entityCreatorId: String?
    var reportEntityType: ReportEntityType = .post
    func fetchReportTags() {
        let request = GetReportTagRequest(3)
        LMFeedClient.shared.getReportTags(request) { [weak self] response in
            if response.success == false {
                self?.delegate?.didReceivedReportRespone(response.errorMessage)
            }
            guard let tags = response.data?.reportTags else { return }
            self?.reportTags = tags
            self?.delegate?.reloadReportTags()
        }
    }
    
    func reportContent(reason: String) {
        let tagId = selected.first?.id ?? 0
        let request = ReportRequest(entityId ?? "")
            .entityType(reportEntityType)
            .entityCreatorId(entityCreatorId ?? "")
            .tagId(tagId)
            .reason(reason)
        print(request)
        LMFeedClient.shared.report(request) {[weak self] response in
            if response.success {
                let entityType = self?.reportEntityType == .post ? "post" : "comment"
                LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Comment.reported, eventProperties: ["\(entityType)_id": (self?.entityId ?? "") , "user_id": (self?.entityCreatorId ?? ""), "reason": reason])
                self?.delegate?.didReceivedReportRespone(nil)
            } else {
                self?.delegate?.didReceivedReportRespone(response.errorMessage)
            }
        }
    }
    
}
