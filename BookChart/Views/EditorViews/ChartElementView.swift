//
//  ChartElementView.swift
//  BookChart
//
//  Created by Quang Nguyen on 9/26/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//
import UIKit

protocol ChartElementDelegate {
    func elementTapped(_ element: ChartElementView)
    
    func elementMenuAddButtonTapped(_ element: ChartElementView)
    
    func elementMenuDeleteButtonTapped(_ element: ChartElementView)
}


class ChartElementView: UIView {
    
    static var autoIncrementer = 0
    
    var id = 0
    var book: Book?
    var lastLocation:CGPoint = CGPoint(x: 0, y: 0)
    var links: [ChartLink] = []
    var delegate: ChartElementDelegate?
    
    let defaultEmptyView: UIView = {
        let dotted = UIView()
        dotted.translatesAutoresizingMaskIntoConstraints = true
        return dotted
    }()
    
    let coverImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = true
        return imgView
    }()
    
    let elementOptionMenu: ElementOptionMenu = {
        let menu = ElementOptionMenu(frame: CGRect(x: 20, y: -50, width: 100, height: 50))
        return menu
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(detectTap))
        self.gestureRecognizers = [panRecognizer, tapRecognizer]
        self.backgroundColor = .clear
        
        addSubview(defaultEmptyView)
        setUpMenu()
        addConstraintsWithFormat("V:|[v0]|", views: defaultEmptyView)
        addConstraintsWithFormat("H:|[v0]|", views: defaultEmptyView)
        
        defaultEmptyView.addSubview(coverImageView)
        addConstraintsWithFormat("V:|[v0]|", views: coverImageView)
        addConstraintsWithFormat("H:|[v0]|", views: coverImageView)
    }
    
    static func setAutoIncrementer(to num: Int) {
        autoIncrementer = num
    }
    
    func loadBook(_ book:Book) {
        coverImageView.render(fromUrlString: book.thumbnailImageName)
        self.book = book
    }
    
    @objc func detectTap(recognizer: UITapGestureRecognizer) {
        delegate?.elementTapped(self)
    }
    
    @objc func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.location(in: self.superview)
        self.center = CGPoint(x: translation.x,y: translation.y)
        
        for link in links {
            link.updateLine()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
    }
    
    func setUpMenu() {
        addSubview(elementOptionMenu)
        elementOptionMenu.isHidden = true
        elementOptionMenu.addButton.addTarget(self, action: #selector(menuAddButtonTapped), for: .touchUpInside)
        elementOptionMenu.deleteButton.addTarget(self, action: #selector(menuDeleteButtonTapped), for: .touchUpInside)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden {
            print("NOPE")
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }
    
    @objc func menuAddButtonTapped() {
        delegate?.elementMenuAddButtonTapped(self)
    }
    
    @objc func menuDeleteButtonTapped() {
        delegate?.elementMenuDeleteButtonTapped(self)
    }
    
    func presentMenu() {
        elementOptionMenu.isHidden = false
    }
    
    func dismissMenu() {
        elementOptionMenu.isHidden = true
    }
    
    func toggleMenu() {
        elementOptionMenu.isHidden = (elementOptionMenu.isHidden) ? false : true
    }
    
    override func draw(_ rect: CGRect) {
        self.backgroundColor = .clear
        // say you want 8 dots, with perfect fenceposting:
        let totalCount = 8 + 8 - 1
        let fullHeight = bounds.size.height
        let itemLength = fullHeight / CGFloat(totalCount)
        
        let path = UIBezierPath(rect: self.bounds)
        
        path.lineWidth = 4
        
        let dashes: [CGFloat] = [itemLength, itemLength]
        path.setLineDash(dashes, count: dashes.count, phase: 0)
        UIColor.lightGray.setStroke()
        path.stroke()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
