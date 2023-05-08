//
//  DeleteContentViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import UIKit

class DeleteContentViewController: UIViewController {
    
    @IBOutlet weak var btnLeft: LMButton!
    @IBOutlet weak var btnRight: LMButton!
    @IBOutlet weak var lblPopupTitle: LMLabel!
    
    @IBOutlet weak var lblMessage: LMLabel!
    @IBOutlet weak var textField: LMTextField!
    @IBOutlet weak var btnDropDown: LMButton!
    @IBOutlet weak var reasonPickerView: UIPickerView!
    
    @IBOutlet weak var pickerviewHeightConstraints: NSLayoutConstraint!
    
    let viewModel = DeleteContentViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetups()
        viewModel.fetchReportTags(type: 0)
    }


    func initialSetups()  {
        self.reasonPickerView.dataSource = self
        self.reasonPickerView.delegate = self
        self.pickerviewHeightConstraints.constant = 0
        self.textField.superview?.superview?.layer.cornerRadius = 10
        self.textField.superview?.superview?.layer.borderWidth = 1
        self.textField.superview?.superview?.layer.borderColor = UIColor.gray.cgColor
        self.setTitleAndMessage()
        self.btnLeft.setTitleColor(LMBranding.shared.buttonColor, for: .normal)
        self.btnRight.setTitleColor(LMBranding.shared.buttonColor, for: .normal)
        self.btnLeft.addTarget(self, action: #selector(leftButtonClicked(sender:)), for: .touchUpInside)
        self.btnRight.addTarget(self, action: #selector(rightButtonClicked(sender:)), for: .touchUpInside)
        self.btnDropDown.addTarget(self, action: #selector(dropDownButtonClicked(sender:)), for: .touchUpInside)
    }
    
    private func setTitleAndMessage()  {
        self.lblPopupTitle.text = ""
        self.lblMessage.text = ""
    }
    
    
    @objc func dropDownButtonClicked(sender: UIButton)  {
        if self.pickerviewHeightConstraints.constant == 0{
            UIView.animate(withDuration: 0.1,
                           delay: 0.1,
                           options: .transitionCurlDown,
                           animations: { () -> Void in
                self.pickerviewHeightConstraints.constant = 165
            }, completion: { (finished) -> Void in
            })
            
        }else{
            UIView.animate(withDuration: 0.1,
                           delay: 0.1,
                           options: .transitionCurlUp,
                           animations: { () -> Void in
                self.pickerviewHeightConstraints.constant = 0
            }, completion: { (finished) -> Void in
            })
        }
    }
    
    @objc func leftButtonClicked(sender: UIButton)  {
        self.dismissViewController()
    }
    
    @objc func rightButtonClicked(sender: UIButton)  {
       
    }
    
    @objc func dismissViewController()  {
        self.dismiss(animated: true, completion: nil)
    }

}

extension DeleteContentViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.reasons?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: LMLabel? = (view as? LMLabel)
        if pickerLabel == nil {
            pickerLabel = LMLabel()
            pickerLabel?.font = LMBranding.shared.font(20, .regular)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = viewModel.reasons?[row].name
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedReason = viewModel.reasons?[row]
        self.textField.text = viewModel.selectedReason?.name
        // self.btnRight.setTitleColor(.turquoise(), for: .normal)
        // self.btnRight.isEnabled = true
    }
    
}
