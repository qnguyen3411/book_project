//
//  SearchVC.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    
    var searchOptions:[BookSearchQuery.KeywordOption] = [
        .general, .inTitle, .inAuthor, .inPublisher, .subject, .isbn
    ]
    var tableData:[Book] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var keywordFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableKeyboardDismissOnTap()
        
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        var query = BookSearchQuery()
        
        for keywordField in keywordFields {
            guard let keywords = keywordField.text else { continue }
            guard keywords.count != 0 else { continue }
            let uniqueKeywordArr = Array(Set(keywords.components(separatedBy: " ")))

            let option = searchOptions[keywordField.tag]
            query.addBulkKeywords(uniqueKeywordArr, withOption: option)
        }
        fetchVolumes(with: query)
    }
    
    func fetchVolumes(with query: BookSearchQuery) {
        BookModel.fetchVolumes(withSearchQuery: query, APIKey: GBookAPIKey) { json in
            if let results = json["items"] as? [NSDictionary] {
                self.tableData = []
                
                let volumes = results.map() { itemResult in
                    return itemResult["volumeInfo"] as! NSDictionary
                }
                
                for volume in volumes {
                    let book = Book()
                    book.title = (volume["title"] as? String) ?? ""
                    book.authors = (volume["authors"] as? [String]) ?? []
                    
                    guard let imageLinks = volume["imageLinks"] as? NSDictionary else { continue }
                    guard let smallThumbnail = imageLinks["smallThumbnail"] as? String else { continue }
                    book.thumbnailImageName = smallThumbnail.replacingOccurrences(of: "&edge=curl", with: "")
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
    
}
