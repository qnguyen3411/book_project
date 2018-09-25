//
//  ElementOptionMenu.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/25/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

class ElementOptionMenu: UIView {
    let deleteButton:UIButton = {
        let btn = UIButton()
        btn.setTitle("✖︎", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()
    
    let addButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("✚", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.backgroundColor = .orange
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(deleteButton)
        addSubview(addButton)
        addConstraintsWithFormat("H:[v1(30)]-8-[v0(30)]|", views: addButton, deleteButton)
        addConstraintsWithFormat("V:|[v0]|", views: addButton)
        addConstraintsWithFormat("V:|[v0]|", views: deleteButton)
    }
    
    func setTapEventListeners(addTapped: UITapGestureRecognizer, deleteTapped: UITapGestureRecognizer) {
        addButton.gestureRecognizers = [addTapped]
        deleteButton.gestureRecognizers = [deleteTapped]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   

}
