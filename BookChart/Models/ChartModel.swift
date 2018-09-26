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
    var lastestElementIdInDB: Int = 0
    var elements: [ChartElementObject] = []
    var links: [LinkObject] = []
    
    func toJson() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            print(String(data: data, encoding: .utf8)!)
        } catch {
            print("ERROR")
        }
        
    }
}

class ChartElementObject: Codable {
    var id: Int = 0
    var chartId: Int = 0
    var bookId: String = ""
    var x: Double = 0
    var y: Double = 0
    
    convenience init(id: Int, chartId: Int, bookId: String, x: Double, y: Double) {
        self.init()
        self.id = id
        self.chartId = chartId
        self.bookId = bookId
        self.x = x
        self.y = y
    }
    
}

class LinkObject: Codable {
    var srcId: Int = 0
    var destId: Int = 0
    
    init(_ srcId: Int, _ destId: Int) {
        self.srcId = srcId
        self.destId = destId
    }
    
}

