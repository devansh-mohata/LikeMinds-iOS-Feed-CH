//
//  PostDetailViewController.swift
//  LMFeedUI
//
//  Created by Pushpendra Singh on 09/04/23.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    @IBOutlet weak var postDetailTableView: UITableView!
    @IBOutlet weak var commentTextView: LMTextView!
    @IBOutlet weak var sendButton: LMButton!
    
    let textViewPlaceHolder: LMLabel = {
        let label = LMLabel()
        label.numberOfLines = 1
        label.font = LMBranding.shared.font(16, .regular)
        label.textColor = .lightGray
        label.text = "Write a comment"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var myHeaderData: [String] = [ "",
        "Section 0aj dflaj dlj lajlf aljd flja dfl",
        "Section 1 ajdlfaj lfj aljsd flja sdljf ajd lasdjf lasdfj ladjf lasjd flasjdf lasjd flaj sdlfj asldf jlajdf laj flajsdflj aldjf lajd flj aljdf lkajdf lajfijw flksjalh ialjf lkajsf ilja lskfjlajs flajflaj ifjlk laljfld jaljdflaif ljaf alifjlajdf lkadf lasjflak jsdflkasjf ilasj flkasdjf ilasj flkajsf aldjf lkajf lajf ilaj flaj filajflia fladjf lkajdflak dflaijdflaf lasdfjiaj fla",
        "Section 2 aldjf lasjd fl alsdfj la dsf aljdlfj alfdj lajd flnew",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postDetailTableView.rowHeight = 50
        postDetailTableView.keyboardDismissMode = .onDrag
        
        postDetailTableView.sectionHeaderHeight = UITableView.automaticDimension
        postDetailTableView.estimatedSectionHeaderHeight = 75
        
        postDetailTableView.register(ReplyCommentTableViewCell.self, forCellReuseIdentifier: ReplyCommentTableViewCell.reuseIdentifier)
        postDetailTableView.register(CommentHeaderViewCell.self, forHeaderFooterViewReuseIdentifier: CommentHeaderViewCell.reuseIdentifier)
        postDetailTableView.register(UINib(nibName: HomeFeedImageVideoTableViewCell.nibName, bundle: HomeFeedImageVideoTableViewCell.bundle), forCellReuseIdentifier: HomeFeedImageVideoTableViewCell.nibName)
        postDetailTableView.rowHeight = UITableView.automaticDimension
        postDetailTableView.estimatedRowHeight = 44
        postDetailTableView.separatorStyle = .none
        commentTextView.addSubview(textViewPlaceHolder)
        textViewPlaceHolder.centerYAnchor.constraint(equalTo: commentTextView.centerYAnchor).isActive = true
        commentTextView.delegate = self
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return myHeaderData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1}
        return 12
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0,
           let cell = tableView.dequeueReusableCell(withIdentifier: HomeFeedImageVideoTableViewCell.nibName, for: indexPath) as? HomeFeedImageVideoTableViewCell
        {
            cell.setupFeedCell(HomeFeedViewModel.tempFeedData, withDelegate: nil)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReplyCommentTableViewCell.reuseIdentifier, for: indexPath) as! ReplyCommentTableViewCell
        cell.commentLabel.text = "\(indexPath)"
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil}
        let commentView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentHeaderViewCell.reuseIdentifier) as! CommentHeaderViewCell
        commentView.commentLabel.text = myHeaderData[section]
        return commentView
    }
}

extension PostDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceHolder.isHidden = true
    }
    
}
