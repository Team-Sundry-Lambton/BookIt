//
//  BorderTextView.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-08.
//

import Foundation
import UIKit

@IBDesignable
class BorderTextView: UITextView {

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

