//
//  AppUrls.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/26/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import Foundation
class AppUrls {
    private static let googleBookApiKey = "AIzaSyAg0gaUqEm2ss7z5N-z13WfynAI-otQtJc"
    static let createChartUrlStr = "http://192.168.1.132:8000/"
    static let updateChartUrlStr = "http://192.168.1.132:8000/update"
    static let deleteChartUrlStr = "http://192.168.1.132:8000/delete"
    static let fetchChartUrlStr = "http://192.168.1.132:8000/charts"
    
    static func fetchVolumesUrlStr(with query: BookSearchQuery) -> String {
        return "https://www.googleapis.com/books/v1/volumes?\(query.toString())&fields=totalItems,items(id,volumeInfo(title,authors,imageLinks(smallThumbnail)))&key=\(googleBookApiKey)"
    }
    static func fetchSingleVolumeUrlStr(with id: String) -> String {
        return "https://www.googleapis.com/books/v1/volumes/\(id)"
    }
}
