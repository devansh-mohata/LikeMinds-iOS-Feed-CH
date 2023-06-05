//
//  LMButton.swift
//  LikeMindsChat
//
//  Created by Pushpendra Singh on 04/10/22.
//


import UIKit

//@IBDesignable
class LMTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This will call `awakeFromNib` in your code
        initialSetup()
    }
    
    private func initialSetup() {
        self.font = font?.brandingFont()
    }

    func leftImage(_ image: UIImage?, imageWidth: CGFloat, padding: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: padding, y: 0, width: imageWidth, height: frame.height)
        imageView.contentMode = .center
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth + 2 * padding, height: frame.height))
        containerView.addSubview(imageView)
        leftView = containerView
        leftViewMode = .always
    }

    @IBInspectable var borderColor: UIColor? = UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor?.cgColor
            layer.borderWidth = 1
            attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: borderColor ?? UIColor.lightGray ])
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.masksToBounds = true
            self.layer.cornerRadius = self.cornerRadius
            
        }
    }

}
