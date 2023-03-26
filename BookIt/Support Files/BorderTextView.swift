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
    
    @IBInspectable var placeholder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var placeholderLeftPadding: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var placeholderTopPadding: CGFloat = 8.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    
    // MARK: - Placeholder Drawing

        override func draw(_ rect: CGRect) {
            super.draw(rect)

            if let placeholder = placeholder, text.isEmpty {
                let placeholderRect = CGRect(x: placeholderLeftPadding, y: placeholderTopPadding, width: rect.width - placeholderLeftPadding - textContainerInset.left - textContainerInset.right, height: rect.height - placeholderTopPadding - textContainerInset.top - textContainerInset.bottom)
                let placeholderAttributes = [NSAttributedString.Key.foregroundColor: placeholderColor, NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 14.0)]
                (placeholder as NSString).draw(in: placeholderRect, withAttributes: placeholderAttributes)
            }
        }

}

