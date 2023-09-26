//
//  EditPostViewController.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 04/06/23.
//


import UIKit
import BSImagePicker
import PDFKit
import LikeMindsFeed
import Photos

class EditPostViewController: BaseViewController {
    
    @IBOutlet weak var articalBannerImage: UIImageView!
    @IBOutlet weak var deleteArticleBannerButton: LMButton!
    @IBOutlet weak var articalBannerViewContainer: UIView!
    @IBOutlet weak var uploadArticleBannerButton: LMButton!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: LMLabel!
    @IBOutlet weak var addMoreButton: LMButton!
    @IBOutlet weak var changeAuthorButton: LMButton!
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
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentCollectionView: UICollectionView! {
        didSet {
            attachmentCollectionView.dataSource = self
            attachmentCollectionView.delegate = self
            attachmentCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.cellIdentifier)
            attachmentCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
            attachmentCollectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
            attachmentCollectionView.register(UINib(nibName: LinkCollectionViewCell.nibName, bundle: Bundle(for: LinkCollectionViewCell.self)), forCellWithReuseIdentifier: LinkCollectionViewCell.cellIdentifier)
            attachmentCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
            attachmentCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "defaultCell")
        }
    }
    @IBOutlet weak var uploadAttachmentActionsView: UIView!
    @IBOutlet weak var uploadActionsTableView: UITableView!
    @IBOutlet weak var collectionSuperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadAttachmentSuperViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var captionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadActionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taggingListViewContainer: UIView!
    @IBOutlet weak var taggingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taggingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topicFeedView: LMTopicView!
    
    var debounceForDecodeLink:Timer?
    private var uploadActionsHeight:CGFloat = 0
    private var addTitlePlaceholderLabel: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .bold)
        label.textColor = ColorConstant.textBlackColor
        label.text = " Add title *"
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
    
    private let viewModel: EditPostViewModel = EditPostViewModel()
    private let taggingUserList: TaggedUserList =  {
        guard let userList = TaggedUserList.nibView() else { return TaggedUserList() }
        return userList
    }()
    var postId: String = ""
    private var isTaggingViewHidden = true
    private var isReloadTaggingListView = true
    private var typeTextRangeInTextView: NSRange?
    private var postButtonItem: UIBarButtonItem?
    var resourceType: EditPostViewModel.AttachmentUploadType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
        NotificationCenter.default.addObserver(self, selector: #selector(errorMessage), name: .errorInApi, object: nil)
        self.userProfileImage.makeCircleView()
        setupTitleAndDescriptionTextView()
        viewModel.delegate = self
        viewModel.postId = postId
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.delegate = self
        addMoreButton.layer.borderWidth = 1
        addMoreButton.layer.borderColor = LMBranding.shared.buttonColor.cgColor
        addMoreButton.tintColor = LMBranding.shared.buttonColor
        addMoreButton.layer.cornerRadius = 8
//        addMoreButton.addTarget(self, action: #selector(addMoreAction), for: .touchUpInside)
        addMoreButton.superview?.isHidden = true
        self.attachmentCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.cellIdentifier)
        self.attachmentCollectionView.register(DocumentCollectionCell.self, forCellWithReuseIdentifier: DocumentCollectionCell.cellIdentifier)
        
        topicFeedView.delegate = self
        
        self.setupProfileData()
        self.setTitleAndSubtile(title: self.resourceType?.rawValue ?? "", subTitle: nil)
        self.hideTaggingViewContainer()
        self.pageControl?.currentPageIndicatorTintColor = LMBranding.shared.buttonColor
        changeAuthorButton.addTarget(self, action: #selector(changeAuthor), for: .touchUpInside)
        self.viewModel.getPost()
        self.setupResourceType()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTaggingView()
    }
    
    func setupResourceType() {
        self.setTitleAndSubtile(title: self.resourceType?.rawValue ?? "", subTitle: nil)
        switch self.resourceType {
        case .article:
            self.articalBannerViewContainer.isHidden = false
            self.attachmentView.isHidden = true
            self.articalBannerImage.contentMode = .scaleToFill
            self.deleteArticleBannerButton.isHidden = false
            self.placeholderLabel.text = "Write something here (min. 200 char)"
            self.uploadArticleBannerButton.addTarget(self, action: #selector(uploadArticleBanner), for: .touchUpInside)
            self.deleteArticleBannerButton.addTarget(self, action: #selector(deleteArticleBanner), for: .touchUpInside)
        default:
            self.articalBannerViewContainer.isHidden = true
            self.attachmentView.isHidden = false
        }
    }
    
    @objc func uploadArticleBanner() {
        openImagePicker(.image)
    }
    
    @objc func backButtonClicked() {
        if viewModel.imageAndVideoAttachments.first?.url == viewModel.postDetail?.imageVideos?.first?.url && viewModel.linkAttatchment?.url == viewModel.postDetail?.linkAttachment?.url && viewModel.documentAttachments.first?.attachmentUrl == viewModel.postDetail?.attachments?.first?.attachmentUrl && titleTextView.text == viewModel.postDetail?.header && captionTextView.text == viewModel.postDetail?.caption {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let bottomSheetViewController = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: Bundle(for: BottomSheetViewController.self))
        bottomSheetViewController.delegate  = self
        bottomSheetViewController.modalPresentationStyle = .overCurrentContext
        self.present(bottomSheetViewController, animated: false)
    }
    
    @objc func deleteArticleBanner() {
        let alert = UIAlertController(title: "Remove article banner?", message: "Are you sure you want to remove the article banner?", preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "Remove", style: .default) { [weak self] alert in
            self?.viewModel.imageAndVideoAttachments.removeAll()
            self?.articalBannerImage.image = nil
            self?.uploadArticleBannerButton.isHidden = false
            self?.deleteArticleBannerButton.isHidden = true
            self?.enablePostButton()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        alert.preferredAction = removeAction
        self.present(alert, animated: true)
    }
    
    func setupTaggingView() {
        self.taggingListViewContainer.addSubview(taggingUserList)
        taggingUserList.addConstraints(equalToView: self.taggingListViewContainer)
        taggingUserList.setUp()
        taggingUserList.delegate = self
        self.taggingListViewContainer.layer.borderWidth = 1
        self.taggingListViewContainer.layer.borderColor = ColorConstant.disableButtonColor.cgColor
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
        addTitlePlaceholderLabel.attributedText = Self.checkRequiredField(textColor: ColorConstant.textBlackColor, title: " Add title")
        addTitlePlaceholderLabel.isHidden = !titleTextView.text.isEmpty
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
    
    func setupNavigationItems() {
        postButtonItem = UIBarButtonItem(title: "Save",
                                         style: .done,
                                         target: self,
                                         action: #selector(editPost))
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
    
    func setupProfileData() {
        guard let user = LocalPrefrerences.getUserData() else {
            return
        }
        let placeholder = UIImage.generateLetterImage(with: user.name)
        self.userProfileImage.setImage(withUrl: user.imageUrl ?? "", placeholder: placeholder)
        self.usernameLabel.text = user.name?.capitalized
    }
    
    @objc func changeAuthor() {
        let memberListVC = MemberListViewController(nibName: "MemberListViewController", bundle: Bundle(for: MemberListViewController.self))
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    @objc
    override func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.uploadAttachmentSuperViewBottomConstraint.constant = 5 + (frame.size.height - self.view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    override func keyboardWillHide(_ sender: Notification) {
        self.uploadAttachmentSuperViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    
    @objc func editPost() {
        self.view.endEditing(true)
        let text = self.captionTextView.trimmedText()
        let heading = self.titleTextView.trimmedText()
        
        let disabledTopics = viewModel.selectedTopics.filter { !$0.isEnabled }.map { $0.title }
        if !disabledTopics.isEmpty {
            var message = "The Following Topics are disabled - \(disabledTopics.joined(separator: ", "))"
            showErrorAlert(message: message)
            return
        }
        
        switch self.resourceType {
        case .article:
            if text.count < 200 {
                self.showErrorAlert(message: MessageConstant.articalMinimumBodyCharError)
                return
            }
        default:
            break
        }
        self.viewModel.editPost(text, heading: heading, postType: self.resourceType ?? .image)
        self.navigationController?.popViewController(animated: true)
    }
    
    func openImagePicker(_ mediaType: Settings.Fetch.Assets.MediaTypes, forAddMore: Bool = false) {
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1//(10 - self.viewModel.imageAndVideoAttachments.count)
        imagePicker.settings.theme.selectionStyle = .checked
        imagePicker.settings.fetch.assets.supportedMediaTypes = forAddMore ? [.image, .video] : [mediaType]
        imagePicker.doneButton.isEnabled = false
        imagePicker.settings.selection.unselectOnReachingMax = true
        let start = Date()
        self.presentImagePicker(imagePicker, select: {[weak self] (asset) in
            print("Selected: \(asset)")
            asset.getURL { responseURL in
                guard let url = responseURL else {return }
                
                if self?.resourceType == .article, let selectedImage = UIImage(contentsOfFile: url.path) {
                    let cropper = CropperViewController(originalImage: selectedImage)
                    cropper.currentAspectRatioValue = 16/9
                    cropper.delegate = self
                    imagePicker.dismiss(animated: true) {
                        self?.present(cropper, animated: true, completion: nil)
                    }
                } else  {
                    let mediaType: EditPostViewModel.AttachmentUploadType = asset.mediaType == .image ? .image : .video
                    self?.viewModel.addImageVideoAttachment(fileUrl: url, type: mediaType)
                    self?.reloadCollectionView()
                    imagePicker.dismiss(animated: true)
                }
            }
        }, deselect: {[weak self] (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: {[weak self] (assets) in
            print("Finished with selections: \(assets)")
            
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
    
    @objc func addMoreAction() {
        switch self.resourceType {
        case .image:
            openImagePicker(.image, forAddMore: true)
        case .video:
            openImagePicker(.video, forAddMore: true)
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
 
}

extension EditPostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
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
                cell.removeButton.alpha = 0
                defaultCell = cell
            }
        case .video, .image:
            let item = self.viewModel.imageAndVideoAttachments[indexPath.row]
            if  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
                cell.setupDocumentCell(item.attachmentName(), documentDetails: item.attachmentDetails(), imageUrl: item.url)
                cell.delegate = self
                cell.removeButton.alpha = 0
                defaultCell = cell
            }
            
        case .document:
            let item = self.viewModel.documentAttachments[indexPath.row]
            if  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCollectionCell.cellIdentifier, for: indexPath) as? DocumentCollectionCell {
                cell.setupDocumentCell(item.attachmentName(), documentDetails: item.attachmentDetails())
                cell.delegate = self
                cell.removeButton.alpha = 0
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
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x  / self.view.frame.width)
    }
}

extension EditPostViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension EditPostViewController: UITextViewDelegate {
    
    func currentActiveTextViewPlaceholder(_ textView: UITextView, isHiddenPlacehodler: Bool) {
        switch textView {
        case titleTextView:
            addTitlePlaceholderLabel.isHidden = isHiddenPlacehodler
        case captionTextView:
            placeholderLabel.isHidden = isHiddenPlacehodler
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

extension EditPostViewController: AttachmentCollectionViewCellDelegate {
    
    func removeAttachment(_ cell: UICollectionViewCell) {
        guard let indexPath = self.attachmentCollectionView.indexPath(for: cell) else { return }
        print(indexPath.row)
        switch self.viewModel.currentSelectedUploadeType {
        case .video, .image:
            self.viewModel.imageAndVideoAttachments.remove(at: indexPath.row)
            reloadAttachmentsView()
        case .document:
            self.viewModel.documentAttachments.remove(at: indexPath.row)
            reloadAttachmentsView()
        case .link:
            self.viewModel.linkAttatchment = nil
//            reloadAttachmentsView()
            reloadCollectionView()
        default:
            break
        }
        if self.viewModel.documentAttachments.count == 0 && self.viewModel.imageAndVideoAttachments.count == 0 && (self.viewModel.currentSelectedUploadeType != .dontAttachOgTag) {
            self.uploadActionViewHeightConstraint.constant = uploadActionsHeight
        }
    }
}

//MARK: - Ext. Delegate DocumentPicker
extension EditPostViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        print(url)
        self.viewModel.addDocumentAttachment(fileUrl: url)
        controller.dismiss(animated: true)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
}

//MARK: - Delegate view model

extension EditPostViewController: EditPostViewModelDelegate {
    func didReceivedPostDetails() {
        self.resourceType = viewModel.editResourceType()
        self.viewModel.currentSelectedUploadeType = self.resourceType ?? .unknown
        self.setupResourceType()
        self.reloadAttachmentsView()
        let data  = TaggedRouteParser.shared.getTaggedParsedAttributedStringForEditText(with: self.viewModel.postDetail?.caption ?? "", forTextView: true)
        captionTextView.attributedText = data.0
        viewModel.taggedUsers = data.1
        taggingUserList.initialTaggedUsers(taggedUsers: viewModel.taggedUsers)
        titleTextView.text = self.viewModel.postDetail?.header
        addTitlePlaceholderLabel.isHidden = !titleTextView.text.isEmpty
        placeholderLabel.isHidden = !captionTextView.text.isEmpty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.captionTextView.becomeFirstResponder()
        }
    }
    
    func reloadAttachmentsView() {
        var isCountGreaterThanZero = false
        switch viewModel.currentSelectedUploadeType {
        case .article:
            guard viewModel.imageAndVideoAttachments.count > 0 else { return }
            uploadArticleBannerButton.isHidden = true
            deleteArticleBannerButton.isHidden = false
            guard let url = viewModel.imageAndVideoAttachments.first?.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let uRL = URL(string: url) else { return }
            DispatchQueue.global().async { [weak self] in
                DispatchQueue.main.async {
                    if let image = self?.viewModel.imageAndVideoAttachments.first?.thumbnailImage {
                        self?.articalBannerImage.image = image
                    } else {
                        self?.articalBannerImage.kf.setImage(with: uRL)
                    }
                }
            }
            enablePostButton()
        case .image, .video:
            isCountGreaterThanZero = viewModel.imageAndVideoAttachments.count > 0
            self.uploadActionViewHeightConstraint.constant = isCountGreaterThanZero ? 0 : uploadActionsHeight
            let docHeight = CGFloat(viewModel.imageAndVideoAttachments.count * 90)
            self.collectionSuperViewHeightConstraint.constant = docHeight
            let imageCount = viewModel.imageAndVideoAttachments.count
            pageControl?.superview?.isHidden = true//imageCount < 2
            pageControl?.numberOfPages = imageCount
        case .document:
            isCountGreaterThanZero = viewModel.documentAttachments.count > 0
            self.uploadActionViewHeightConstraint.constant = isCountGreaterThanZero ? 0 : uploadActionsHeight
            let docHeight = CGFloat(viewModel.documentAttachments.count * 90)
            self.collectionSuperViewHeightConstraint.constant = docHeight //< 393 ? 393 : docHeight
            pageControl?.superview?.isHidden = true
        default:
            self.uploadActionViewHeightConstraint.constant = uploadActionsHeight
            self.collectionSuperViewHeightConstraint.constant = 110
            pageControl?.superview?.isHidden = true
            break
        }
        attachmentCollectionView.reloadData()
    }
    
    func reloadCollectionView() {
        reloadAttachmentsView()
    }
    
    func reloadActionTableView() {
        self.uploadActionsTableView.reloadData()
    }
    
    func hasReachedMaximumAttachment() -> Bool {
        (viewModel.imageAndVideoAttachments.count > 0 && viewModel.imageAndVideoAttachments.count == 10) || (viewModel.documentAttachments.count > 0 && viewModel.documentAttachments.count == 10)
    }
    
    func showHideTopicView(topics: [TopicViewCollectionCell.ViewModel]) {
        topicFeedView.configure(with: topics) 
    }
}

extension EditPostViewController: TaggedUserListDelegate {
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

extension EditPostViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage, let url = info[.imageURL] as? URL else {
            dismiss(animated: true, completion: nil)
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        let size = Int(selectedImage.sizeInKB()/1000)
        if size > ConstantValue.maxPDFUploadSizeInMB {
            picker.dismiss(animated: true, completion: nil)
            self.showErrorAlert(message: MessageConstant.maxPDFError)
            return
        }
        self.viewModel.addImageVideoAttachment(fileUrl: url, type: self.resourceType ?? .image)
        self.reloadCollectionView()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditPostViewController: CropImageViewControllerDelegate {
    func didReceivedCropedImage(image: UIImage, imageUrl: URL) {
        self.viewModel.addImageVideoAttachment(fileUrl: imageUrl, type: .image)
        self.reloadCollectionView()
    }
}

extension EditPostViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        if cropper.aspectRatioPicker.selectedAspectRatio == .ratio(width: 16, height: 9),
           let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            cropper.dismiss(animated: true, completion: nil)
            guard let imageData = image.jpegData(compressionQuality: 1) else {
                print("error saving cropped image")
                return
            }
            do {
                let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let imageURL = docDir.appendingPathComponent("tmp.jpeg")
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    try FileManager.default.removeItem(atPath: imageURL.path)
                }
                try imageData.write(to: imageURL)
                let newImage = UIImage(contentsOfFile: imageURL.path)
                guard let img = newImage else { return }
                self.viewModel.addImageVideoAttachment(fileUrl: imageURL, type: .image)
                self.reloadCollectionView()
            } catch let error  {
                print("error:  \(error.localizedDescription)")
            }
        } else {
            cropper.presentAlert(message: MessageConstant.aritcleCoverPhotoRatioError)
        }
    }
}

extension EditPostViewController: BottomSheetViewDelegate {
    
    func didClickedOnDeleteButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didClickedOnContinueButton() {}
}
// MARK: SelectTopicViewDelegate
extension EditPostViewController: SelectTopicViewDelegate {
    func updateSelection(with data: [TopicFeedDataModel]) {
        viewModel.updateSelectedTopics(with: data)
    }
}

// MARK: LMTopicViewDelegate
extension EditPostViewController: LMTopicViewDelegate {
    func didTapEditTopics() {
        let vc = SelectTopicViewController(selectedTopics: viewModel.selectedTopics, isShowAllTopics: false, delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }
}
