//
//  BottomSheetViewController.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 08/09/23.
//

import UIKit

protocol BottomSheetViewDelegate: AnyObject {
    func didClickedOnDeleteButton()
    func didClickedOnContinueButton()
}

class BottomSheetViewController: UIViewController {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    weak var delegate: BottomSheetViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomSheetView.clipsToBounds = true
        bottomSheetView.layer.cornerRadius = 10
        bottomSheetView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        firstTitleLabel.text = StringConstant.BottomSheet.firstTitle
        subtitleLabel.text = StringConstant.BottomSheet.subtitle
        continueButton.setTitle(StringConstant.BottomSheet.continueTitle, for: .normal)
        deleteButton.setTitle(StringConstant.BottomSheet.deleteTitle, for: .normal)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func deleteClicked(_ sender: Any) {
        delegate?.didClickedOnDeleteButton()
        self.dismiss(animated: false)
    }
    
    @objc
    @IBAction func continueClicked(_ sender: Any) {
        delegate?.didClickedOnContinueButton()
        self.dismiss(animated: false)
    }

    func animateBottomSheetView() {
        self.bottomSheetBottomConstraint.constant = -241
        UIView.animate(withDuration: 1) {
            self.bottomSheetBottomConstraint.constant = 0
        }
    }
}
