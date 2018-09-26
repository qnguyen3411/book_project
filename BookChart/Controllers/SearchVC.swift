//
//  SearchVC.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

protocol SearchVCDelegate: class {
    func searchResultDidGetSelected(result: Book)
}

class SearchVC: UIViewController {
    
    var searchOptions:[BookSearchQuery.KeywordOption] = [
        .general, .inTitle, .inAuthor, .inPublisher, .subject, .isbn
    ]
    var tableData:[Book] = []
    
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
    
//    @IBAction func searchButtonPressed(_ sender: UIButton) {
//        var query = BookSearchQuery()
//
//        for keywordField in keywordFields {
//            guard let keywords = keywordField.text else { continue }
//            guard keywords.count != 0 else { continue }
//            let uniqueKeywordArr = Array(Set(keywords.components(separatedBy: " ")))
//
//            let option = searchOptions[keywordField.tag]
//            query.addBulkKeywords(uniqueKeywordArr, withOption: option)
//        }
//        fetchVolumes(with: query)
//    }
    
    func fetchVolumes(with query: BookSearchQuery) {
        BookModel.fetchVolumes(withSearchQuery: query, APIKey: GBookAPIKey) { json in
            if let results = json["items"] as? [NSDictionary] {
                self.tableData = []
                
//                let volumes = results.map() { itemResult in
//                    return itemResult["volumeInfo"] as! NSDictionary
//                }
                
                for item in results {
                    guard let book = BookModel.getBookFromJson(item) else {
                        print("CANT GET BOOK")
                        continue
                    }
//                    let book = Book()
//                    book.title = (volume["title"] as? String) ?? ""
//                    book.authors = (volume["authors"] as? [String]) ?? []
//
//                    guard let imageLinks = volume["imageLinks"] as? NSDictionary else { continue }
//                    guard let smallThumbnail = imageLinks["smallThumbnail"] as? String else { continue }
//                    book.thumbnailImageName = smallThumbnail.replacingOccurrences(of: "&edge=curl", with: "")
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
