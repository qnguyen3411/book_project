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
    var elementBeingDisplayed: ChartElement?
    var elementBeingDragged: ChartElement?
    var elementPairToJoin: [ChartElement] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        imageView.isExclusiveTouch = false
        imageView.isUserInteractionEnabled = true
        
        addButton.delegate = self
    }
    
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        currTool = "link"
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        
        if let element = sender as? ChartElement {
            dest.book = element.book
        }
    }
    
    
    func link(_ elementA: ChartElement, _ elementB: ChartElement) {
        let newLink = ChartLink(srcView: elementA, destView: elementB)
        newLink.layer.zPosition = -1
        self.imageView.addSubview(newLink)
        elementA.links.append(newLink)
        elementB.links.append(newLink)
    }
    
    func handleLink(element: ChartElement) {
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
    
    func elementTapped(_ element: ChartElement) {
        if currTool == "link" {
            handleLink(element: element)
        } else {
            print("Should present menu above element")
            element.toggleMenu()
        }
    }
    
    func elementMenuAddButtonTapped(_ element: ChartElement) {
        element.dismissMenu()
        elementBeingDisplayed = element
        performSegue(withIdentifier: "EditorToDisplay", sender: element)
    }
    
    func elementMenuDeleteButtonTapped(_ element: ChartElement) {
        element.dismissMenu()
        element.removeConstraints(element.constraints)
        element.removeFromSuperview()
    }
}

extension EditorVC: TouchTrackingButtonDelegate {
    
    func buttonTouched(with touch: UITouch) {
        let location = touch.location(in: imageView)
        let origin = CGPoint(x: location.x + 50, y: location.y + 50)
        let element = ChartElement(frame: CGRect(origin: origin, size: CGSize(width: 100, height: 150)))
        element.delegate = self
        element.isExclusiveTouch = true
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
    func displayVC(_ displayController: DisplayVC, didSaveNewBook book: Book) {
        guard let element = elementBeingDisplayed else {
            print("NO ELEMENT BEING INSPECTED")
            return
        }
        element.loadBook(book)
        
    }

}

