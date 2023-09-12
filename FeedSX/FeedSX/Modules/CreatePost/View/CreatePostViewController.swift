//
//  CreatePostViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 04/04/23.
//

import UIKit
import BSImagePicker
import PDFKit
import LikeMindsFeed
import AVFoundation

class CreatePostViewController: BaseViewController, BottomSheetViewDelegate {
    
    @IBOutlet weak var articalBannerImage: UIImageView!
    @IBOutlet weak var deleteArticleBannerButton: LMButton!
    @IBOutlet weak var uploadArticleBannerButton: LMButton!
    @IBOutlet weak var articalBannerViewContainer: UIView!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: LMLabel!
    @IBOutlet weak var changeAuthorButton: LMButton!
    @IBOutlet weak var addMoreButton: LMButton!
    @IBOutlet weak var postinLabel: LMLabel!
    @IBOutlet weak var titleTextView: LMTextView! {
        didSet{
            titleTextView.textColor = ColorConstant.textBlackColor
        }
    }
    @IBOutlet weak var captionTextView: LMTextView! {
        didSet{
            captionTextView.textColor = ColorConstant.textBlackColor.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var addLinkTextView: LMTextView! {
        didSet{
            addLinkTextView.textColor = ColorConstant.textBlackColor
        }
    }
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var uploadAttachmentActionsView: UIView!
    @IBOutlet weak var uploadActionsTableView: UITableView!
    @IBOutlet weak var collectionSuperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadAttachmentSuperViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var captionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taggingListViewContainer: UIView!
    @IBOutlet weak var taggingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentActionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var taggingViewBottomConstraint: NSLayoutConstraint!
    private var debounceForDecodeLink:Timer?
    private var uploadActionsHeight:CGFloat = 43 * 3
    private var addTitlePlaceholderLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .bold)
        label.textColor = ColorConstant.textBlackColor
        label.attributedText = checkRequiredField(textColor: ColorConstant.textBlackColor, title: " Add title")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var placeholderLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = " Write something (optional)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var addLinkPlaceholderLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = " Share the link resource*"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    private let viewModel: CreatePostViewModel = CreatePostViewModel()
    private let taggingUserList: TaggedUserList =  {
        guard let userList = TaggedUserList.nibView() else { return TaggedUserList() }
        return userList
    }()
    private var isTaggingViewHidden = true
    private var isReloadTaggingListView = true
    private var typeTextRangeInTextView: NSRange?
    private var postButtonItem: UIBarButtonItem?
    var resourceType: CreatePostViewModel.AttachmentUploadType?
    var resourceURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        NotificationCenter.default.addObserver(self, selector: #selector(errorMessage), name: .errorInApi, object: nil)
        self.userProfileImage.makeCircleView()
        setupTitleAndDescriptionTextView()
        viewModel.delegate = self
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.delegate = self
        uploadActionsTableView.dataSource = self
        uploadActionsTableView.delegate = self
        uploadActionsTableView.layoutMargins = UIEdgeInsets.zero
        uploadActionsTableView.separatorInset = UIEdgeInsets.zero
        addMoreButton.addTarget(self, action: #selector(addMoreAction), for: .touchUpInside)
        addMoreButton.superview?.isHidden = true
        self.attachmentCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)

        let linkNib = UINib(nibName: LinkCollectionViewCell.nibName, bundle: Bundle(for: LinkCollectionViewCell.self))
        self.attachmentCollectionView.register(linkNib, forCellWithReuseIdentifier: LinkCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        self.attachmentCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        self.setupProfileData()
        self.setTitleAndSubtile(title: self.resourceType?.rawValue ?? "", subTitle: nil)
        self.hideTaggingViewContainer()
        self.pageControl?.currentPageIndicatorTintColor = LMBranding.shared.buttonColor
        changeAuthorButton.addTarget(self, action: #selector(changeAuthor), for: .touchUpInside)
        self.setupResourceType()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTaggingView()
    }
    
    func setupResourceType() {
        self.viewModel.currentSelectedUploadeType = self.resourceType ?? .unknown
        self.addLinkTextView.superview?.isHidden = true
        switch self.resourceType {
        case .article:
            self.articalBannerViewContainer.isHidden = false
            self.attachmentView.isHidden = true
            self.deleteArticleBannerButton.isHidden = true
            articalBannerImage.contentMode = .scaleToFill
            self.placeholderLabel.text = MessageConstant.articalMinimumBodyChars
            self.uploadArticleBannerButton.addTarget(self, action: #selector(uploadArticleBanner), for: .touchUpInside)
            self.deleteArticleBannerButton.addTarget(self, action: #selector(deleteArticleBanner), for: .touchUpInside)
        case .link:
            self.articalBannerViewContainer.isHidden = true
            self.attachmentView.isHidden = false
            guard let url = resourceURL?.absoluteString else { return }
            self.viewModel.parseMessageForLink(message: url)
        case .document:
            self.articalBannerViewContainer.isHidden = true
            self.attachmentView.isHidden = false
            self.addMoreButton.setImage(UIImage(systemName: ImageIcon.paperclip), for: .normal)
            self.addMoreButton.setAttributedTitle(Self.checkRequiredField(textColor: ColorConstant.likeTextColor, title: "Select PDF to share"), for: .normal)
            self.addMoreButton.tintColor = ColorConstant.textBlackColor
            guard let url = resourceURL else { return }
            self.viewModel.addDocumentAttachment(fileUrl: url)
        default:
            self.articalBannerViewContainer.isHidden = true
            self.attachmentView.isHidden = false
            self.addMoreButton.setImage(UIImage(systemName: ImageIcon.videoFill), for: .normal)
            self.addMoreButton.setAttributedTitle(Self.checkRequiredField(textColor: ColorConstant.likeTextColor, title: "Select Video to share"), for: .normal)
            self.addMoreButton.tintColor = ColorConstant.purpleColor
            guard let url = resourceURL else { return }
            self.viewModel.addImageVideoAttachment(fileUrl: url, type: resourceType ?? .image)
        }
        self.reloadCollectionView()
    }
    
    @objc
    override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.attachmentActionBottomConstraint.constant = 5 + (frame.size.height - self.view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    override func keyboardWillHide(_ sender: Notification) {
        self.attachmentActionBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func setupTaggingView() {
        self.taggingListViewContainer.addSubview(taggingUserList)
        taggingUserList.addConstraints(equalToView: self.taggingListViewContainer)
        taggingUserList.setUp()
        taggingUserList.delegate = self
        self.taggingListViewContainer.layer.borderWidth = 1
        self.taggingListViewContainer.layer.borderColor = ColorConstant.disableButtonColor.cgColor
//        taggingListViewContainer.addShadow()
        taggingListViewContainer.layer.cornerRadius = 8
    }
    
    func setupTitleAndDescriptionTextView() {
        captionTextView.delegate = self
        captionTextView.addSubview(placeholderLabel)
        placeholderLabel.topAnchor.constraint(equalTo: captionTextView.topAnchor, constant: 10).isActive = true
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !captionTextView.text.isEmpty
        
        titleTextView.delegate = self
        titleTextView.addSubview(addTitlePlaceholderLabel)
        addTitlePlaceholderLabel.centerYAnchor.constraint(equalTo: titleTextView.centerYAnchor).isActive = true
        addTitlePlaceholderLabel.isHidden = !titleTextView.text.isEmpty
        
        addLinkTextView.delegate = self
        addLinkTextView.addSubview(addLinkPlaceholderLabel)
        addLinkPlaceholderLabel.centerYAnchor.constraint(equalTo: addLinkTextView.centerYAnchor).isActive = true
        addLinkPlaceholderLabel.isHidden = !addLinkTextView.text.isEmpty
    }
    
    func setupNavigationItems() {
         postButtonItem = UIBarButtonItem(title: "Post",
                        style: .done,
                        target: self,
                        action: #selector(createPost))
        postButtonItem?.tintColor = LMBranding.shared.buttonColor
        self.navigationItem.rightBarButtonItem = postButtonItem
        postButtonItem?.isEnabled = false
        
        let backButton = UIBarButtonItem(image: UIImage(systemName:  ImageIcon.backIcon),
                                         style: .done,
                                         target: self,
                                         action: #selector(backButtonClicked))
        backButton.tintColor = LMBranding.shared.buttonColor
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonClicked() {
        if viewModel.imageAndVideoAttachments.count == 0 && viewModel.linkAttatchment == nil && viewModel.documentAttachments.count == 0 && titleTextView.text.isEmpty && captionTextView.text.isEmpty {
            self.navigationController?.popViewController(animated: true)
            return 
        }
        let bottomSheetViewController = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: Bundle(for: BottomSheetViewController.self))
        bottomSheetViewController.delegate  = self
        bottomSheetViewController.modalPresentationStyle = .overCurrentContext
        self.present(bottomSheetViewController, animated: false)
    }
    
    func didClickedOnDeleteButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didClickedOnContinueButton() {}
    
    func setupProfileData() {
        guard let user = LocalPrefrerences.getUserData() else {
            return
        }
        if LocalPrefrerences.getMemberStateData()?.state != MemberState.admin.rawValue {
            changeAuthorButton.isHidden = true
        }
        let placeholder = UIImage.generateLetterImage(with: user.name)
        self.userProfileImage.setImage(withUrl: user.imageUrl ?? "", placeholder: placeholder)
        self.usernameLabel.text = user.name
        self.viewModel.onBehalfOfUUID = user.clientUUID
    }
    
    @objc func changeAuthor() {
        let memberListVC = MemberListViewController(nibName: "MemberListViewController", bundle: Bundle(for: MemberListViewController.self))
        memberListVC.delegate = self
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    @objc func createPost() {
        self.view.endEditing(true)
        let text = self.captionTextView.trimmedText()
        let heading = self.titleTextView.trimmedText()
        switch self.resourceType {
        case .article:
            if text.count < 200 {
                self.showError(errorMessage: MessageConstant.articalMinimumBodyCharError)
                return
            }
        default:
            break
        }
        self.viewModel.createPost(text, heading: heading, postType: self.resourceType ?? .image)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func uploadArticleBanner() {
        /*
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.allowsEditing = true
            self.present(myPickerController, animated: true, completion: nil)
        }*/
        openImagePicker(.image)
    }
    
    @objc func deleteArticleBanner() {
        
        let alert = UIAlertController(title: "Remove article banner?", message: "Are you sure you want to remove the article banner?", preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "Remove", style: .default) { [weak self] alert in
            self?.viewModel.imageAndVideoAttachments.removeFirst()
            self?.articalBannerImage.image = nil
            self?.uploadArticleBannerButton.isHidden = false
            self?.deleteArticleBannerButton.isHidden = true
            self?.enablePostButton()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func openImagePicker(_ mediaType: Settings.Fetch.Assets.MediaTypes, forAddMore: Bool = false) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1
        imagePicker.settings.theme.selectionStyle = .checked
        imagePicker.settings.fetch.assets.supportedMediaTypes = forAddMore ? [.image, .video] : [mediaType]
        imagePicker.settings.selection.unselectOnReachingMax = true
        imagePicker.doneButton.isEnabled = false
//        self.viewModel.currentSelectedUploadeType = mediaType == .image ? .image : .video
        let start = Date()
        self.presentImagePicker(imagePicker, select: {[weak self] (asset) in
            print("Selected: \(asset)")
            asset.getURL { responseURL in
                guard let url = responseURL else {return }
                let mediaType: CreatePostViewModel.AttachmentUploadType = asset.mediaType == .image ? .image : .video
                DispatchQueue.main.async {
                    if self?.resourceType == .article, let selectedImage = UIImage(contentsOfFile: url.path) {
                        let shittyVC = CropImageViewController(frame: (self?.view.frame) ?? .zero, image: selectedImage, aspectWidth: 16, aspectHeight: 9)
                        shittyVC.delegate = self
                        imagePicker.dismiss(animated: true)
                        self?.present(shittyVC, animated: true, completion: nil)
                    } else  {
                        if mediaType == .video {
                            let asset = AVAsset(url: url)
                            let duration = asset.duration
                            let durationTime = CMTimeGetSeconds(duration)
                            if durationTime > (10*60) {
                                self?.showErrorAlert(message: "Max video duration is 10 mins!")
                                return
                            }
                        }
                        self?.viewModel.addImageVideoAttachment(fileUrl: url, type: mediaType)
                        self?.reloadCollectionView()
                        imagePicker.dismiss(animated: true)
                    }
                }
            }
        }, deselect: {[weak self] (asset) in
            print("Deselected: \(asset)")
            asset.getURL { responseURL in
                self?.viewModel.imageAndVideoAttachments.removeAll(where: {$0.url == responseURL?.absoluteString})
            }
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
//            self?.viewModel.currentSelectedUploadeType =  (self?.viewModel.imageAndVideoAttachments.count ?? 0) > 0 ? .image : .unknown
            
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
//        self.viewModel.currentSelectedUploadeType = .document
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @objc func addMoreAction() {
        switch self.viewModel.currentSelectedUploadeType {
        case .image:
            openImagePicker(.image, forAddMore: true)
        case .video:
            openImagePicker(.video, forAddMore: false)
        case .document:
            openDocumentPicker()
        default:
            break
        }
    }
    
    func enablePostButton() {
        let imageVideoCount = self.viewModel.imageAndVideoAttachments.count != 0
        let documentCount = self.viewModel.documentAttachments.count != 0
        let headingText = !titleTextView.trimmedText().isEmpty
        let linkAttachment = self.viewModel.linkAttatchment != nil
        postButtonItem?.isEnabled = (imageVideoCount || documentCount || linkAttachment) && headingText
    }
    
    static func checkRequiredField(textColor: UIColor, title: String) -> NSAttributedString {
        let titleColor:UIColor = textColor
        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: titleColor ]
        let mutableString = NSMutableAttributedString(string: title, attributes: myAttribute1)
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
        let strick = NSMutableAttributedString(string: " *", attributes: myAttribute )
        mutableString.append(strick)
        return mutableString
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
            return  self.viewModel.linkAttatchment == nil ? 0 : 1
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
            if  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
                cell.setupDocumentCell(item.attachmentName(), documentDetails: item.attachmentDetails(), imageUrl: item.url)
                cell.delegate = self
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
        switch self.viewModel.currentSelectedUploadeType  {
        case .document, .image, .video:
            return CGSize(width: UIScreen.main.bounds.width, height: 70)
        case .link:
            return CGSize(width: UIScreen.main.bounds.width, height: 90)
        default:
            break
        }
        return CGSize(width: 1, height: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x  / self.view.frame.width)
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
            LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Post.clickedOnAttachment, eventProperties: ["type": "image"])
            openImagePicker(.image)
        case .video:
            LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Post.clickedOnAttachment, eventProperties: ["type": "video"])
            openImagePicker(.video)
        case .document:
            LMFeedAnalytics.shared.track(eventName: LMFeedAnalyticsEventName.Post.clickedOnAttachment, eventProperties: ["type": "file"])
            openDocumentPicker()
        default:
            break
        }
    }
}

extension CreatePostViewController: UITextViewDelegate {
    
    func currentActiveTextViewPlaceholder(_ textView: UITextView, isHiddenPlacehodler: Bool) {
        switch textView {
        case titleTextView:
            addTitlePlaceholderLabel.isHidden = isHiddenPlacehodler
        case captionTextView:
            placeholderLabel.isHidden = isHiddenPlacehodler
        case addLinkTextView:
            addLinkPlaceholderLabel.isHidden = isHiddenPlacehodler
        default:
            return
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentActiveTextViewPlaceholder(textView, isHiddenPlacehodler: true)
        enablePostButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.currentActiveTextViewPlaceholder(textView, isHiddenPlacehodler: !textView.text.isEmpty)
        enablePostButton()
        switch textView {
        case titleTextView:
            break
        case captionTextView:
            taggingUserList.textViewDidChange(textView)
        default:
            break
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        switch textView {
        case addLinkTextView:
            debounceForDecodeLink?.invalidate()
            debounceForDecodeLink = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {[weak self] _ in
                self?.viewModel.parseMessageForLink(message: textView.text)
            }
        case titleTextView:
            break
        case captionTextView:
            taggingUserList.textViewDidChangeSelection(textView)
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        currentActiveTextViewPlaceholder(textView, isHiddenPlacehodler: !textView.text.isEmpty)
        enablePostButton()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        currentActiveTextViewPlaceholder(textView, isHiddenPlacehodler: true)
        
        switch textView {
        case titleTextView:
            enablePostButton()
        case captionTextView:
            self.typeTextRangeInTextView = range
            if text != "" {
                typeTextRangeInTextView?.location += 1
            }
            let numLines = textView.text.sizeForWidth(width: textView.contentSize.width, font: textView.font ?? UIFont.systemFont(ofSize: 14)).height / (textView.font?.lineHeight ?? 0)
            self.taggingViewBottomConstraint.constant = CGFloat(-(20 * Int(numLines - 1)))
            taggingUserList.textView(textView, shouldChangeTextIn: range, replacementText: text)
            enablePostButton()
        default:
            break
        }
        return true
    }
}

extension CreatePostViewController: AttachmentCollectionViewCellDelegate {
    
    func removeAttachment(_ cell: UICollectionViewCell) {
        guard let indexPath = self.attachmentCollectionView.indexPath(for: cell) else { return }
        var title = "Remove attachment?"
        var message = "Are you sure you want to remove the attached video?"
        switch self.viewModel.currentSelectedUploadeType {
        case .video, .image, .document:
            title = "Remove attachment?"
            message = "Are you sure you want to remove the attached video?"
        case .link:
            title = "Remove link?"
            message = "Are you sure you want to remove the attached link?"
        default:
            break
        }
        
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionSubmit = UIAlertAction(title: "Remove", style: .default) { [weak self] (action) in
            self?.removeAttachmentConfirmationPopup(indexPath: indexPath)
            alertView.dismiss(animated: true, completion: nil)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertView.dismiss(animated: true)
        }
        alertView.addAction(actionSubmit)
        alertView.addAction(actionCancel)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func removeAttachmentConfirmationPopup(indexPath: IndexPath) {
        switch self.viewModel.currentSelectedUploadeType {
        case .video, .image:
            self.viewModel.imageAndVideoAttachments.remove(at: indexPath.row)
            reloadAttachmentsView()
        case .document:
            self.viewModel.documentAttachments.remove(at: indexPath.row)
            reloadAttachmentsView()
        case .link:
            self.viewModel.linkAttatchment = nil
            reloadAttachmentsView()
        default:
            break
        }
        if self.viewModel.documentAttachments.count == 0 && self.viewModel.imageAndVideoAttachments.count == 0 && (self.viewModel.currentSelectedUploadeType != .dontAttachOgTag) {
            //            self.viewModel.currentSelectedUploadeType = .unknown
            self.uploadActionViewHeightConstraint.constant = 0
        }
    }
}

//MARK: - Ext. Delegate DocumentPicker
extension CreatePostViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.relativePath), let size = attr[.size] as? Int, (size/1000000) > 8 {
            print(size)
            print((size/1000000))
            self.showErrorAlert(message: "Max size limit is 8 MB!")
            return
        }
        print(url)
        self.viewModel.addDocumentAttachment(fileUrl: url)
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
}

extension CreatePostViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage, let url = info[.imageURL] as? URL else {
            dismiss(animated: true, completion: nil)
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let size = Int(selectedImage.sizeInKB()/1000)
        if size > 8 {
            picker.dismiss(animated: true, completion: nil)
            self.showError(errorMessage:"Max. file size allowed is 8 MB" )
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
        let shittyVC = CropImageViewController(frame: (self.navigationController?.view.frame)!, image: selectedImage, aspectWidth: 16, aspectHeight: 9)
        shittyVC.delegate = self
        self.present(shittyVC, animated: true, completion: nil)
    }
}

extension CreatePostViewController: CropImageViewControllerDelegate {
    func didReceivedCropedImage(image: UIImage, imageUrl: URL) {
        self.viewModel.addImageVideoAttachment(fileUrl: imageUrl, type: .image)
        self.reloadCollectionView()
    }
}

//MARK: - Delegate view model

extension CreatePostViewController: CreatePostViewModelDelegate {
    
    func showError(errorMessage: String?) {
        self.showErrorAlert(message: errorMessage)
    }
    
    func reloadAttachmentsView() {
        var isCountGreaterThanZero = false
        switch viewModel.currentSelectedUploadeType {
        case .image, .video:
             let attachmentsCount = viewModel.imageAndVideoAttachments.count
             isCountGreaterThanZero = attachmentsCount > 0
            self.uploadActionViewHeightConstraint.constant = 0
            let heightForNumberOfItems = attachmentsCount > 0 ? attachmentsCount : 1
            let docHeight = CGFloat(heightForNumberOfItems * 90)
            self.collectionSuperViewHeightConstraint.constant = docHeight
            self.attachmentView.isHidden = !(attachmentsCount > 0)
            let imageCount = viewModel.imageAndVideoAttachments.count
            pageControl?.superview?.isHidden = true
            pageControl?.numberOfPages = imageCount
            addMoreButton.superview?.isHidden = isCountGreaterThanZero
        case .article:
            guard viewModel.imageAndVideoAttachments.count > 0 else { return }
            uploadArticleBannerButton.isHidden = true
            deleteArticleBannerButton.isHidden = false
            guard let url = viewModel.imageAndVideoAttachments.first?.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL(string: url) else { return }
            DispatchQueue.global().async { [weak self] in
                DispatchQueue.main.async {
                    if let img = self?.viewModel.imageAndVideoAttachments.first?.thumbnailImage {
                        self?.articalBannerImage.image = img
                    } else {
                        self?.articalBannerImage.kf.setImage(with: uRL)
                    }
                }
            }
        case .document:
            let attachmentsCount = viewModel.documentAttachments.count
            isCountGreaterThanZero = attachmentsCount > 0
            self.uploadActionViewHeightConstraint.constant = 0
            let heightForNumberOfItems = attachmentsCount > 0 ? attachmentsCount : 1
            let docHeight = CGFloat(heightForNumberOfItems * 90)
            self.attachmentView.isHidden = !(attachmentsCount > 0)
            self.collectionSuperViewHeightConstraint.constant = docHeight
            pageControl?.superview?.isHidden = true
            addMoreButton.superview?.isHidden = isCountGreaterThanZero
        case .link:
            self.uploadActionViewHeightConstraint.constant = 0
            self.collectionSuperViewHeightConstraint.constant = 110
            self.addMoreButton.superview?.isHidden = true
            pageControl?.superview?.isHidden = true
            self.addLinkTextView.superview?.isHidden = self.viewModel.linkAttatchment != nil
            self.attachmentView.isHidden = self.viewModel.linkAttatchment == nil
        default:
            self.uploadActionViewHeightConstraint.constant = 0
            self.collectionSuperViewHeightConstraint.constant = 110
            self.addMoreButton.superview?.isHidden = true
            pageControl?.superview?.isHidden = true
            break
        }
        enablePostButton()
        attachmentCollectionView.reloadData()
        if hasReachedMaximumAttachment() {
//            addMoreButton.superview?.isHidden = true
            self.uploadActionViewHeightConstraint.constant = 0
        }
    }
    
    func reloadCollectionView() {
        reloadAttachmentsView()
    }
    
    func reloadActionTableView() {
        self.uploadActionsTableView.reloadData()
    }
    
    func hasReachedMaximumAttachment() -> Bool {
        (viewModel.imageAndVideoAttachments.count > 0 && viewModel.imageAndVideoAttachments.count == 1) || (viewModel.documentAttachments.count > 0 && viewModel.documentAttachments.count == 1)
    }
}

extension CreatePostViewController: TaggedUserListDelegate {
    
    func didChangedTaggedList(taggedList: [TaggedUser]) {
        hideTaggingViewContainer()
        viewModel.taggedUsers = taggedList
    }

    func hideTaggingViewContainer() {
        isTaggingViewHidden = true
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .showHideTransitionViews, animations: {
            self.taggingListViewContainer.alpha = 0
            self.taggingViewHeightConstraint.constant = 48
            self.view.layoutIfNeeded()
        }) { finished in
        }
    }
    
    func unhideTaggingViewContainer(heightValue: CGFloat) {
        if !isReloadTaggingListView {return}
        isTaggingViewHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .transitionCurlUp, animations: {
            self.taggingListViewContainer.alpha = 1
            self.taggingViewHeightConstraint.constant = heightValue
            self.taggingUserList.frame = self.taggingListViewContainer.bounds
            self.view.layoutIfNeeded()
            
        }) { finished in
        }
    }
}

extension CreatePostViewController: MemberListViewControllerDelegate {
    
    func didSelectMember(member: MemberListDataView.MemberDataView) {
        self.viewModel.onBehalfOfUUID = member.uuid
        let placeholder = UIImage.generateLetterImage(with: member.name)
        self.userProfileImage.setImage(withUrl: member.profileImageURL, placeholder: placeholder)
        self.usernameLabel.text = member.name
    }
}
