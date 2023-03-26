//
//  IconTextField.swift
//  Capstone Practice
//
//  Created by Sonia Nain on 2023-03-26.
//

import UIKit

@IBDesignable extension UITextField {

    @IBInspectable var leftIcon: UIImage? {
        get {
            return leftView?.subviews.compactMap { $0 as? UIImageView }.first?.image
        }
        set {
            if let icon = newValue {
                let iconView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
                iconView.tintColor = iconColor
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + iconPadding, height: frame.height))
                iconView.center = paddingView.center
                paddingView.addSubview(iconView)
                leftView = paddingView
                leftViewMode = .always
            } else {
                leftView = nil
                leftViewMode = .never
            }
        }
    }

    @IBInspectable var rightIcon: UIImage? {
        get {
            return rightView?.subviews.compactMap { $0 as? UIImageView }.first?.image
        }
        set {
            if let icon = newValue {
                let iconView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
                iconView.tintColor = iconColor
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + iconPadding, height: frame.height))
                iconView.center = paddingView.center
                paddingView.addSubview(iconView)
                rightView = paddingView
                rightViewMode = .always
            } else {
                rightView = nil
                rightViewMode = .never
            }
        }
    }

    @IBInspectable var iconColor: UIColor {
        get {
            if let iconView = leftView?.subviews.compactMap { $0 as? UIImageView }.first {
                return iconView.tintColor
            } else if let iconView = rightView?.subviews.compactMap { $0 as? UIImageView }.first {
                return iconView.tintColor
            } else {
                return .lightGray
            }
        }
        set {
            leftView?.subviews.compactMap { $0 as? UIImageView }.forEach { $0.tintColor = newValue }
            rightView?.subviews.compactMap { $0 as? UIImageView }.forEach { $0.tintColor = newValue }
        }
    }

    @IBInspectable var iconPadding: CGFloat {
        get {
            if let paddingView = leftView {
                return paddingView.frame.width - 24
            } else if let paddingView = rightView {
                return paddingView.frame.width - 24
            } else {
                return 0
            }
        }
        set {
            if let paddingView = leftView {
                let newFrame = CGRect(x: 0, y: 0, width: 24 + newValue, height: frame.height)
                let iconView = paddingView.subviews.compactMap { $0 as? UIImageView }.first
                iconView?.center = CGPoint(x: newFrame.width / 2, y: newFrame.height / 2)
                paddingView.frame = newFrame
            } else if let paddingView = rightView {
                let newFrame = CGRect(x: 0, y: 0, width: 24 + newValue, height: frame.height)
                let iconView = paddingView.subviews.compactMap { $0 as? UIImageView }.first
                iconView?.center = CGPoint(x: newFrame.width / 2, y: newFrame.height / 2)
                paddingView.frame = newFrame
            }
        }
    }

}
