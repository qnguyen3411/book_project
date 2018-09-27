//
//  BookModel.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import Foundation

class BookModel {
    
    var googleId: String = ""
    var title: String = ""
    var authors: [String] = []
    var thumbnailImageName: String = ""
    var publisher: String = ""
    
    init() {}
    
    init?(data:NSDictionary) {
        self.googleId = data["id"] as! String
        let volume = data["volumeInfo"] as! NSDictionary
        self.title = (volume["title"] as? String) ?? ""
        self.authors = (volume["authors"] as? [String]) ?? []
        guard let imageLinks = volume["imageLinks"] as? NSDictionary else { return nil }
        guard let smallThumbnail = imageLinks["smallThumbnail"] as? String else { return nil }
        self.thumbnailImageName = smallThumbnail.replacingOccurrences(of: "&edge=curl", with: "")
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

