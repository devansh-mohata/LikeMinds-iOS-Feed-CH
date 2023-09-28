//
//  SelectTopicTableViewCell.swift
//  FeedSX
//
//  Created by Devansh Mohata on 20/09/23.
//

import UIKit

final class SelectTopicTableViewCell: UITableViewCell {
    struct ViewModel {
        let isSelected: Bool
        let title: String
    }
    
    @IBOutlet private weak var topicLbl: UILabel! {
        didSet {
            topicLbl.font = LMBranding.shared.font(17, .regular)
        }
    }
    @IBOutlet private weak var checkmarkImgView: UIImageView! {
        didSet {
            checkmarkImgView.tintColor = LMBranding.shared.buttonColor
        }
    }
    
    func configure(with data: ViewModel) {
        topicLbl.text = data.title
        checkmarkImgView.isHidden = !data.isSelected
    }
}
