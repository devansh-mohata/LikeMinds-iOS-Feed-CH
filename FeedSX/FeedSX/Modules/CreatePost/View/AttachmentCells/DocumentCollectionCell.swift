//
//  DocumentCollectionCellCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class DocumentCollectionCell: UICollectionViewCell {
    
    static let cellIdentifier = "DocumentCollectionCell"
    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    var documentContainerView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        uiView.clipsToBounds = true
        uiView.layer.cornerRadius = 8
        uiView.layer.borderWidth = 1.0
        uiView.layer.borderColor = UIColor.lightGray.cgColor
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let documentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 15
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "pdf_icon", in: Bundle(for: DocumentCollectionCell.self), with: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: 40, height: 45)
        return imageView
    }()
    
    let documentNameAndDetailStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 2
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let documentNameLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .medium)
        label.textColor = ColorConstant.postCaptionColor
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let documentDetailLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .regular)
        label.textColor = ColorConstant.editedTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let removeButton: LMButton = {
        let button = LMButton()
        button.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        button.tintColor = .darkGray
        button.setPreferredSymbolConfiguration(.init(pointSize: 20, weight: .light, scale: .large), forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setSizeConstraint(width: 30, height: 30)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.addSubview(documentContainerView)
        documentContainerView.addConstraints(equalToView: self, top: 5, bottom: -5, left: 16, right: -16)
        documentStackView.addArrangedSubview(documentImageView)
        documentNameAndDetailStackView.addArrangedSubview(documentNameLabel)
        documentNameAndDetailStackView.addArrangedSubview(documentDetailLabel)
        documentStackView.addArrangedSubview(documentNameAndDetailStackView)
        documentStackView.addArrangedSubview(removeButton)
        documentContainerView.addSubview(documentStackView)
        documentStackView.addConstraints(equalToView: documentContainerView, top: 10, bottom: -10, left: 20, right: -10)
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        bringSubviewToFront(self.removeButton)
    }

    func setupDocumentCell(_ documentName: String, documentDetails: String) {
        self.documentNameLabel.text = documentName
        self.documentDetailLabel.text = documentDetails
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
    
}
