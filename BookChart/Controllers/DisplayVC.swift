//
//  DisplayVC.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/25/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

protocol DisplayVCDelegate: class {
    func displayVC(_ displayController: DisplayVC, didSaveNewBook book: BookModel)
}

class DisplayVC: UIViewController {

    @IBOutlet weak var bookImageView: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    var delegate: DisplayVCDelegate?
    var book: BookModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderData()
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "DisplayToSearch", sender: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let searchVC = nav.topViewController as! SearchVC
        searchVC.delegate = self
    }
    
    func renderData() {
        if let book = self.book {
            titleLabel.text = "Title: " + book.title
            authorsLabel.text = "Written by: " + book.authors.joined(separator: ", ")
            bookImageView.render(fromUrlString: book.thumbnailImageName)
        }
    }

}

extension DisplayVC: SearchVCDelegate {
    func searchResultDidGetSelected(result: BookModel) {
        self.book = result
        renderData()
        delegate?.displayVC(self, didSaveNewBook: result)
        dismiss(animated: true, completion: nil)
    }

}
