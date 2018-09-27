//
//  ChartModel.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/25/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import Foundation

class ChartObject: Codable {

    var id: Int = 0
    var latestElementIdInDB: Int = 0
    var elements: [ChartElementObject] = []
    var links: [LinkObject] = []
    
    init() {
    }
    
    init?(data:NSDictionary) {
        guard let id = data["id"] as? Int else { return nil }
        guard let latestId = data["lastestElementId"] as? Int else { return nil }
        guard let elementsData = data["elements"] as? [NSDictionary] else { return nil }
        guard let linksData = data["links"] as? [[Int]] else { return nil }
        
        self.id = id
        self.latestElementIdInDB = latestId
        for elemData in elementsData {
            guard let newElement = ChartElementObject(data: elemData) else { continue }
            self.elements.append(newElement)
        }
        for idPair in linksData {
            guard let newLink = LinkObject(fromIdPair: idPair) else { continue }
            self.links.append(newLink)
        }
        
    }
    
    func toJson() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(self)
        return data
    }
    
    static func saveToDB(_ chart:ChartObject, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        let urlToRequest = (chart.id == 0) ? AppUrls.createChartUrlStr : AppUrls.updateChartUrlStr
        let url = URL(string: urlToRequest)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try chart.toJson()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    static func deleteFromDB(_ chart: ChartObject, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        let url = URL(string: AppUrls.deleteChartUrlStr)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let postString = "id=\(chart.id)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}

class ChartElementObject: Codable {
    var id: Int = 0
    var chartId: Int = 0
    var bookId: String = ""
    var x: Double = 0
    var y: Double = 0
    
    init() {
        
    }
    
    convenience init(id: Int, chartId: Int, bookId: String, x: Double, y: Double) {
        self.init()
        self.id = id
        self.chartId = chartId
        self.bookId = bookId
        self.x = x
        self.y = y
    }
    
    init?(data: NSDictionary) {
        guard let bookId = data["bookId"] as? String,
            let id = data["id"] as? Int,
            let x = data["x"] as? Double,
            let y = data["y"] as? Double else {
                return nil
        }

        self.id = id
        self.bookId = bookId
        self.x = x
        self.y = y
    }
    
    init?(view: ChartElementView) {
        guard let bookId = view.book?.googleId else { return nil }
        self.id = view.id
        self.x = Double(view.frame.origin.x)
        self.y = Double(view.frame.origin.y)
        self.bookId = bookId
    }
    
}

class LinkObject: Codable {
    var srcId: Int = 0
    var destId: Int = 0
    
    init(_ srcId: Int, _ destId: Int) {
        self.srcId = srcId
        self.destId = destId
    }
    
    init?(fromIdPair idPair: [Int]) {
        guard idPair.count == 2 else { return nil }
        self.srcId = idPair[0]
        self.destId = idPair[1]
    }
    
    init?(view: ChartLink) {
        guard let srcId = (view.srcView as? ChartElementView)?.id else { return nil }
        guard let destId = (view.destView as? ChartElementView)?.id else { return nil }
        self.srcId = srcId
        self.destId = destId

    }
}

