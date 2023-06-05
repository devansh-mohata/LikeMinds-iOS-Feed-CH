//
//  ReportTagCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 14/04/23.
//

import Foundation

import UIKit

class ReportTagCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ReportTagCollectionViewCell"
    
    var tagLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = LMBranding.shared.buttonColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.contentView.addSubview(tagLabel)
        tagLabel.addConstraints(equalToView: self.contentView, top: 10, bottom: -10, left: 10, right: -10)
        self.layer.borderColor = LMBranding.shared.buttonColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
    }
    
    func highLightCell() {
        self.layer.borderColor = LMBranding.shared.buttonColor.cgColor
        tagLabel.textColor = LMBranding.shared.buttonColor
    }
    
    func unhighLightCell() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        tagLabel.textColor = .lightGray
    }
}
