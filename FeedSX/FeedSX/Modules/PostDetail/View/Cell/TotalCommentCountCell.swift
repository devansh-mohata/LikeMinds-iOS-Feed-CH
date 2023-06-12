//
//  TotalCommentCountCell.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 12/06/23.
//

import Foundation
import UIKit

class TotalCommentCountCell: UITableViewCell {
    
    static let reuseIdentifier: String = String(describing: TotalCommentCountCell.self)
    
    let commentsCountStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let commentsCountLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(16, .medium)
        label.text = ""
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
        contentView.addSubview(commentsCountStackView)
        commentsCountStackView.addArrangedSubview(commentsCountLabel)
        let g = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            commentsCountStackView.topAnchor.constraint(equalTo: g.topAnchor, constant: 10),
            commentsCountStackView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            commentsCountStackView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            commentsCountStackView.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
    }
    
    func setupDataView(post: PostFeedDataView) {
        let commentPlural = post.commentCount > 1 ? "Comments" : (post.commentCount > 0 ? "Comment" : "")
        let counts = post.commentCount > 0 ? "\(post.commentCount) \(commentPlural)" : "\(commentPlural)"
        commentsCountLabel.text = counts
    }
}

