//
//  ShimmerView.swift
//  ShimmerView
//
//  Created by Devansh Mohata on 08/09/23.
//

import UIKit

@IBDesignable
class ShimmerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
    }
    
    private lazy var shimmerAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1
        
        animation.repeatCount = .infinity
        return animation
    }()
    
    private lazy var shimmerGradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        gradientLayer.colors = [
            UIColor.init(red: 209 / 255.0, green: 209 / 255.0, blue: 214 / 255.0, alpha: 1).cgColor,
            UIColor.init(red: 209 / 255.0, green: 209 / 255.0, blue: 214 / 255.0, alpha: 1).cgColor,
            UIColor.init(red: 242 / 255.0, green: 242 / 255.0, blue: 247 / 255.0, alpha: 1).cgColor
        ]
        
        return gradientLayer
    }()
    
    func startShimmerAnimation() {
        if let _ = layer.sublayers?.first(where: { $0 == shimmerGradient }) { } else {
            layer.addSublayer(shimmerGradient)
        }
        shimmerGradient.add(shimmerAnimation, forKey: shimmerAnimation.keyPath)
    }
    
    func stopShimmeringAnimation() {
        guard let keyPath = shimmerAnimation.keyPath else { return }
        shimmerGradient.removeAnimation(forKey: keyPath)
        isHidden = true
    }
}
