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
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let documentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: ImageIcon.docFillIcon)
        imageView.tintColor = .orange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setSizeConstraint(width: 40, height: 45)
        return imageView
    }()
    
    let documentNameAndDetailStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let documentNameLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .medium)
        label.textColor = ColorConstant.textBlackColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let documentDetailLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(11, .regular)
        label.textColor = ColorConstant.editedTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeButton: LMButton = {
        let button = LMButton()
        button.setImage(UIImage(systemName: ImageIcon.trashFill), for: .normal)
        button.tintColor = .darkGray
        button.setPreferredSymbolConfiguration(.init(pointSize: 20, weight: .light, scale: .medium), forImageIn: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setSizeConstraint(width: 40, height: 40)
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
        documentStackView.addConstraints(equalToView: documentContainerView, top: 10, bottom: -10, left: 0, right: 0)
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        bringSubviewToFront(self.removeButton)
    }

    func setupDocumentCell(_ documentName: String, documentDetails: String, imageUrl: String? = nil) {
        self.documentNameLabel.text = documentName
        self.documentDetailLabel.text = documentDetails
//        self.setupImageVideoView(imageUrl)
    }
    
    func setupImageVideoView(_ url: String?) {
        guard let url else { return }
        let imagePlaceholder = UIImage(named: "imageplaceholder", in: Bundle.lmBundle, with: nil)
        self.documentImageView.image = imagePlaceholder
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL.url(string: url) else { return }
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                self?.documentImageView.kf.setImage(with: uRL, placeholder: imagePlaceholder)
            }
        }
    }
    
    @objc func removeClicked() {
        delegate?.removeAttachment(self)
    }
    
}
