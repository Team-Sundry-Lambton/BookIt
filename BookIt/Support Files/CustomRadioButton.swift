//
//  CustomRadioButton.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-22.
//

import UIKit

class CustomRadioButton: UIButton {

    let checkedImage = UIImage(named: "radioChecked")! as UIImage
    let uncheckedImage = UIImage(named: "radioUnchecked")! as UIImage
    
    override var isSelected: Bool {
        didSet {
            let image = isSelected ? checkedImage : uncheckedImage
            setImage(image, for: UIControl.State.normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    func setupButton() {
        setImage(uncheckedImage, for: UIControl.State.normal)
        addTarget(self, action: #selector(buttonClicked), for: UIControl.Event.touchUpInside)
    }

    @objc func buttonClicked() {
        isSelected = !isSelected
    }
}
