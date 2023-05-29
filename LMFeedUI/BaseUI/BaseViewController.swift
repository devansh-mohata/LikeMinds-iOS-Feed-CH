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
        label.text = ""
        label.textColor = ColorConstant.navigationTitleColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subTitleLabel: LMLabel = {
        let label = LMLabel()
        label.font = LMBranding.shared.font(12, .regular)
        label.textColor = ColorConstant.navigationTitleColor
        label.textAlignment = .center
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
        imageView.tintColor = LMBranding.shared.buttonColor
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .light, scale: .large)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackButtonWithAction()
        self.navigationBarColor()
//        self.initializeHideKeyboard()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
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
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    
    @objc
    func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] else {
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
    
    func navigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = LMBranding.shared.headerColor
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        let backItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backItem.tintColor = .white//LMBranding.shared.buttonColor
        self.navigationItem.backBarButtonItem = backItem
    }
    
}

public class KeyboardHandlingBaseVC: UIViewController {
    @IBOutlet weak var backgroundSV: UIScrollView!
    public override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        initializeHideKeyboard()
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
}

// MARK: Keyboard Dismissal Handling on Tap
private extension KeyboardHandlingBaseVC {
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
}

private extension KeyboardHandlingBaseVC {
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        if let scrollView = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}



