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
    
    func angleRelativeToSelf(of otherView: UIView) -> CGFloat{
        return frame.angleRelativeToSelf(of: otherView.frame)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension CGRect {
    
    func angleRelativeToSelf(of otherRect: CGRect) -> CGFloat{
        let srcCenter = self.center
        let destCenter =  otherRect.center
        
        var angle = atan2(srcCenter.y - destCenter.y, destCenter.x - srcCenter.x) as CGFloat
        angle += (angle < 0) ? 2 * CGFloat.pi : 0
        return angle
    }
    
    var center: CGPoint {
        let centerX = origin.x + (size.width / 2)
        let centerY = origin.y + (size.height / 2)
        return CGPoint(x: centerX, y: centerY)
    }
    
    var topLeftCorner: CGPoint {
        return origin
    }
    
    var topRightCorner: CGPoint {
        return CGPoint(x: origin.x + size.width, y: 0)
    }
    
    var botRightCorner: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y + size.height)
    }
    
    var botLeftCorner: CGPoint {
        return CGPoint(x: 0, y: origin.y + size.height)
    }
    
    var leftEdgeMidpoint: CGPoint {
        return CGPoint(x: self.origin.x, y: self.origin.y + self.height / 2)
    }
    
    var rightEdgeMidpoint: CGPoint {
        return CGPoint(x: self.origin.x + self.width, y: self.origin.y + self.height / 2)
    }
    
    var topEdgeMidPoint: CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y)
    }
    
    var botEdgeMidPoint: CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height)
    }

}
