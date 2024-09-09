//
//  UITableView+Extension.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 16/07/23.
//

import Foundation
import UIKit

extension UITableView {
    
    func setEmptyMessage(_ message: String, emptyImage: UIImage = UIImage()) {
        let emptyView = EmptyTableViewPlaceholder(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyView.setupEmptyData(message: message, imageIcon: emptyImage)
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

class EmptyTableViewPlaceholder: UIView {
    
    let superStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.spacing = 10
        sv.alignment = .center
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: ImageIcon.emptyDataImage, in: Bundle.lmBundle, with: nil)
        imageView.tintColor = ColorConstant.likeTextColor
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let emptyTitleLabel1: UILabel = {
        let label = LMPaddedLabel()
        label.paddingTop = 10
        label.paddingBottom = 5
        label.textColor = ColorConstant.userNameTextColor
        label.font = LMBranding.shared.font(14, .bold)
        label.text = "No data found!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(superStackView)
        superStackView.addArrangedSubview(emptyImageView)
        superStackView.addArrangedSubview(emptyTitleLabel1)
        superStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
        superStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        emptyImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        emptyImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupEmptyData(message: String, imageIcon: UIImage) {
        self.emptyImageView.image = imageIcon
        self.emptyTitleLabel1.text = message
    }
}
