//
//  BaseViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 27/03/23.
//

import UIKit
//import BSImagePicker
import Photos

public class BaseViewController: UIViewController {
    
    let titleAndSubtitleStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis  = .vertical
        sv.alignment = .center
        sv.distribution = .equalCentering
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false;
        return sv
    }()
    
    let titleLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(18, .medium)
        label.text = "No title"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subTitleLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(14, .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backImageView: UIImageView = {
        let menuImageSize = 40
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: menuImageSize, height: menuImageSize))
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: ImageIcon.pinIcon)
        imageView.tintColor = .darkGray
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .large)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButtonWithAction()
    }
    
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc
    func keyboardWillShow(_ sender: Notification) {
        guard let info = sender.userInfo,
              let frame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
//        self.bottomConstraint.constant = frame.size.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func keyboardWillHide(_ sender: Notification) {
//        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func setTitleAndSubtile(title: String, subTitle: String?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        guard self.navigationItem.titleView == nil else { return }
        self.titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        self.titleAndSubtitleStackView.addArrangedSubview(subTitleLabel)
        self.navigationItem.titleView = self.titleAndSubtitleStackView
    }
    
    func setBackButtonWithAction() {
        let backImage = UIImage(systemName: ImageIcon.backIcon)
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
    
}
