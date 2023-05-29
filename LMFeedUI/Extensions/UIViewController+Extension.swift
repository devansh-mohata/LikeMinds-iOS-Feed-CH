//
//  UIViewController+Extension.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 29/03/23.
//

import Foundation
import UIKit

extension UIViewController {
    
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "DiffBgColor")
    }
    
    var isTabBarVisible: Bool {
        return (self.tabBarController?.tabBar.frame.origin.y ?? 0) < self.view.frame.maxY
    }
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        // bail if the current state matches the desired state
        if (isTabBarVisible == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration: TimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    func setupBasicViews(title: String){
        self.title = title
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor(named: "diffBgColor")
    }
    
    func presentAlert(title: String? = "", message: String, handler: (() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { alert in
            handler?()
        }))
        self.present(alert, animated: true)
    }
    
    func share(firstActivityItem description: String = "", secondActivityItem url: String, image: UIImage? = nil) {
        let uRl = URL(string: url)
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [url, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
//        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
//
//        // This line remove the arrow of the popover to show in iPad
//        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
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
//            UIActivity.ActivityType.postToFlickr,
//            UIActivity.ActivityType.postToVimeo,
//            UIActivity.ActivityType.postToTencentWeibo,
//            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
}
