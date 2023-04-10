//
//  BaseButton.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-19.
//

import UIKit

class BaseButton: UIButton {
    override func draw(_ rect: CGRect) {
        backgroundColor = .white
        layer.cornerRadius = self.frame.height/2
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1).cgColor
        tintColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1)
        setTitleColor(#colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1), for: .normal)
    }
}
