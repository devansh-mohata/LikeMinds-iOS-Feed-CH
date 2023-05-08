//
//  ReportContentViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 13/04/23.
//

import UIKit

class ReportContentViewController: BaseViewController {
    
    @IBOutlet weak var reportCollectionView: UICollectionView!
    @IBOutlet weak var otherTextView: LMTextView!
    @IBOutlet weak var otherTextViewBottomLine: UIView!
    @IBOutlet weak var reportButton: LMButton!
    var placeholderLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = "Write Description"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var viewModel: ReportContentViewModel!
    @IBOutlet weak var collectionViewHeightContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ReportContentViewModel()
        setupViews()
        viewModel.fetchReportTags()
    }
    
    func setupViews() {
        reportCollectionView.register(ReportTagCollectionViewCell.self, forCellWithReuseIdentifier: ReportTagCollectionViewCell.reuseIdentifier)
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
        let layout = TagFlowLayout()
        layout.estimatedItemSize = CGSize(width: 140, height: 40)
        reportCollectionView.collectionViewLayout = layout
        viewModel.delegate = self
        reportButton.backgroundColor = LMBranding.shared.buttonColor
        otherTextView.superview?.isHidden = true
        otherTextViewBottomLine.backgroundColor = LMBranding.shared.buttonColor
        otherTextView.delegate = self
        otherTextView.addSubview(placeholderLabel)
        placeholderLabel.centerYAnchor.constraint(equalTo: otherTextView.centerYAnchor).isActive = true
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !otherTextView.text.isEmpty
    }
    
    func showTextView(_ tag: String) {
        self.otherTextView.superview?.isHidden = !(tag.lowercased() == "others")
    }
}

extension ReportContentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reportTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportTagCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? ReportTagCollectionViewCell else {
            return ReportTagCollectionViewCell()
        }
        cell.tagLabel.text = viewModel.reportTags[indexPath.row]
        cell.tagLabel.preferredMaxLayoutWidth = collectionView.frame.width - 16
        if viewModel.selected.contains(viewModel.reportTags[indexPath.row]) {
            cell.highLightCell()
        } else {
            cell.unhighLightCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ReportTagCollectionViewCell, let text = cell.tagLabel.text else {return}
        viewModel.selected.removeAll()
        viewModel.selected.append(text)
        showTextView(text)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 200, height: 30)
    }
}

extension ReportContentViewController: ReportContentViewModelDelegate {
    func reloadReportTags() {
        self.reportCollectionView.reloadData()
        let height = self.reportCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.collectionViewHeightContraint.constant = height
        self.view.layoutIfNeeded()
    }
}

extension ReportContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
}
