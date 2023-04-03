//
//  GradientColorExtension.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-19.
//

import UIKit

extension UIButton {
    func applyBlueGradientColor() {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            #colorLiteral(red: 0.2822242975, green: 0.3429933786, blue: 0.4983132482, alpha: 1).cgColor,
            #colorLiteral(red: 0.3948013783, green: 0.4809916615, blue: 0.6447818279, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2
        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

