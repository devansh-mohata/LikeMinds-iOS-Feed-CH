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
    static let bundle = Bundle.lmBundle
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
        self.moreMenuButton.isHidden = true
        self.profileImageView.makeCircleView()
        self.docIconImageView.superview?.makeCircleView()
        self.docIconImageView.superview?.backgroundColor = LMBranding.shared.buttonColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupNotificationFeedCell(dataView: NotificationFeedDataView) {
        self.notificationDetailLabel.attributedText = dataView.activityText()
        self.contentView.backgroundColor =  (dataView.isRead) ? .white : ColorConstant.notificationFeedColor
        timeLabel.text = Date(milliseconds: Double(dataView.activity.updatedAt ?? 0)).timeAgoDisplay()
        setTypeOfPostActivity(dataView: dataView)
        let profilePlaceHolder = UIImage.generateLetterImage(with: dataView.user?.name ?? "") ?? UIImage()
        guard let url = dataView.user?.imageUrl?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            profileImageView.image = profilePlaceHolder
            return
        }
        profileImageView.kf.setImage(with: URL.url(string: url), placeholder: profilePlaceHolder)
    }
    
    func setTypeOfPostActivity(dataView: NotificationFeedDataView) {
        if let attachment = dataView.activity.activityEntityData?.attachments?.first {
            docIconImageView.superview?.isHidden = false
            var attachmentTypePlaceHolder = ""
            if (attachment.attachmentType == .image || attachment.attachmentType == .video) { attachmentTypePlaceHolder = ImageIcon.photoIcon }
            else if (attachment.attachmentType == .doc) { attachmentTypePlaceHolder = ImageIcon.docFillIcon }
//           else if (attachment.attachmentType == .video) { attachmentTypePlaceHolder = ImageIcon.video }
//           else if (attachment.attachmentType == .link) { attachmentTypePlaceHolder = ImageIcon.linkIcon }
            if !attachmentTypePlaceHolder.isEmpty {
                docIconImageView.image = UIImage(systemName: attachmentTypePlaceHolder)
            } else {
                docIconImageView.superview?.isHidden = true
            }
        } else {
            docIconImageView.superview?.isHidden = true
        }
    }
    
    @objc func didMenuButtonClicked() {
        print("Menu button clicked")
        self.delegate?.menuButtonClicked(self)
    }
    
}
