//
//  ShareContentUtil.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 28/06/23.
//

import Foundation
import UIKit

class ShareContentUtil {
    
#if DEBUG
    static let domainUrl = "https://betaweb.likeminds.community"
#else
    static let domainUrl = "https://web.likeminds.community"
#endif
    
    static func sharePost(viewController: UIViewController, domainUrl: String = domainUrl, postId: String, description: String = "") {
        let shareUrl = "\(domainUrl)/post?post_id=\(postId)"
        Self.share(viewController: viewController, firstActivityItem: description, secondActivityItem: shareUrl)
    }
    
    private static func share(viewController: UIViewController, firstActivityItem description: String = "", secondActivityItem url: String, image: UIImage? = nil) {
        guard let url = URL(string: url) else { return }
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [description, url], applicationActivities: nil)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList
        ]
        
        activityViewController.isModalInPresentation = true
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
}
