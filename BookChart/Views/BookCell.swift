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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func displayData(forBook book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")

        guard let imageUrl = URL(string: book.thumbnailImageName ) else {
            print("CANT GET CONTENT FROM IMAGE URL: \(book.thumbnailImageName)")
            return
        }
        do {
            let data = try Data(contentsOf: imageUrl)
            thumbnailImageView.image = UIImage(data: data)

        } catch {
            print("CANT GET DATA FROM IMAGE URL")
        }
    }

}
