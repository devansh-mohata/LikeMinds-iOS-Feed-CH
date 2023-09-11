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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        Bundle(for: HomeFeedShimmerView.self).loadNibNamed("HomeFeedShimmerView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shimmers.forEach {
            $0.startShimmerAnimation()
        }
    }
    
    override func awakeFromNib() {
        shimmers.forEach {
            $0.backgroundColor = .red
            $0.startShimmerAnimation()
        }
    }
}
