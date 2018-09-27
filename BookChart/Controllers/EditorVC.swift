//
//  ViewController.swift
//  charttest
//
//  Created by Quang Nguyen on 9/21/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

class EditorVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var addButton: TouchTrackingButton!

    var currTool = ""
    var elementBeingDisplayed: ChartElementView?
    var elementBeingDragged: ChartElementView?
    var elementPairToJoin: [ChartElementView] = []
    
    var currChart: ChartObject?
    var autoIncrementer: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        imageView.isExclusiveTouch = false
        imageView.isUserInteractionEnabled = true
        
        addButton.delegate = self
        
        if let chart = currChart {
            print("RENDERING \(chart)")
            renderChart(chart)
        } else {
            print("NO CHART")
        }
    }
    
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        currTool = "link"
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        let chart = saveToChartObject()
        do {
            try ChartObject.saveToDB(chart) {data, response, error in
                if let response = response as? HTTPURLResponse {
                    self.handleSaveSuccessStatus(response: response)
                }
//                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            print("ERROR TRYING TO POST TO SERVER")
        }
    }
    
    func handleSaveSuccessStatus(response: HTTPURLResponse) {
        var alertTitle = ""
        var message = ""
        var action:(UIAlertAction) -> ()
        switch response.statusCode {
        case 200:
            alertTitle = "Success!"
            message = "Your chart is now saved!"
            action = {alert in self.dismiss(animated: true, completion: nil)}
        default:
            alertTitle = "Error"
            message = "Something went wrong on our side and your chart wasn't saved"
            action = { alert in }
        }
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: action))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setUpScrollView() {
        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = UIScreen.main.bounds.height / imageView.frame.height
        scrollView.canCancelContentTouches = false
        scrollView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let dest = nav.topViewController as! DisplayVC
        dest.delegate = self
        
        if let element = sender as? ChartElementView {
            dest.book = element.book
        }
    }
    
    func link(_ elementA: ChartElementView, _ elementB: ChartElementView) {
        let newLink = ChartLink(srcView: elementA, destView: elementB)
        newLink.layer.zPosition = -1
        self.imageView.addSubview(newLink)
        elementA.addLink(newLink)
        elementB.addLink(newLink)
    }
    
    func handleLink(element: ChartElementView) {
        elementPairToJoin.append(element)
        if elementPairToJoin.count == 2 {
            if elementPairToJoin[0] !== elementPairToJoin[1] {
                link(elementPairToJoin[0], elementPairToJoin[1])
                elementPairToJoin = []
                currTool = ""
            } else {
                _ = elementPairToJoin.popLast()
            }
        }
    }
    
}

extension EditorVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension EditorVC: ChartElementDelegate {
    
    func elementTapped(_ element: ChartElementView) {
        if currTool == "link" {
            handleLink(element: element)
        } else {
            for subview in self.imageView.subviews {
                if let chartElem = subview as? ChartElementView {
                    chartElem.dismissMenu()
                }
            }
            element.toggleMenu()
        }
    }
    
    func elementMenuAddButtonTapped(_ element: ChartElementView) {
        element.dismissMenu()
        elementBeingDisplayed = element
        performSegue(withIdentifier: "EditorToDisplay", sender: element)
    }
    
    func elementMenuDeleteButtonTapped(_ element: ChartElementView) {
//        element.dismissMenu()
//        element.removeConstraints(element.constraints)
//        element.removeFromSuperview()
    }
    
}

extension EditorVC: TouchTrackingButtonDelegate {
    
    func buttonTouched(with touch: UITouch) {
        let location = touch.location(in: imageView)
        let origin = CGPoint(x: location.x + 50, y: location.y + 50)
        let element = ChartElementView(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 150)))
        element.delegate = self
        elementBeingDragged = element
        self.imageView.addSubview(element)
    }
    
    func buttonTouchMoved(_ touch: UITouch) {
        if let element = elementBeingDragged {
            let translation  = touch.location(in: imageView)
            element.center = CGPoint(x: translation.x, y: translation.y)
        }
    }
    
    func buttonTouchEnded(_ touch: UITouch) {
        elementBeingDragged = nil
    }
    
}

extension EditorVC: DisplayVCDelegate {
    
    func displayVC(_ displayController: DisplayVC, didSaveNewBook book: BookModel) {
        guard let element = elementBeingDisplayed else {
            print("NO ELEMENT BEING INSPECTED")
            return
        }
        element.loadBook(book)
    }

}

extension EditorVC {
    
    func renderChart(_ chart:ChartObject) {
        ChartElementView.setAutoIncrementer(to: chart.latestElementIdInDB )
        var elemDict: [Int:ChartElementView] = [:]
        for element in chart.elements {
            let urlStr = AppUrls.fetchSingleVolumeUrlStr(with: element.bookId)
            ApiManager.shared.fetchData(fromUrlString: urlStr) { json in
                guard let book = BookModel(data:json) else { return }
                DispatchQueue.main.async {
                    let chartElement = ChartElementView()
                    chartElement.loadBook(book)
                    chartElement.id = element.id
                    chartElement.delegate = self
                    chartElement.frame = CGRect(x: element.x, y: element.y, width: 100, height: 150)
                    self.imageView.addSubview(chartElement)
                    elemDict[element.id] = chartElement
                    
                    guard elemDict.count == chart.elements.count else { return }
                    for link in chart.links {
                        self.link(elemDict[link.srcId]!, elemDict[link.destId]!)
                    }
                }
            }
        }
        ChartElementView.setAutoIncrementer(to: chart.latestElementIdInDB )

    }
    
    func saveToChartObject() -> ChartObject {
        let chart = ChartObject()
        if let id = self.currChart?.id, let lastestElemId = self.currChart?.latestElementIdInDB {
            chart.id = id
            chart.latestElementIdInDB = lastestElemId
        }
        
        for subView in self.imageView.subviews {
            if let elementView = subView as? ChartElementView {
                guard let elem = ChartElementObject(view: elementView) else { continue }
                chart.elements.append(elem)
            }
            if let linkView = subView as? ChartLink {
                guard let link = LinkObject(view: linkView) else { continue }
                chart.links.append(link)
            }
        }
        return chart
    }
    
}
