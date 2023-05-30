//
//  NotificationFeedTableViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 22/05/23.
//

import UIKit

protocol NotificationFeedTableViewCellDelegate: AnyObject {
    func menuButtonClicked(_ cell: UITableViewCell)
}

class NotificationFeedTableViewCell: UITableViewCell {
    
    static let nibName: String = "NotificationFeedTableViewCell"
    static let bundle = Bundle(for: NotificationFeedTableViewCell.self)
    weak var delegate: NotificationFeedTableViewCellDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var docIconImageView: UIImageView!
    @IBOutlet weak var notificationDetailLabel: LMLabel!
    @IBOutlet weak var timeLabel: LMLabel!
    @IBOutlet weak var moreMenuButton: LMButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.moreMenuButton.addTarget(self, action: #selector(didMenuButtonClicked), for: .touchUpInside)
        self.profileImageView.makeCircleView()
        self.docIconImageView.superview?.makeCircleView()
        self.docIconImageView.superview?.backgroundColor = LMBranding.shared.buttonColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupNotificationFeedCell() {
        
    }
    
    @objc func didMenuButtonClicked() {
        print("Menu button clicked")
        self.delegate?.menuButtonClicked(self)
    }
    
}
