//
//  DeleteContentViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import Foundation
import LMFeed

protocol DeleteContentViewModelProtocol: AnyObject {

}

final class DeleteContentViewModel {
    
    var reasons:[ReportTag]?
    var selectedReason: ReportTag?
    
    weak var delegate: DeleteContentViewModelProtocol?
    
    func fetchReportTags(type: Int) {
        let request = GetReportTagRequest(type)
        LMFeedClient.shared.getReportTags(request) {[weak self] result in
            if result.success, let tags = result.data?.reportTags {
                self?.reasons = tags
                print(tags)
            } else {
                
            }
        }
    }
}
