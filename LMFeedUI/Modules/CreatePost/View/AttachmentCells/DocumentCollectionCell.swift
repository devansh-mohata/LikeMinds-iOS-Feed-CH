//
//  DocumentCollectionCellCollectionViewCell.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit

class DocumentCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var documentContainerView: UIView!
    @IBOutlet weak var docImageView: UIImageView!
    @IBOutlet weak var documentNameLabel: LMLabel!
    @IBOutlet weak var documentDetailLabel: LMLabel!
    @IBOutlet weak var removeButton: LMButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
}
