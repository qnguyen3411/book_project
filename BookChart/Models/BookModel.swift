//
//  BookModel.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

let GBookAPIKey = "AIzaSyAg0gaUqEm2ss7z5N-z13WfynAI-otQtJc"

import Foundation

class Book: NSObject {
    var googleId: String = ""
    var title: String = ""
    var authors: [String] = []
    var thumbnailImageName: String = ""
    var publisher: String = ""
}

class BookModel {
    
    static func fetchVolumes(withSearchQuery query: BookSearchQuery, APIKey: String, completionHandler: @escaping (NSDictionary) -> Void) {
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes?\(query.toString())&fields=totalItems,items(id,volumeInfo(title,authors,imageLinks(smallThumbnail)))&key=\(APIKey)")
        
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
    
    static func fetchVolume(id:String, APIKey: String,completionHandler: @escaping (NSDictionary) -> Void) {
        let url = URL(string: "https://www.googleapis.com/books/v1/volumes/\(id)")
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
    
    static func getBookFromJson(_ json: NSDictionary) -> Book? {
        let book = Book()
        book.googleId = json["id"] as! String
        let volume = json["volumeInfo"] as! NSDictionary
        book.title = (volume["title"] as? String) ?? ""
        book.authors = (volume["authors"] as? [String]) ?? []
        guard let imageLinks = volume["imageLinks"] as? NSDictionary else {
            return nil
        }
        guard let smallThumbnail = imageLinks["smallThumbnail"] as? String else {
            return nil
        }
        book.thumbnailImageName = smallThumbnail.replacingOccurrences(of: "&edge=curl", with: "")
        return book
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

