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
        print("FETCHING CHART...")
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
        cell.indexPath = indexPath
        cell.loadChart(charts[indexPath.row])
        return cell
    }
    
    func getChart(for cell: ChartCell) -> ChartObject?{
        guard let indexPath = cell.indexPath else { return nil }
        return charts[indexPath.row]
    }
}

extension HomeVC: ChartCellDelegate {
    func cellMainButtonPressed(_ cell: ChartCell) {
        guard let chart = getChart(for: cell) else { return }
        performSegue(withIdentifier: "HomeToEditor", sender: chart)
    }
    
    func cellDeleteButtonPressed(_ cell: ChartCell) {
        guard let chart = getChart(for: cell) else { return }
        do {
            try ChartObject.deleteFromDB(chart) { data, response, error in
                guard let response = response as? HTTPURLResponse else { return }
                self.handleDeleteSuccessResponse(response) {_ in
                    guard let indexPath = cell.indexPath else { return }
                    self.charts.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at:[indexPath], with: .automatic)
                    }
                }
            }
        } catch {
            print("CANT DELETE")
        }
    }
    
    func handleDeleteSuccessResponse(_ response: HTTPURLResponse, completion: @escaping (UIAlertAction) -> ()) {
        var alertTitle = ""
        var message = ""
        var action:(UIAlertAction) -> ()
        print("STATUSCODE: \(response.statusCode)")
        switch response.statusCode {
        case 200:
            alertTitle = "Success!"
            message = "Your chart is now deleted!"
            action = completion
        default:
            alertTitle = "Error"
            message = "Something went wrong on our side and your chart isn't deleted"
            action = { alert in }
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: action))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension HomeVC {
    
    func fetchCharts() {
        let urlStr = AppUrls.fetchChartUrlStr
        ApiManager.shared.fetchData(fromUrlString: urlStr) { json in
            guard let successStatus = json["success"] as? Int, successStatus == 1 else { return }
            guard let results = json["results"] as? [NSDictionary] else { return }
            var chartArr:[ChartObject] = []
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
