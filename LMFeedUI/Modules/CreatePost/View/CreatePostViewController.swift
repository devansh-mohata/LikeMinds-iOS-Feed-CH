//
//  CreatePostViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit
import BSImagePicker
import PDFKit

class CreatePostViewController: BaseViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: LMLabel!
    @IBOutlet weak var postinLabel: LMLabel!
    @IBOutlet weak var captionTextView: LMTextView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var uploadAttachmentActionsView: UIView!
    @IBOutlet weak var uploadActionsTableView: UITableView!
    @IBOutlet weak var collectionSuperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadAttachmentSuperViewBottomConstraint: NSLayoutConstraint!
    var debounceForDecodeLink:Timer?
    
    let viewModel: CreatePostViewModel = CreatePostViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        captionTextView.delegate = self
        attachmentView.isHidden = true
        viewModel.delegate = self
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.delegate = self
        uploadActionsTableView.dataSource = self
        uploadActionsTableView.delegate = self
        uploadActionsTableView.layoutMargins = UIEdgeInsets.zero
        uploadActionsTableView.separatorInset = UIEdgeInsets.zero
        
        let nib = UINib(nibName: ImageVideoCollectionViewCell.nibName, bundle: Bundle(for: ImageVideoCollectionViewCell.self))
        self.attachmentCollectionView.register(nib, forCellWithReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier)
        let videoNib = UINib(nibName: VideoCollectionViewCell.nibName, bundle: Bundle(for: VideoCollectionViewCell.self))
        self.attachmentCollectionView.register(videoNib, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        let docNib = UINib(nibName: DocumentCollectionCell.nibName, bundle: Bundle(for: DocumentCollectionCell.self))
        self.attachmentCollectionView.register(docNib, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
        let linkNib = UINib(nibName: LinkCollectionViewCell.nibName, bundle: Bundle(for: LinkCollectionViewCell.self))
        self.attachmentCollectionView.register(linkNib, forCellWithReuseIdentifier: LinkCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        self.attachmentCollectionView.register(VideoCollectionViewCell1.self, forCellWithReuseIdentifier: VideoCollectionViewCell1.cellIdentifier)
    }
    
    func setupNavigationItems() {
        let postButtonItem = UIBarButtonItem(title: "POST",
                        style: .plain,
                        target: self,
                        action: #selector(createPost))
        postButtonItem.tintColor = LMBranding.shared.buttonColor
        self.navigationItem.rightBarButtonItem = postButtonItem
    }
    
    @objc func createPost() {
        print("post data")
        self.view.endEditing(true)
    }
    
    func openImagePicker(_ mediaType: Settings.Fetch.Assets.MediaTypes) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [mediaType]
        imagePicker.settings.selection.unselectOnReachingMax = true
        self.viewModel.currentSelectedUploadeType = mediaType == .image ? .image : .video
        let start = Date()
        self.presentImagePicker(imagePicker, select: {[weak self] (asset) in
            print("Selected: \(asset)")
            asset.getURL { responseURL in
                guard let url = responseURL else {return }
                let mediaType: CreatePostViewModel.AttachmentUploadType = asset.mediaType == .image ? .image : .video
                print("selected: \(responseURL?.absoluteString)")
                self?.viewModel.addImageVideoAttachment(fileUrl: url, type: mediaType)
            }
        }, deselect: {[weak self] (asset) in
            print("Deselected: \(asset)")
            asset.getURL { responseURL in
                print("selected: \(responseURL?.absoluteString)")
                self?.viewModel.imageAndVideoAttachments.removeAll(where: {$0.url == responseURL?.absoluteString})
            }
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: {[weak self] (assets) in
            print("Finished with selections: \(assets)")
            self?.viewModel.currentSelectedUploadeType =  (self?.viewModel.imageAndVideoAttachments.count ?? 0) > 0 ? .image : .unknown
            self?.reloadCollectionView()
            
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
    }
    
    func openDocumentPicker() {
        let types: [String] = [
            "com.adobe.pdf"
        ]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.viewModel.currentSelectedUploadeType = .document
        self.present(documentPicker, animated: true, completion: nil)
    }
}

extension CreatePostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.viewModel.currentSelectedUploadeType {
        case .video, .image:
            return viewModel.imageAndVideoAttachments.count
        case .document:
            return viewModel.documentAttachments.count
        case .link:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
        switch self.viewModel.currentSelectedUploadeType {
        case .link:
            if let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.cellIdentifier, for: indexPath) as? LinkCollectionViewCell {
                let linkAttachment = self.viewModel.linkAttatchment
                cell.setupLinkCell(linkAttachment?.title, description: linkAttachment?.description, link: linkAttachment?.url, linkThumbnailUrl: linkAttachment?.linkThumbnailUrl)
                cell.delegate = self
                defaultCell = cell
            }
        case .video, .image:
            let item = self.viewModel.imageAndVideoAttachments[indexPath.row]
            if  item.fileType == .image,
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImageVideoCollectionViewCell.cellIdentifier, for: indexPath) as? ImageVideoCollectionViewCell {
                //            cell.postImageView.kf.setImage(with: URL(string: "https://beta-likeminds-media.s3.amazonaws.com/post/c6c4aa41-cdca-4c1d-863c-89c2ea3bc922/SamplePNGImage_20mbmb-1679906349694.png"))
                cell.setupImageVideoView(self.viewModel.imageAndVideoAttachments[indexPath.row].url)
                cell.delegate = self
                defaultCell = cell
            } else if item.fileType == .video,
                      let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell1.cellIdentifier, for: indexPath) as? VideoCollectionViewCell1,
                      let url = item.url {
                cell.setupVideoData(url: url)
                
                defaultCell = cell
            }
            
        case .document:
            let item = self.viewModel.documentAttachments[indexPath.row]
            if  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
                cell.setupDocumentCell(item.attachmentName(), documentDetails: item.attachmentDetails())
                cell.delegate = self
                defaultCell = cell
            }
        default:
            break
        }
        return defaultCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        pageControl?.currentPage = Int(scrollView.contentOffset.x  / self.frame.width)
        //        currentPageIndicatorImage(forPage: Int(scrollView.contentOffset.x  / self.frame.width))
    }
    
}

extension CreatePostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.attachmentUploadTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = viewModel.attachmentUploadTypes[indexPath.row].rawValue
        switch viewModel.attachmentUploadTypes[indexPath.row] {
        case .image:
            cell.imageView?.tintColor = .orange
            cell.imageView?.image = UIImage(systemName: "photo")
        case .video:
            cell.imageView?.tintColor = .blue
            cell.imageView?.image = UIImage(systemName: "video.fill")
        case .document:
            cell.imageView?.image = UIImage(systemName: "paperclip")
        default:
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.attachmentUploadTypes[indexPath.row] {
        case .image:
            openImagePicker(.image)
        case .video:
            openImagePicker(.video)
        case .document:
            openDocumentPicker()
        default:
            break
        }
    }
}

extension CreatePostViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if self.viewModel.currentSelectedUploadeType == .unknown || self.viewModel.currentSelectedUploadeType == .link {
            debounceForDecodeLink?.invalidate()
            debounceForDecodeLink = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {[weak self] _ in
                let enteredString = textView.text + text
                self?.viewModel.parseMessageForLink(message: enteredString)
            }
        }
//        attachmentView.isHidden = false
//        let contentSize = textView.contentSize
//        let textViewSize = textView.frame.size
//        if contentSize.height > textViewSize.height {
//            textView.isScrollEnabled = true
//        } else {
//            textView.isScrollEnabled = false
//        }
        return true
    }
    
}

extension CreatePostViewController: AttachmentCollectionViewCellDelegate {
    
    func removeAttachment(_ cell: UICollectionViewCell) {
        guard let indexPath = self.attachmentCollectionView.indexPath(for: cell) else { return }
        print(indexPath.row)
        switch self.viewModel.currentSelectedUploadeType {
        case .video, .image:
            self.viewModel.imageAndVideoAttachments.remove(at: indexPath.row)
            attachmentCollectionView.reloadData()
        case .document:
            self.viewModel.documentAttachments.remove(at: indexPath.row)
            attachmentCollectionView.reloadData()
        case .link:
            self.viewModel.linkAttatchment = nil
            self.viewModel.currentSelectedUploadeType = .unknown
            attachmentCollectionView.reloadData()
        default:
            break
        }
        if self.viewModel.documentAttachments.count == 0 && self.viewModel.imageAndVideoAttachments.count == 0 {
            self.viewModel.currentSelectedUploadeType = .unknown
        }
    }
}

//MARK: - Ext. Delegate DocumentPicker
extension CreatePostViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print(url)
        self.viewModel.addDocumentAttachment(fileUrl: url)
//        self.delegate?.didSelect(image: image)
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
}

//MARK: - Delegate view model

extension CreatePostViewController: CreatePostViewModelDelegate {
    
    func reloadCollectionView() {
        attachmentView.isHidden = false
        attachmentCollectionView.reloadData()
    }
    
    func reloadActionTableView() {
        self.uploadActionsTableView.reloadData()
    }
}
