//
//  MemberListViewController.swift
//  FeedSX
//
//  Created by Pushpendra Singh on 02/09/23.
//

import UIKit

protocol MemberListViewControllerDelegate: AnyObject {
    func didSelectMember(member: MemberListDataView.MemberDataView)
}

class MemberListViewController: BaseViewController {
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalMemberCountLabel: LMLabel!
    @IBOutlet weak var memberListTableView: UITableView!
    var searchBar = UISearchController()
    
    let viewModel: MemberListViewModel = MemberListViewModel()
    weak var delegate: MemberListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewBottomConstraint = self.tableViewBottomConstraint
        self.navigationItem.searchController = searchBar
        searchBar.searchResultsUpdater = self
        viewModel.delegate = self
        viewModel.fetchAllMembers()
        self.setTitleAndSubtile(title: "Select Author", subTitle: nil)
        memberListTableView.dataSource = self
        memberListTableView.delegate = self
        memberListTableView.register(UINib(nibName: MemberCell.nibName, bundle: Bundle(for: MemberCell.self)), forCellReuseIdentifier: MemberCell.nibName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MemberListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.communityMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.nibName) as? MemberCell else {
            return UITableViewCell()
        }
        let item = viewModel.communityMembers[indexPath.row]
        cell.configCellData(data: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.communityMembers[indexPath.row]
        self.delegate?.didSelectMember(member: item)
        self.navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard (scrollView.contentSize.height == (scrollView.frame.size.height + position)) else {return}
        self.viewModel.fetchAllMembers(isNextFetch: true)
    }
    
}

extension MemberListViewController: MemberListViewModelDelegate {
    func didFailedToReceivedMemberListData() {
    }
    
    func didReceivedMemberListData() {
        memberListTableView.reloadData()
    }

}

extension MemberListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
//        print(searchController.isActive)
        guard let text = searchController.searchBar.text?.trimmedText() else { return }
        self.viewModel.searchMember(withName: text)
    }
}
