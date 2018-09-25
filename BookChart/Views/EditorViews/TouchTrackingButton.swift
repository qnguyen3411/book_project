//
//  TouchTrackingButton.swift
//  charttest
//
//  Created by Quang Nguyen on 9/24/18.
//  Copyright © 2018 Quang Nguyen. All rights reserved.
//

import UIKit

protocol TouchTrackingButtonDelegate: class {
    func buttonTouched(with touch: UITouch)
    
    func buttonTouchMoved(_ touch: UITouch)
    
    func buttonTouchEnded(_ touch: UITouch)
}

class TouchTrackingButton: UIButton {
    
    var delegate: TouchTrackingButtonDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        delegate?.buttonTouched(with: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        delegate?.buttonTouchEnded(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        delegate?.buttonTouchMoved(touch)
    }
    
}
