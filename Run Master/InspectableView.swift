//
//  InspectableView.swift
//  Run Master
//
//  Created by Danny Espina on 10/25/17.
//  Copyright © 2017 LegendarySilverback. All rights reserved.
//

import UIKit
class InspectableView: UIButton{
    
    // Background Color.
    
    @IBInspectable var backColor: UIColor? {
        didSet {
            backgroundColor = backColor
        }
    }
    
    // Corner Radius.
    
    @IBInspectable var corRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corRadius
            layer.masksToBounds = corRadius > 0
        }
    }
    
    // Border Width
    
    @IBInspectable var borderwidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderwidth
            layer.masksToBounds = borderwidth > 0
        }
    }
    
    // Border Color.
    @IBInspectable var borderColor : UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
        }
    }
}

