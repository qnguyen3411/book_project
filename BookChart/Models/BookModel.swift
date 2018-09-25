//
//  BookModel.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

let GBookAPIKey = ""

import Foundation

class Book: NSObject {
    var title: String = ""
    var authors: [String] = []
    var thumbnailImageName: String = ""
}

class BookModel {
    
    static func fetchVolumes(withSearchQuery query: BookSearchQuery, APIKey: String, completionHandler: @escaping (NSDictionary) -> Void) {
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes?\(query.toString())&fields=totalItems,items(volumeInfo(title,authors,imageLinks(smallThumbnail)))&key=\(APIKey)")
        
        print("URLSTRING: \(String(describing: url?.absoluteString))")
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
                if let json = json as? NSDictionary {
                    completionHandler(json)
                }
            } catch let jsonError {
                print("JSON ERROR: \(jsonError)")
            }
        }
        task.resume()
    }

}

struct BookSearchQuery {
    
    var page = 0
    var limit = 10
    
    enum KeywordOption: String {
        case general = ""
        case inTitle = "intitle:"
        case inAuthor = "inauthor:"
        case inPublisher = "inpublisher:"
        case subject = "subject:"
        case isbn = "isbn:"
        
        // Library of Congress control number
        case lccn = "lccn:"
        
        // Online Computer Library Center number
        case oclc = "oclc:"
    }
    
    var keywords: [String] = []
    
    mutating func addBulkKeywords(_ texts: [String], withOption option: KeywordOption) {
        for keywordText in texts {
            let keyword = option.rawValue + keywordText
            keywords.append(keyword)
        }
    }
    
    func toString() -> String {
        return "q=" + keywords.joined(separator: "+") + "&startIndex=\(page * limit)&maxResults=\(limit)"
    }
    
    func nextPage() -> BookSearchQuery {
        var nextQuery = self
        nextQuery.page = self.page + 1
        return nextQuery
    }
}

