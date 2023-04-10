//
//  LoadingHudManager.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-20.
//

import Foundation
import JGProgressHUD

class LoadingHudManager {
    static let shared = LoadingHudManager()
    let hud = JGProgressHUD()

    func showSimpleHUD(title: String, view: UIView) {
        hud.backgroundColor = UIColor(white: 1, alpha: 0.5)
        hud.contentView.backgroundColor = UIColor.white
        hud.textLabel.tintColor = UIColor.black
        hud.vibrancyEnabled = true
        #if os(tvOS)
            hud.textLabel.text = title
        #else
            hud.textLabel.text = title
        #endif
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        hud.show(in: view)
    }
    
    func dissmissHud(){
        hud.dismiss()
    }
}
