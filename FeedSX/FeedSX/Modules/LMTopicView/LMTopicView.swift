//
//  LMTopicView.swift
//  FeedSX
//
//  Created by Devansh Mohata on 22/09/23.
//

import UIKit

protocol LMTopicViewDataProtocol { }

protocol LMTopicViewDelegate: AnyObject {
    func didTapRemoveCell(topicId: String)
    func didTapEditTopics()
}

extension LMTopicViewDelegate {
    func didTapRemoveCell(topicId: String) { }
    func didTapEditTopics() { }
}

final class LMTopicView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var topicCollectionView: DynamicCollectionView! {
        didSet {
            topicCollectionView.dataSource = self
            topicCollectionView.delegate = self
            topicCollectionView.contentInsetAdjustmentBehavior = .always
            topicCollectionView.register(UINib(nibName: TopicViewCollectionCell.identifier, bundle: Bundle(for: TopicViewCollectionCell.self)), forCellWithReuseIdentifier: TopicViewCollectionCell.identifier)
            topicCollectionView.register(UINib(nibName: HomeFeedTopicCell.identifier, bundle: Bundle(for: HomeFeedTopicCell.self)), forCellWithReuseIdentifier: HomeFeedTopicCell.identifier)
            topicCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
            topicCollectionView.collectionViewLayout = TagsLayout()
            topicCollectionView.isScrollEnabled = false
        }
    }
    
    private var topics: [LMTopicViewDataProtocol] = []
    
    weak var delegate: LMTopicViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        Bundle(for: LMTopicView.self).loadNibNamed("LMTopicView", owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configure(with topics: [LMTopicViewDataProtocol], setHeight: ((CGFloat) -> Void)?) {
        self.topics = topics
        topicCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            var height = self?.topicCollectionView.collectionViewLayout.collectionViewContentSize.height ?? .zero
            height = height != .zero ? (height + 2) : 2
            
            // Doing this to add Seprator View height of 2px incase there are no cells, if there are cells then collection height + 16(spacing) + 2(seprator view height)
            setHeight?(height)
            
        }
    }
}

extension LMTopicView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopicViewCollectionCell.identifier, for: indexPath) as? TopicViewCollectionCell,
           let data = topics[indexPath.row] as? TopicViewCollectionCell.ViewModel {
            cell.configure(with: data) { [weak self] in
                if data.isEditCell {
                    self?.delegate?.didTapEditTopics()
                }
            }
            return cell
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedTopicCell.identifier, for: indexPath) as? HomeFeedTopicCell,
                  let data = topics[indexPath.row] as? HomeFeedTopicCell.ViewModel {
            cell.configure(with: data) { [weak self] in
                self?.delegate?.didTapRemoveCell(topicId: data.topicID)
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let data = topics[indexPath.row] as? TopicViewCollectionCell.ViewModel {
            let size = data.title?.sizeOfString(with: LMBranding.shared.font(14, .regular)) ?? .zero
            var width = size.width

            if data.image == "pencil" {
                width = 24
            }

            return .init(width: width, height: 40)
        } else if let data = topics[indexPath.row] as? HomeFeedTopicCell.ViewModel {
            let size = data.topicName.sizeOfString(with: LMBranding.shared.font(14, .regular))
            var width = size.width
            // Image Width
            width += 20

            // Padding
            width += 16

            return .init(width: width, height: 40)
        }

        return .zero
    }
}


// MARK: DynamicCollectionView
class DynamicCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
