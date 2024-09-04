//
//  HomeFeedShimmerView.swift
//  ShimmerView
//
//  Created by Devansh Mohata on 11/09/23.
//

import UIKit

class HomeFeedShimmerView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet var shimmers: [ShimmerView]!
    @IBOutlet var actionsSectionView: UIView!
    
    let actionFooterSectionView: ActionsFooterView = {
        let actionsSection = ActionsFooterView()
        actionsSection.translatesAutoresizingMaskIntoConstraints = false
        actionsSection.likeImageView.isUserInteractionEnabled = false
        actionsSection.savedImageView.isUserInteractionEnabled = false
        actionsSection.shareImageView.isUserInteractionEnabled = false
        actionsSection.commentImageView.isUserInteractionEnabled = false
        actionsSection.alpha = 0.1
        return actionsSection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        Bundle.lmBundle?.loadNibNamed("HomeFeedShimmerView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.actionsSectionView.addSubview(actionFooterSectionView)
        actionFooterSectionView.addConstraints(equalToView: self.actionsSectionView)
    }
    
    func startAnimation() {
        shimmers.forEach {
            $0.startShimmerAnimation()
        }
    }
    
    func stopAnimation() {
        shimmers.forEach {
            $0.stopShimmeringAnimation()
        }
    }
}
