//
//  ChartLink.swift
//  charttest
//
//  Created by Quang Nguyen on 9/24/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//
// Given 2 UI view, ChartLink(view1, view2) will draw a line between them
import UIKit

class LinkManager {
    var links:[ChartLink] = []
    
    func add(link: ChartLink) {
        links.append(link)
    }
    
    func clear() {
        while !links.isEmpty {
            let link = links.removeFirst()
            link.removeFromSuperview()
        }
    }
    
    func updateAll() {
        links.forEach { $0.updateLine() }
    }
}


class ChartLink: UIView {
    
    var srcView: UIView?
    var destView: UIView?
    var lastOctant: Int = 0
    
    var lineView: ZigzagLine = {
        let zigzag = ZigzagLine()
        return zigzag
    }()
    
    init(srcView: UIView, destView: UIView) {
        super.init(frame: CGRect.zero)
        self.srcView = srcView
        self.destView = destView
        
        addSubview(lineView)
        addConstraintsWithFormat("V:|[v0]|", views: lineView)
        addConstraintsWithFormat("H:|[v0]|", views: lineView)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        lineView.button.gestureRecognizers = [tapRecognizer]
        updateLine()
    }
    
    func updateLine() {
        guard let srcView = srcView, let destView = destView else { return }
        let angle = srcView.angleRelativeToSelf(of: destView)
        let octant = Int(ceil(angle / (CGFloat.pi / 4))) % 8
        
        setFrame(srcView: srcView, destView: destView, octant: octant)
        if octant != lastOctant {
            lastOctant = octant
            drawLink(octant: octant)
        }
    }
    
    func setFrame(srcView: UIView, destView: UIView, octant: Int) {
        let attachPoints = getAttachPoints(srcView: srcView, destView: destView, octant: octant)
        var origin = CGPoint.zero
        guard let start = attachPoints["start"], let end = attachPoints["end"] else { return }
        
        switch octant {
        case 1, 2:
            origin = CGPoint(x: start.x, y: end.y)
        case 3, 4:
            origin = end
        case 5, 6:
            origin = CGPoint(x: end.x, y: start.y)
        default:
            origin = start
        }
        
        let width = abs(end.x - start.x)
        let height = abs(end.y - start.y)
        self.frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    func getAttachPoints(srcView: UIView, destView: UIView, octant: Int) -> [String:CGPoint] {
        var output = ["start": CGPoint.zero, "end": CGPoint.zero]
        switch octant {
        case 1, 0:
            output["start"] = srcView.frame.rightEdgeMidpoint
            output["end"] = destView.frame.leftEdgeMidpoint
        case 2, 3:
            output["start"] = srcView.frame.topEdgeMidPoint
            output["end"] = destView.frame.botEdgeMidPoint
        case 4, 5:
            output["start"] = srcView.frame.leftEdgeMidpoint
            output["end"] = destView.frame.rightEdgeMidpoint
        default:
            output["start"] = srcView.frame.botEdgeMidPoint
            output["end"] = destView.frame.topEdgeMidPoint
        }
        return output
    }
    
    func drawLink(octant: Int) {
        switch octant {
        case 1, 5:
            lineView.updateConstraintSet(option: .rightUpRight)
        case 2, 6:
            lineView.updateConstraintSet(option: .upRightUp)
        case 3, 7:
            lineView.updateConstraintSet(option: .upLeftUp)
        default:
            lineView.updateConstraintSet(option: .rightDownRight)
        }
    }
    
    @objc func buttonTapped() {
        removeConstraints(constraints)
        removeFromSuperview()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}


class ZigzagLine: UIView {
    
    enum ConstraintSetOption {
        case upRightUp
        case rightUpRight
        case upLeftUp
        case rightDownRight
    }
    
    var lineWidth:CGFloat = 5
    
    let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let midLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let button: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12.5
        btn.backgroundColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var upRightUpConstraints:[NSLayoutConstraint] = []
    var rightUpRightConstraints:[NSLayoutConstraint] = []
    var upLeftUpConstraints:[NSLayoutConstraint] = []
    var rightDownRightConstraints:[NSLayoutConstraint] = []
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        addSubview(leftLine)
        addSubview(midLine)
        addSubview(rightLine)
        addSubview(button)
        
        setUpConstraintSets()
        updateConstraintSet(option: .upRightUp)
    }
    
    convenience init(frame:CGRect, lineWidth: CGFloat) {
        self.init(frame: frame)
        self.lineWidth = lineWidth
        
    }
    
    func setUpConstraintSets() {
        // Constant constraint set
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 25),
            button.heightAnchor.constraint(equalToConstant: 25),
            leftLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            rightLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            midLine.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            midLine.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        upRightUpConstraints = [
            leftLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            leftLine.widthAnchor.constraint(equalToConstant: lineWidth),
            leftLine.topAnchor.constraint(equalTo: self.centerYAnchor),
            midLine.heightAnchor.constraint(equalToConstant: lineWidth),
            midLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            midLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            rightLine.topAnchor.constraint(equalTo: self.topAnchor),
            rightLine.bottomAnchor.constraint(equalTo: self.centerYAnchor),
            rightLine.widthAnchor.constraint(equalToConstant: lineWidth),
        ]
        
        rightUpRightConstraints = [
            leftLine.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: lineWidth),
            leftLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            midLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            midLine.topAnchor.constraint(equalTo: self.topAnchor),
            midLine.widthAnchor.constraint(equalToConstant: lineWidth),
            rightLine.topAnchor.constraint(equalTo: self.topAnchor),
            rightLine.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: lineWidth),
        ]
        
        upLeftUpConstraints = [
            leftLine.topAnchor.constraint(equalTo: self.topAnchor),
            leftLine.bottomAnchor.constraint(equalTo: self.centerYAnchor),
            leftLine.widthAnchor.constraint(equalToConstant: lineWidth),
            midLine.heightAnchor.constraint(equalToConstant: lineWidth),
            midLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            midLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            rightLine.topAnchor.constraint(equalTo: self.centerYAnchor),
            rightLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightLine.widthAnchor.constraint(equalToConstant: lineWidth)
        ]
        
        rightDownRightConstraints = [
            leftLine.topAnchor.constraint(equalTo: self.topAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: lineWidth),
            leftLine.trailingAnchor.constraint(equalTo: self.centerXAnchor),
            midLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            midLine.topAnchor.constraint(equalTo: self.topAnchor),
            midLine.widthAnchor.constraint(equalToConstant: lineWidth),
            rightLine.leadingAnchor.constraint(equalTo: self.centerXAnchor),
            rightLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: lineWidth)
        ]
    }
    
    func updateConstraintSet(option: ConstraintSetOption) {
        // reset constraints
        NSLayoutConstraint.deactivate(
            upRightUpConstraints
            + rightUpRightConstraints
            + upLeftUpConstraints
            + rightDownRightConstraints
        )
        
        switch option {
        case .rightUpRight:
            NSLayoutConstraint.activate(rightUpRightConstraints)
        case .upRightUp:
            NSLayoutConstraint.activate(upRightUpConstraints)
        case .upLeftUp:
            NSLayoutConstraint.activate(upLeftUpConstraints)
        default:
            NSLayoutConstraint.activate(rightDownRightConstraints)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

