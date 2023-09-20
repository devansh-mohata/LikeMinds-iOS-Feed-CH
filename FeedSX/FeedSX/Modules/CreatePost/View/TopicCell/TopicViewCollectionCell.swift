//
//  TopicViewCollectionCell.swift
//  FeedSX
//
//  Created by Devansh Mohata on 20/09/23.
//

import UIKit

final class TopicViewCollectionCell: UICollectionViewCell {
    struct ViewModel {
        let image: String?
        let title: String?
        var isImageFirst: Bool = true
        var isEditCell: Bool = false
    }
    
    @IBOutlet private var topicStackView: UIStackView!
    
    static let identifier = "TopicViewCollectionCell"
    
    func configure(with data: ViewModel) {
        backgroundColor = LMBranding.shared.buttonColor.withAlphaComponent(0.1)
        layer.cornerRadius = 4
        
        topicStackView.removeAllArrangedSubviews()
        
        if let image = data.image,
           let uiimage = UIImage(systemName: image) {
            let imgView = UIImageView(image: uiimage)
            imgView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            imgView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            imgView.tintColor = LMBranding.shared.buttonColor
            
            let title = UILabel()
            title.text = data.title
            title.font = LMBranding.shared.font(14, .regular)
            title.textColor = LMBranding.shared.buttonColor
            
            if data.isImageFirst {
                topicStackView.addArrangedSubview(imgView)
                topicStackView.addArrangedSubview(title)
            } else {
                topicStackView.addArrangedSubview(title)
                topicStackView.addArrangedSubview(imgView)
            }
        } else if let titleText = data.title {
            let title = UILabel()
            title.text = titleText
            title.font = LMBranding.shared.font(14, .regular)
            title.textColor = LMBranding.shared.buttonColor
            
            topicStackView.addArrangedSubview(title)
        }
    }
}
