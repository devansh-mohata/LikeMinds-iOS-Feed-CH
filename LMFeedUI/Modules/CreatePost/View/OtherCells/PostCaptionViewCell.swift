//
//  PostCaptionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import UIKit

class PostCaptionViewCell: UITableViewCell {
    
    static let cellIdentifier = "PostCaptionViewCell"
    //    weak var delegate: AttachmentCollectionViewCellDelegate?
    
    var captionContainerView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        uiView.clipsToBounds = true
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    let captionTextView: LMTextView = {
        let textView = LMTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        textView.font = LMBranding.shared.font(16, .regular)
        textView.isScrollEnabled = false
        textView.text = "Test text view \n ne ala flaj  aij laf \n ladjf la"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let textViewPlaceHolder: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = "Write something here..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        self.contentView.addSubview(captionContainerView)
        captionContainerView.addSubview(captionTextView)
        captionTextView.addConstraints(equalToView: captionContainerView, top: 5, bottom: -5, left: 16, right: -10)
        captionContainerView.addConstraints(equalToView: self.contentView, top: 0, bottom: 0, left: 0, right: 0)
    }
    
}
