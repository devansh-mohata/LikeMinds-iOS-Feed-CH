//
//  TaggedListTableViewCell.swift
//  CollabMates
//
//  Created by Shashank on 02/06/21.
//  Copyright © 2021 CollabMates. All rights reserved.
//

import UIKit
import LikeMindsFeed

class TaggedListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAbout: UILabel!
    @IBOutlet weak var viewSeperator: UIView!
    
    static let cellIdentifier = "TaggedListTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        viewSeperator.backgroundColor = ColorConstant.disableButtonColor
        viewContainer.layer.cornerRadius = 20
        viewContainer.layer.borderColor = UIColor.gray.cgColor
        viewContainer.layer.borderWidth = 0.2
        viewContainer.layer.masksToBounds = true
        imgView.layer.cornerRadius = 18
        imgView.layer.masksToBounds = true
    }
    func setMemberForTag(_ member: User) {
        labelName.text = member.name
//        labelAbout.text = member.about
        var placeholderImage = UIImage.generateLetterImage(name: member.name ?? "")
        if let url = URL(string: member.imageUrl ?? "") {
            imgView.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            imgView.image = placeholderImage
        }
    }

}
