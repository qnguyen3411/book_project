//
//  HomeVC.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/25/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit
import GoogleSignIn

class HomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var charts:[ChartObject] = []
    override func viewWillAppear(_ animated: Bool) {
        fetchCharts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "HomeToEditor", sender: nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! EditorVC
        if let chart = sender as? ChartObject {
            dest.currChart = chart
        }
    }
 

}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell") as! ChartCell
//        cell.backgroundColor = .blue
        cell.delegate = self
        cell.loadChart(charts[indexPath.row])
        return cell
    }
    
    
}

extension HomeVC: ChartCellDelegate {
    func cellMainButtonPressed(_ cell: ChartCell) {
        guard let chart = cell.chart else { return }
        performSegue(withIdentifier: "HomeToEditor", sender: chart)
    }
}

extension HomeVC {
    
    func fetchCharts() {
        ChartObject.fetchAll { json in
            print(json)
            guard let successStatus = json["success"] as? Int, successStatus == 1 else { return }
            guard let results = json["results"] as? [NSDictionary] else { return }
            var chartArr:[ChartObject] = []
            print("MAKING CHART OBJECTS:")
            for chartData in results {
                guard let newChart = ChartObject(data: chartData) else { return }
                chartArr.append(newChart)
            }
            self.charts = chartArr
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}
