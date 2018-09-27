//
//  SearchVC.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

protocol SearchVCDelegate: class {
    func searchResultDidGetSelected(result: BookModel)
}

class SearchVC: UIViewController {
    
    var searchOptions:[BookSearchQuery.KeywordOption] = [
        .general, .inTitle, .inAuthor, .inPublisher, .subject, .isbn
    ]
    var tableData:[BookModel] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate:SearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        enableKeyboardDismissOnTap()
        
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        var query = BookSearchQuery()
        query.addBulkKeywords(["borges"], withOption: .inAuthor)
        fetchVolumes(with: query)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchVolumes(with query: BookSearchQuery) {
        let urlStr = AppUrls.fetchVolumesUrlStr(with: query)
        ApiManager.shared.fetchData(fromUrlString: urlStr) { json in
            if let results = json["items"] as? [NSDictionary] {
                self.tableData = []
                
                for data in results {
                    guard let book = BookModel(data:data) else { continue }
                    self.tableData.append(book)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        cell.displayData(forBook: tableData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = tableData[indexPath.row]
        delegate?.searchResultDidGetSelected(result: book)
        view.endEditing(true)
    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keywords = searchBar.text?.components(separatedBy: " ") else { return }
        var query = BookSearchQuery()
        query.addBulkKeywords(keywords, withOption: .general)
        fetchVolumes(with: query)
    }
    
}
