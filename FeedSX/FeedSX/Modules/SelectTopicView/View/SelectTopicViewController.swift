//
//  SelectTopicViewController.swift
//  FeedSX
//
//  Created by Devansh Mohata on 20/09/23.
//

import UIKit

protocol SelectTopicViewDelegate: AnyObject {
    func updateSelection(with data: [TopicFeedDataModel])
}

class SelectTopicViewController: BaseViewController {
    @IBOutlet private weak var allTopicsView: UIView! {
        didSet {
            allTopicsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAllTopicsView)))
        }
    }
    @IBOutlet private weak var allTopicsCheckmark: UIImageView! {
        didSet {
            allTopicsCheckmark.tintColor = LMBranding.shared.buttonColor
        }
    }
    @IBOutlet private weak var topicsTableView: UITableView! {
        didSet {
            topicsTableView.dataSource = self
            topicsTableView.delegate = self
            topicsTableView.bounces = false
            topicsTableView.register(UINib(nibName: "SelectTopicTableViewCell", bundle: Bundle(for: SelectTopicTableViewCell.self)), forCellReuseIdentifier: "SelectTopicTableViewCell")
            topicsTableView.showsVerticalScrollIndicator = false
            topicsTableView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet private weak var doneBtn: UIButton! {
        didSet {
            doneBtn.setTitle(nil, for: .normal)
            doneBtn.setTitle(nil, for: .selected)
            doneBtn.setImage(UIImage(systemName: "arrow.right"), for: .normal)
            doneBtn.setImage(UIImage(systemName: "arrow.right"), for: .selected)
            doneBtn.backgroundColor = LMBranding.shared.buttonColor
            doneBtn.tintColor = .white
            doneBtn.layer.cornerRadius = doneBtn.frame.size.height / 2
        }
    }
    
    private var debounceForText: Timer?
    private var topicCells: [SelectTopicTableViewCell.ViewModel] {
        didSet {
            topicsTableView.reloadData()
        }
    }
    private var viewModel: SelectTopicViewModel
    private var searchQuery: String?
    private weak var delegate: SelectTopicViewDelegate?
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.sizeToFit()
        bar.placeholder = "Search Topic"
        bar.showsCancelButton = true
        bar.delegate = self
        return bar
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(didTapSearchBar))
        btn.tintColor = LMBranding.shared.buttonColor
        return btn
    }()
    
    init(selectedTopics: [TopicFeedDataModel], selectionStyle: SelectTopicViewModel.SelectionStyle = .multiple, isShowAllTopics: Bool, delegate: SelectTopicViewDelegate?) {
        self.topicCells = []
        self.viewModel = .init(selectedTopics: selectedTopics, selectionStyle: selectionStyle, isShowAllTopics: isShowAllTopics)
        super.init(nibName: "SelectTopicViewController", bundle: Bundle(for: SelectTopicViewController.self))
        viewModel.delegate = self
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        self.topicCells = []
        self.viewModel = .init(selectedTopics: [], selectionStyle: .multiple, isShowAllTopics: false)
        super.init(coder: coder)
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTopicsView.isHidden = !viewModel.isShowAllTopics
        viewModel.fetchTopics(searchQuery: searchQuery, isFreshSearch: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Doing this to make navigation title left aligned
        let offset = UIOffset(horizontal: -CGFloat.greatestFiniteMagnitude, vertical: .zero)
        navigationController?.navigationBar.standardAppearance.titlePositionAdjustment = offset
        navigationController?.navigationBar.scrollEdgeAppearance?.titlePositionAdjustment = offset
        navigationController?.navigationBar.compactAppearance?.titlePositionAdjustment = offset
        
        navigationItem.setRightBarButton(rightBarButton, animated: false)
        
        setTitleAndSubtile(title: "Select Topic", subTitle: nil, alignment: .leading)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        debounceForText?.invalidate()
        
        // Doing this to make navigation title left aligned
        let offset = UIOffset(horizontal: .zero, vertical: .zero)
        navigationController?.navigationBar.standardAppearance.titlePositionAdjustment = offset
        navigationController?.navigationBar.scrollEdgeAppearance?.titlePositionAdjustment = offset
        navigationController?.navigationBar.compactAppearance?.titlePositionAdjustment = offset
        
        navigationItem.setRightBarButton(nil, animated: false)
    }
    
    @objc
    private func didTapAllTopicsView() {
        self.allTopicsCheckmark.isHidden.toggle()
        viewModel.didSelectAllTopics()
    }
    
    @objc
    private func didTapSearchBar() {
        allTopicsView.isHidden = true
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction private func doneBtnTapped(_ sender: UIButton) {
        viewModel.updateSelection()
    }
}


extension SelectTopicViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topicCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTopicTableViewCell") as? SelectTopicTableViewCell {
            cell.configure(with: topicCells[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == topicCells.count - 1 {
            viewModel.fetchTopics(searchQuery: searchQuery)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        allTopicsCheckmark.isHidden = true
        viewModel.didSelectRowAt(indexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension SelectTopicViewController: SelectTopicViewModelToView {
    func updateTableView(with data: [SelectTopicTableViewCell.ViewModel], isSelectAllTopics: Bool) {
        allTopicsCheckmark.isHidden = !isSelectAllTopics
        topicCells = data
    }
    
    func updateTitleView(with subtitle: String?) {
        setTitleAndSubtile(title: "Select Topic", subTitle: subtitle, alignment: .leading)
    }
    
    func updateSelection(with data: [TopicFeedDataModel]) {
        delegate?.updateSelection(with: data)
        navigationController?.popViewController(animated: true)
    }
}

extension SelectTopicViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.titleView = nil
        navigationItem.setRightBarButton(rightBarButton, animated: false)
        
        viewModel.updateTitleView()
        viewModel.fetchTopics(searchQuery: nil, isFreshSearch: true)
        
        allTopicsView.isHidden = !viewModel.isShowAllTopics
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceForText?.invalidate()
        searchQuery = searchText
        
        debounceForText = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            self?.viewModel.fetchTopics(searchQuery: searchText, isFreshSearch: true)
            timer.invalidate()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        debounceForText?.invalidate()
    }
}
