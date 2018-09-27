//
//  BookCell.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

class BookCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    func displayData(forBook book: BookModel) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        thumbnailImageView.render(fromUrlString: book.thumbnailImageName)
    }

}
