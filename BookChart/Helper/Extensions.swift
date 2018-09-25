//
//  Extensions.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/19/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

extension UIImageView {
    func render(fromUrlString urlStr: String) {
        guard let imageUrl = URL(string: urlStr ) else {
            print("CANT GET CONTENT FROM IMAGE URL: \(urlStr)")
            return
        }
        do {
            let data = try Data(contentsOf: imageUrl)
            self.image = UIImage(data: data)
        } catch {
            print("CANT GET DATA FROM IMAGE URL")
        }
    }
}

extension UIViewController {
    
    func enableKeyboardDismissOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil, views: viewsDictionary))
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension CGRect {
    enum Edge {
        case left
        case top
        case right
        case bottom
    }
    
    func getMidpoint(forEdge edge: Edge) -> CGPoint {
        switch edge {
        case .left:
            return CGPoint(x: self.origin.x, y: self.origin.y + self.height / 2)
        case .top:
            return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y)
        case .right:
            return CGPoint(x: self.origin.x + self.width, y: self.origin.y + self.height / 2)
        default:
            return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height)
        }
    }
}
