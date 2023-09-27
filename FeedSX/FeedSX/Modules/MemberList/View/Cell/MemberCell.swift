//
//  MemberCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 02/09/23.
//

import UIKit

class MemberCell: UITableViewCell {
    
    static let nibName = "MemberCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: LMLabel!
    @IBOutlet weak var userDesignation: LMLabel!
    @IBOutlet weak var userTitle: LMLabel!
    @IBOutlet weak var titleView: UIStackView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width/2
        self.userDesignation.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCellData(data: MemberListDataView.MemberDataView) {
        let placeHolder = UIImage.generateLetterImage(with: data.name)
        profileImageView.kf.setImage(with: URL.url(string: data.profileImageURL), placeholder: placeHolder)
        self.usernameLabel.text = data.name.capitalized
        self.userTitle.text = data.customTitle
        self.titleView.isHidden = (data.customTitle == nil)
    }
    
}
