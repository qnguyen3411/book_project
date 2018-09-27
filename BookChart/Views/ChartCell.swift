//
//  ChartCell.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/25/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

protocol ChartCellDelegate {
    func cellMainButtonPressed(_ cell: ChartCell)
}


class ChartCell: UITableViewCell {

    var chart: ChartObject?
    var delegate: ChartCellDelegate?
    
    @IBOutlet weak var chartView: UIImageView!
    
    @IBOutlet weak var mainButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadChart(_ chart: ChartObject) {
        self.chart = chart
        self.mainButton.setTitle("ID: \(chart.id)", for: .normal)
    }
    
    @IBAction func mainButtonPressed(_ sender: UIButton) {
        print("PRESSED")
        delegate?.cellMainButtonPressed(self)
    }
    

}
