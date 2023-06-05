//
//  ViewMoreRepliesCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 20/05/23.
//

import UIKit

class ViewMoreRepliesCell: UITableViewCell {
    
    static let reuseIdentifier: String = String(describing: ViewMoreRepliesCell.self)
    
    let viewMoreRepliesAndCountStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()

    let viewMoreRepliesLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .bold)
        label.text = "View more replies"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var spaceView: UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    var countLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(14, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() -> Void {
        contentView.addSubview(viewMoreRepliesAndCountStackView)
        viewMoreRepliesAndCountStackView.addArrangedSubview(viewMoreRepliesLabel)
        viewMoreRepliesAndCountStackView.addArrangedSubview(spaceView)
        viewMoreRepliesAndCountStackView.addArrangedSubview(countLabel)
        spaceView.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        let g = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            viewMoreRepliesAndCountStackView.topAnchor.constraint(equalTo: g.topAnchor),
            viewMoreRepliesAndCountStackView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 32),
            viewMoreRepliesAndCountStackView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            viewMoreRepliesAndCountStackView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
    }

    func setupDataView(comment: PostDetailDataModel.Comment) {
        countLabel.text = "\(comment.replies.count) of \(comment.commentCount)"
    }
}
