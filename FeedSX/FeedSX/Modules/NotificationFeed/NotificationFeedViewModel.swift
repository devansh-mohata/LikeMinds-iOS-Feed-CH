//
//  NotificationFeedViewModel.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 22/05/23.
//

import Foundation
import LikeMindsFeed

protocol NotificationFeedViewModelDelegate: AnyObject {
    func didReceiveNotificationFeedsResponse()
    func didReceiveMarkReadNotificationResponse()
}

class NotificationFeedViewModel: BaseViewModel {
    
    var currentPage: Int = 1
    weak var delegate: NotificationFeedViewModelDelegate?
    var activities: [NotificationFeedDataView] = []
    var isNotificationFeedLoading: Bool = false
    
    func pullToRefreshData() {
        self.currentPage = 1
        self.getNotificationFeed()
    }
    
    func getNotificationFeed() {
        let request = GetNotificationFeedRequest(page: currentPage)
        self.isNotificationFeedLoading = true
        LMFeedClient.shared.getNotificationFeed(request) {[weak self] response in
            if response.success {
                if let notificationActivities = response.data?.activities,
                   let users = response.data?.users,
                   notificationActivities.count > 0  {
                    if self?.currentPage == 1 {
                        self?.activities = notificationActivities.map({NotificationFeedDataView(activity: $0, user: users[$0.actionBy?.last ?? ""])})
                    } else {
                        self?.activities.append(contentsOf: notificationActivities.map({NotificationFeedDataView(activity: $0, user: users[$0.actionBy?.last ?? ""])}))
                    }
                    self?.currentPage += 1
                }
            } else {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
            self?.delegate?.didReceiveNotificationFeedsResponse()
            self?.isNotificationFeedLoading = false
        }
    }
    
    func markReadNotification(activityId: String?) {
        guard let activityId = activityId else {return}
        let request = MarkReadNotificationRequest(activityId: activityId)
        LMFeedClient.shared.markReadNotification(request) {[weak self] response in
            if response.success {
                self?.delegate?.didReceiveMarkReadNotificationResponse()
            } else {
                self?.postErrorMessageNotification(error: response.errorMessage)
            }
        }
    }
    
}
